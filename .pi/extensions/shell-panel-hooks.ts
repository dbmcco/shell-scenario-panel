/**
 * shell-panel-hooks.ts — Shell Scenario Panel lifecycle hooks for the Pi coding agent.
 *
 * This is a thin Pi adapter around the repo's existing hook scripts (dumb pipes are
 * reused, not ported). Every script is invoked exactly as Claude Code invokes it:
 * with cwd = repo root (the scripts use repo-relative paths like
 * `scenarios/active/...`), CLAUDE_PROJECT_DIR set to the repo root, and Claude-style
 * hook JSON on stdin. Script failures are logged to stderr only and never break the
 * panel session.
 *
 * Pi event → Claude hook mapping (mirrors .claude/settings.json):
 *
 *   session_start      → .claude/hooks/pre-session.sh           (Claude "SessionStart",     10s)
 *                        Startup banner: active scenarios, phase, specialist roster.
 *                        Reads no stdin.
 *
 *   before_agent_start → .claude/hooks/on-user-message.sh       (Claude "UserPromptSubmit", 15s)
 *                        Logs the user's prompt to moderator_dialog.jsonl, runs the Phase 0
 *                        gate check and quality-gate.sh. Parses `.prompt` from stdin
 *                        (`jq -r '.prompt // empty'`); event.prompt supplies it.
 *
 *   tool_execution_end → .claude/hooks/post-task.sh             (Claude "PostToolUse" matcher "Task", 30s)
 *                        Post-consultation transcript reminders. Filtered to
 *                        toolName === "subagent" — in Pi, specialist consultations run
 *                        through the "subagent" tool (pi-subagents), the analogue of
 *                        Claude Code's "Task" tool. Reads no stdin (Claude PostToolUse
 *                        shape supplied anyway, built from event.toolName/result).
 *
 *   agent_end          → .claude/hooks/on-response-complete.sh  (Claude "Stop",             30s)
 *                        Detects panel completion and generates exports. agent_end is used
 *                        rather than turn_end because Claude's Stop fires once when the
 *                        main agent finishes responding to the user — not per LLM turn
 *                        inside a tool-calling run — and the export script is idempotent
 *                        (`.completion_processed` marker). Reads no stdin (Claude Stop
 *                        shape supplied anyway).
 *
 * Project-local discovery: `.pi/extensions/*.ts` loads automatically once the project
 * is trusted. No npm dependencies; Node built-ins only.
 */

import { spawn } from "node:child_process";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

/** Cap on captured stdout/stderr per hook run (prevents runaway output). */
const MAX_CAPTURE = 64 * 1024;
/** Cap on what is surfaced through ctx.ui.notify. */
const MAX_NOTIFY = 1600;
/** Name of the Pi tool that runs specialist consultations (registered by pi-subagents). */
const SUBAGENT_TOOL = "subagent";

/** Claude hook timeouts (from .claude/settings.json). */
const TIMEOUTS = {
  preSession: 10_000,
  onUserMessage: 15_000,
  postTask: 30_000,
  onResponseComplete: 30_000,
} as const;

/** Minimal structural types for the Pi extension API surface used here. */
interface ExtensionContextLike {
  cwd: string;
  hasUI: boolean;
  ui: {
    notify(message: string, type?: "info" | "warning" | "error"): void;
  };
  sessionManager?: {
    getSessionId?(): string;
    getSessionFile?(): string | undefined;
  };
}

interface ExtensionApiLike {
  on(
    event: string,
    handler: (event: any, ctx: ExtensionContextLike) => void | Promise<void>
  ): void;
}

interface HookResult {
  stdout: string;
  stderr: string;
  code: number | null;
  timedOut: boolean;
}

function logFailure(hook: string, result: HookResult): void {
  const detail =
    (result.timedOut ? "timed out" : `exit code ${result.code ?? "n/a"}`) +
    (result.stderr.trim() ? `; stderr: ${result.stderr.trim().slice(0, 800)}` : "");
  process.stderr.write(`[shell-panel-hooks] ${hook} failed (${detail})\n`);
}

/**
 * Run one hook script with repo-root cwd, CLAUDE_PROJECT_DIR set, and the given
 * JSON payload on stdin. Always resolves; never throws.
 */
function runHook(
  hookPath: string,
  repoRoot: string,
  stdinPayload: string,
  timeoutMs: number
): Promise<HookResult> {
  return new Promise((resolvePromise) => {
    const env = { ...process.env, CLAUDE_PROJECT_DIR: repoRoot };
    let child: ReturnType<typeof spawn>;
    try {
      child = spawn(hookPath, [], { cwd: repoRoot, env });
    } catch (err) {
      process.stderr.write(`[shell-panel-hooks] spawn ${hookPath}: ${String(err)}\n`);
      resolvePromise({ stdout: "", stderr: String(err), code: null, timedOut: false });
      return;
    }

    let stdout = "";
    let stderr = "";
    let timedOut = false;
    let settled = false;

    const settle = (code: number | null) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      resolvePromise({ stdout, stderr, code, timedOut });
    };

    const timer = setTimeout(() => {
      timedOut = true;
      try {
        child.kill("SIGKILL");
      } catch {
        /* already gone */
      }
    }, timeoutMs);

    child.stdout?.on("data", (chunk: Buffer) => {
      if (stdout.length < MAX_CAPTURE) stdout += chunk.toString();
    });
    child.stderr?.on("data", (chunk: Buffer) => {
      if (stderr.length < MAX_CAPTURE) stderr += chunk.toString();
    });
    child.on("error", (err: NodeJS.ErrnoException) => {
      // Not executable / not found via shebang exec: retry once through bash.
      if (err.code === "EACCES" || err.code === "ENOENT") {
        try {
          const fallback = spawn("bash", [hookPath], { cwd: repoRoot, env });
          fallback.stdout?.on("data", (chunk: Buffer) => {
            if (stdout.length < MAX_CAPTURE) stdout += chunk.toString();
          });
          fallback.stderr?.on("data", (chunk: Buffer) => {
            if (stderr.length < MAX_CAPTURE) stderr += chunk.toString();
          });
          fallback.on("error", (err2: Error) => {
            stderr += String(err2);
            settle(null);
          });
          fallback.on("close", (code: number | null) => settle(code));
          fallback.stdin?.on("error", () => {});
          fallback.stdin?.end(stdinPayload);
          return;
        } catch (err2) {
          stderr += String(err2);
        }
      }
      stderr += String(err);
      settle(null);
    });
    child.on("close", (code: number | null) => settle(code));

    // Scripts that never read stdin (pre-session, post-task, on-response-complete)
    // may close their pipe early — swallow EPIPE instead of crashing the session.
    child.stdin?.on("error", () => {});
    child.stdin?.end(stdinPayload);
  });
}

/** Show captured hook output to the user; route failures to stderr only. */
function report(
  ctx: ExtensionContextLike,
  hook: string,
  result: HookResult,
  label: string
): void {
  if (result.timedOut || (result.code !== null && result.code !== 0)) {
    logFailure(hook, result);
  }
  const text = result.stdout.trim();
  if (!text) return;
  const shown =
    text.length > MAX_NOTIFY ? `${text.slice(0, MAX_NOTIFY)}\n…[truncated]` : text;
  if (ctx.hasUI) {
    ctx.ui.notify(`${label}\n${shown}`, "info");
  } else {
    process.stderr.write(`[shell-panel-hooks] ${label}\n${shown}\n`);
  }
}

/** Best-effort session identifiers mirroring Claude's hook stdin fields. */
function sessionFields(ctx: ExtensionContextLike, repoRoot: string): Record<string, unknown> {
  let sessionId = "";
  let sessionFile: string | undefined;
  try {
    sessionId = ctx.sessionManager?.getSessionId?.() ?? "";
  } catch {
    /* optional */
  }
  try {
    sessionFile = ctx.sessionManager?.getSessionFile?.();
  } catch {
    /* optional */
  }
  return {
    session_id: sessionId,
    transcript_path: sessionFile ?? "",
    cwd: ctx.cwd || repoRoot,
  };
}

export default function shellPanelHooks(pi: ExtensionApiLike): void {
  // Extension file lives at <repo>/.pi/extensions/shell-panel-hooks.ts → repo root
  // is ../../.. relative to this file.
  const extensionFile = fileURLToPath(import.meta.url);
  const repoRoot = resolve(extensionFile, "..", "..", "..");
  const hooksDir = join(repoRoot, ".claude", "hooks");

  // session_start → Claude "SessionStart" → pre-session.sh (10s)
  pi.on("session_start", async (_event, ctx) => {
    try {
      const result = await runHook(
        join(hooksDir, "pre-session.sh"),
        repoRoot,
        "",
        TIMEOUTS.preSession
      );
      report(ctx, "pre-session.sh", result, "Shell Scenario Panel — session");
    } catch (err) {
      process.stderr.write(`[shell-panel-hooks] pre-session.sh: ${String(err)}\n`);
    }
  });

  // before_agent_start → Claude "UserPromptSubmit" → on-user-message.sh (15s)
  // The script parses `.prompt` from stdin: `jq -r '.prompt // empty'`.
  pi.on("before_agent_start", async (event: { prompt?: string }, ctx) => {
    try {
      const prompt = typeof event?.prompt === "string" ? event.prompt : "";
      if (!prompt) return;
      const stdin = JSON.stringify({
        ...sessionFields(ctx, repoRoot),
        hook_event_name: "UserPromptSubmit",
        prompt,
      });
      const result = await runHook(
        join(hooksDir, "on-user-message.sh"),
        repoRoot,
        stdin,
        TIMEOUTS.onUserMessage
      );
      report(ctx, "on-user-message.sh", result, "Shell Scenario Panel — prompt logged");
    } catch (err) {
      process.stderr.write(`[shell-panel-hooks] on-user-message.sh: ${String(err)}\n`);
    }
  });

  // tool_execution_end → Claude "PostToolUse" (matcher "Task") → post-task.sh (30s)
  // Fires only for specialist-consultation calls: Pi's "subagent" tool.
  pi.on(
    "tool_execution_end",
    async (
      event: { toolCallId?: string; toolName?: string; result?: any; isError?: boolean },
      ctx
    ) => {
      try {
        if (event?.toolName !== SUBAGENT_TOOL) return;
        const result = event.result ?? {};
        const stdin = JSON.stringify({
          ...sessionFields(ctx, repoRoot),
          hook_event_name: "PostToolUse",
          tool_name: event.toolName,
          tool_call_id: event.toolCallId ?? "",
          // tool_execution_end carries no args; Claude's tool_input equivalent is
          // available on tool_execution_start. post-task.sh reads no stdin today.
          tool_input: {},
          tool_response: {
            content: result.content ?? [],
            details: result.details ?? {},
            isError: event.isError ?? false,
          },
        });
        const hookResult = await runHook(
          join(hooksDir, "post-task.sh"),
          repoRoot,
          stdin,
          TIMEOUTS.postTask
        );
        report(ctx, "post-task.sh", hookResult, "Shell Scenario Panel — consultation ended");
      } catch (err) {
        process.stderr.write(`[shell-panel-hooks] post-task.sh: ${String(err)}\n`);
      }
    }
  );

  // agent_end → Claude "Stop" → on-response-complete.sh (30s)
  pi.on("agent_end", async (_event, ctx) => {
    try {
      const stdin = JSON.stringify({
        ...sessionFields(ctx, repoRoot),
        hook_event_name: "Stop",
        stop_hook_active: false,
      });
      const result = await runHook(
        join(hooksDir, "on-response-complete.sh"),
        repoRoot,
        stdin,
        TIMEOUTS.onResponseComplete
      );
      report(ctx, "on-response-complete.sh", result, "Shell Scenario Panel — response complete");
    } catch (err) {
      process.stderr.write(`[shell-panel-hooks] on-response-complete.sh: ${String(err)}\n`);
    }
  });
}

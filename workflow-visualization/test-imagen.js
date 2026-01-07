// Test Gemini image generation API call
const API_KEY = 'REDACTED';
const API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent';

async function testImageGeneration() {
  console.log('Testing Gemini image generation API...');

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': API_KEY
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: 'Professional headshot of a business consultant, neutral gray background, corporate style'
          }]
        }]
      })
    });

    console.log('Response status:', response.status);

    const text = await response.text();

    if (response.ok) {
      const data = JSON.parse(text);
      console.log('Success!');
      console.log('Response structure:', JSON.stringify(data, null, 2).substring(0, 500));

      // Check for image data
      if (data.candidates?.[0]?.content?.parts) {
        const parts = data.candidates[0].content.parts;
        console.log('Parts found:', parts.length);
        parts.forEach((part, i) => {
          if (part.inlineData) {
            console.log(`Part ${i}: Image data (${part.inlineData.data?.length || 0} chars)`);
          } else {
            console.log(`Part ${i}:`, Object.keys(part));
          }
        });
      }
    } else {
      console.error('API Error:', text);
    }
  } catch (error) {
    console.error('Fetch error:', error);
  }
}

testImageGeneration();

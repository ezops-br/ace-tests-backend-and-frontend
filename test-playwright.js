const { chromium } = require('playwright');
const { execSync } = require('child_process');

async function runTests() {
  console.log('🚀 Starting ACE Tests with Playwright');
  console.log('=====================================');

  let browser;
  let page;

  try {
    // Start Docker Compose services
    console.log('📦 Starting Docker Compose services...');
    execSync('docker-compose up -d', { stdio: 'inherit' });
    
    // Wait for services to be ready
    console.log('⏳ Waiting for services to be ready...');
    await new Promise(resolve => setTimeout(resolve, 30000));

    // Launch browser
    console.log('🌐 Launching browser...');
    browser = await chromium.launch({ headless: false });
    page = await browser.newPage();

    // Test Backend API
    console.log('🔍 Testing Backend API...');
    await testBackendAPI(page);

    // Test Frontend
    console.log('🔍 Testing Frontend...');
    await testFrontend(page);

    // Test Database Integration
    console.log('🔍 Testing Database Integration...');
    await testDatabaseIntegration(page);

    console.log('✅ All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
    
    // Clean up Docker Compose
    console.log('🧹 Cleaning up Docker Compose...');
    try {
      execSync('docker-compose down', { stdio: 'inherit' });
    } catch (error) {
      console.log('Warning: Failed to clean up Docker Compose');
    }
  }
}

async function testBackendAPI(page) {
  console.log('  Testing GET /messages...');
  
  // Test GET /messages
  const response = await page.request.get('http://localhost:3000/messages');
  if (response.status() !== 200) {
    throw new Error(`GET /messages failed with status ${response.status()}`);
  }
  
  const messages = await response.json();
  console.log(`  ✅ GET /messages successful - found ${messages.length} messages`);

  // Test POST /messages
  console.log('  Testing POST /messages...');
  const postResponse = await page.request.post('http://localhost:3000/messages', {
    data: { content: 'Hello from Playwright test!' }
  });
  
  if (postResponse.status() !== 201) {
    throw new Error(`POST /messages failed with status ${postResponse.status()}`);
  }
  
  const newMessage = await postResponse.json();
  console.log(`  ✅ POST /messages successful - created message ID ${newMessage.id}`);

  // Test GET /messages/:id
  console.log('  Testing GET /messages/:id...');
  const getByIdResponse = await page.request.get(`http://localhost:3000/messages/${newMessage.id}`);
  
  if (getByIdResponse.status() !== 200) {
    throw new Error(`GET /messages/:id failed with status ${getByIdResponse.status()}`);
  }
  
  const retrievedMessage = await getByIdResponse.json();
  if (retrievedMessage.content !== 'Hello from Playwright test!') {
    throw new Error('Retrieved message content does not match');
  }
  
  console.log('  ✅ GET /messages/:id successful');
}

async function testFrontend(page) {
  console.log('  Testing frontend accessibility...');
  
  // Navigate to frontend
  await page.goto('http://localhost');
  
  // Wait for page to load
  await page.waitForLoadState('networkidle');
  
  // Check if the page title is correct
  const title = await page.title();
  if (title !== 'Ace Tests Frontend') {
    throw new Error(`Expected title "Ace Tests Frontend", got "${title}"`);
  }
  
  console.log('  ✅ Frontend title is correct');
  
  // Check if the header is present
  const header = await page.locator('h1').textContent();
  if (header !== 'Ace Tests Frontend') {
    throw new Error(`Expected header "Ace Tests Frontend", got "${header}"`);
  }
  
  console.log('  ✅ Frontend header is correct');
  
  // Check if the logo is present
  const logo = await page.locator('#logo');
  if (!(await logo.isVisible())) {
    throw new Error('Logo is not visible');
  }
  
  console.log('  ✅ Frontend logo is visible');
  
  // Check if the main content is present
  const mainContent = await page.locator('main p').textContent();
  if (!mainContent.includes('simple frontend scaffold')) {
    throw new Error('Main content is not as expected');
  }
  
  console.log('  ✅ Frontend content is correct');
}

async function testDatabaseIntegration(page) {
  console.log('  Testing database integration...');
  
  // Create a test message
  const testMessage = `Playwright test message - ${Date.now()}`;
  const postResponse = await page.request.post('http://localhost:3000/messages', {
    data: { content: testMessage }
  });
  
  if (postResponse.status() !== 201) {
    throw new Error(`Failed to create test message: ${postResponse.status()}`);
  }
  
  const createdMessage = await postResponse.json();
  console.log(`  ✅ Created test message with ID ${createdMessage.id}`);
  
  // Verify the message was stored in database
  const getResponse = await page.request.get('http://localhost:3000/messages');
  const allMessages = await getResponse.json();
  
  const foundMessage = allMessages.find(msg => msg.content === testMessage);
  if (!foundMessage) {
    throw new Error('Test message not found in database');
  }
  
  console.log('  ✅ Message successfully stored in database');
  
  // Test message retrieval by ID
  const getByIdResponse = await page.request.get(`http://localhost:3000/messages/${createdMessage.id}`);
  const retrievedMessage = await getByIdResponse.json();
  
  if (retrievedMessage.content !== testMessage) {
    throw new Error('Retrieved message content does not match stored content');
  }
  
  console.log('  ✅ Message retrieval by ID works correctly');
}

// Run the tests
runTests().catch(console.error);

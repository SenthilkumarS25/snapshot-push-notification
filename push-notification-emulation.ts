import express from 'express';
import puppeteer from 'puppeteer';
import path from 'path';

const app = express();

// Serve the HTML page that simulates the mobile notification
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Capture a screenshot of the simulated notification
app.get('/screenshot', async (req, res) => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Load the page with the simulated notification
    await page.goto('http://localhost:3000');

    // Set the viewport to mimic a mobile device
    await page.setViewport({ width: 375, height: 667 });

    // Capture the screenshot
    const screenshotBuffer = await page.screenshot({ fullPage: true });

    await browser.close();

    // Send the screenshot as a response
    res.setHeader('Content-Type', 'image/png');
    res.send(screenshotBuffer);
});

// Start the server
const port = 3000;
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});

import express from 'express';
import puppeteer from 'puppeteer';
import path from 'path';

const app = express();

// Serve the HTML page with dynamic content
app.get('/screenshot', async (req, res) => {
    const { title = 'New Message', body = 'You have a new message.' } = req.query;

    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Load the page with the simulated notification
    await page.goto(`http://localhost:3000/notification?title=${encodeURIComponent(title as string)}&body=${encodeURIComponent(body as string)}`);

    // Set the viewport to mimic a mobile device
    await page.setViewport({ width: 375, height: 667 });

    // Capture the screenshot
    const screenshotBuffer = await page.screenshot({ fullPage: true });

    await browser.close();

    // Send the screenshot as a response
    res.setHeader('Content-Type', 'image/png');
    res.send(screenshotBuffer);
});

// Serve the dynamic notification HTML
app.get('/notification', (req, res) => {
    const { title = 'New Message', body = 'You have a new message.' } = req.query;
    
    res.send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Push Notification Simulator</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background-image: url('https://example.com/mobile-background.png'); /* Replace with the URL of your mobile background image */
                    background-size: cover;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                }
                .notification {
                    width: 300px;
                    padding: 20px;
                    background-color: white;
                    box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.1);
                    border-radius: 10px;
                    text-align: center;
                }
                .notification h2 {
                    margin: 0 0 10px;
                    font-size: 18px;
                }
                .notification p {
                    margin: 0;
                    font-size: 14px;
                    color: #555;
                }
            </style>
        </head>
        <body>
            <div class="notification">
                <h2>${title}</h2>
                <p>${body}</p>
            </div>
        </body>
        </html>
    `);
});

// Start the server
const port = 3000;
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});

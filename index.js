const express = require('express');
const { exec } = require('child_process');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
const port = 3000;

app.use(bodyParser.json());

app.post('/screenshot', (req, res) => {
    const { message } = req.body;

    if (!message) {
        return res.status(400).send('Message is required');
    }

    // Command to send a push notification (using ADB shell command)
    const pushNotification = `adb shell am broadcast -a com.example.yourapp.ACTION -e message "${message}"`;

    // Command to take a screenshot
    const takeScreenshot = `adb exec-out screencap -p > ./screenshot.png`;

    exec(pushNotification, (pushErr) => {
        if (pushErr) {
            console.error(`Error sending notification: ${pushErr}`);
            return res.status(500).send('Error sending notification');
        }

        exec(takeScreenshot, (screenshotErr) => {
            if (screenshotErr) {
                console.error(`Error taking screenshot: ${screenshotErr}`);
                return res.status(500).send('Error taking screenshot');
            }

            // Read the screenshot file and send it as the response
            res.sendFile(path.resolve(__dirname, 'screenshot.png'));
        });
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});

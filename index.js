const express = require('express');
const { exec } = require('child_process');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

app.use(bodyParser.json());

app.post('/screenshot', (req, res) => {
    const { device, message } = req.body;

    if (!device || !message) {
        return res.status(400).send('Device and message are required');
    }

    // Command to boot the iOS simulator
    const bootSimulator = `xcrun simctl boot "${device}"`;

    // Command to send a push notification
    const pushNotification = `xcrun simctl push "${device}" com.your.bundle.id ./path/to/payload.apns`;

    // Command to take a screenshot
    const takeScreenshot = `xcrun simctl io "${device}" screenshot ./screenshot.png`;

    exec(bootSimulator, (bootErr) => {
        if (bootErr) {
            console.error(`Error booting simulator: ${bootErr}`);
            return res.status(500).send('Error booting simulator');
        }

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
                res.sendFile(__dirname + '/screenshot.png');
            });
        });
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});

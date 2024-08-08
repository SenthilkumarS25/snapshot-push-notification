const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.post('/screenshot', (req, res) => {
    const { notification } = req.body;
    
    // Command to simulate push notification (this is a placeholder, you need to replace with actual command)
    const pushNotificationCommand = `adb shell am broadcast -a com.example.pushnotification -e message "${notification}"`;

    exec(pushNotificationCommand, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error pushing notification: ${error}`);
            return res.status(500).send('Failed to push notification');
        }

        // Command to capture the screenshot
        const screenshotPath = path.join(__dirname, 'screenshot.png');
        const captureCommand = `adb exec-out screencap -p > ${screenshotPath}`;

        exec(captureCommand, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error capturing screenshot: ${error}`);
                return res.status(500).send('Failed to capture screenshot');
            }

            res.sendFile(screenshotPath);
        });
    });
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

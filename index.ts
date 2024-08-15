import express from 'express';
import wd from 'wd';
import * as fs from 'fs';

const app = express();
const port = 3000;

app.use(express.json());

app.post('/capture-notification', async (req, res) => {
    const { title, body } = req.body;

    if (!title || !body) {
        return res.status(400).send('Title and body are required');
    }

    const caps = {
        platformName: "Android",
        deviceName: "emulator-5554", // Use the correct emulator device name
        appPackage: "com.example.app", // Replace with your app's package name
        appActivity: ".MainActivity",  // Replace with your app's main activity
        automationName: "UiAutomator2"
    };

    const driver = wd.promiseChainRemote("http://localhost:4723/wd/hub");

    try {
        await driver.init(caps);

        // Simulate sending a push notification
        await driver.execute("mobile: pushNotification", {
            packageName: "com.example.app",
            data: {
                title: title,
                body: body
            }
        });

        await driver.sleep(5000);

        const screenshot = await driver.takeScreenshot();
        const screenshotPath = `screenshot-${Date.now()}.png`;
        fs.writeFileSync(screenshotPath, screenshot, "base64");

        console.log("Screenshot saved as", screenshotPath);
        res.sendFile(screenshotPath);

    } catch (err) {
        console.error("Error:", err);
        res.status(500).send('Failed to capture screenshot');
    } finally {
        await driver.quit();
    }
});

app.listen(port, () => {
    console.log(`Service is running on port ${port}`);
});

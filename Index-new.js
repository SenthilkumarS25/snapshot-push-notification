const express = require('express');
const { Canvas, Image } = require('canvas');
import tw from 'twin.macro';

const app = express();

function generateNotification(platform, notificationData) {
  const canvas = new Canvas(360, 100);
  const ctx = canvas.getContext('2d');

  // Load the background image
  const backgroundImage = new Image();
  backgroundImage.src = 'path/to/your/background.png'; // Replace with your image path

  // Render the background image
  backgroundImage.onload = () => {
    ctx.drawImage(backgroundImage, 0, 0, canvas.width, canvas.height);

    // Platform-specific elements
    if (platform === 'android') {
      // Android-specific styles
      ctx.font = '14px Roboto';
      // ... other Android-specific elements
    } else if (platform === 'ios') {
      // iOS-specific styles
      ctx.font = '16px San Francisco';
      // ... other iOS-specific elements
    }

    // Render notification content
    ctx.fillText(notificationData.title, 10, 30);
    ctx.fillText(notificationData.body, 10, 55);

    // ... (add code to render icon, actions, etc.)

    // Scale the canvas for high-density displays
    ctx.scale(devicePixelRatio, devicePixelRatio);

    const buffer = canvas.toBuffer('image/png');
    return buffer;
  };
}

app.get('/screenshot', (req, res) => {
  const platform = req.query.platform || 'android'; // Default to Android
  const notificationData = {
    title: 'New Message',
    body: 'You have a new message.',
    iconUrl: 'path/to/your/app_icon.png'
  };

  const devicePixelRatio = 2.5; // Adjust for your target device

  generateNotification(platform, notificationData, devicePixelRatio)
    .then(imageBuffer => {
      res.set('Content-Type', 'image/png');
      res.send(imageBuffer);
    })
    .catch(error => {
      console.error('Error generating notification:', error);
      res.status(500).send('Error generating notification');
    });
});

app.listen(3000, () => {
  console.log('Server listening on port 3000');
});

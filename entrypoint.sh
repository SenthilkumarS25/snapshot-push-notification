#!/bin/bash

# Start the emulator
$ANDROID_SDK_ROOT/emulator/emulator @test -no-skin -no-audio -no-window &

# Wait for the emulator to start
adb wait-for-device

# Start the Node.js service
node /app/index.js

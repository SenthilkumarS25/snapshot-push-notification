# Use an official Amazon Corretto Ubuntu image
FROM amazoncorretto:8

# Enable multiarch support and install necessary packages
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    wget \
    unzip \
    tar \
    curl \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    zlib1g:i386

# Install additional packages and setup SDK as before
# Download and install Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O /tmp/cmdline-tools.zip && \
    mkdir -p /opt/android-sdk/cmdline-tools && \
    unzip /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools && \
    rm /tmp/cmdline-tools.zip && \
    mv /opt/android-sdk/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/tools

# Set environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin

# Accept licenses and install required packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "emulator" "system-images;android-30;google_apis;x86_64"

# Create and start an Android Virtual Device (AVD)
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64"

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy app source code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Start the Android emulator and Node.js server
CMD ${ANDROID_SDK_ROOT}/emulator/emulator -avd test -no-snapshot-save -no-audio -no-window & \
    adb wait-for-device && \
    node index.js

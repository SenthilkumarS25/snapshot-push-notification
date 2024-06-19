# Use an official OpenJDK runtime as a parent image
FROM openjdk:8

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget unzip tar curl lib32stdc++6 lib32z1

# Set environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/platform-tools

# Download and install Android SDK
RUN wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O /tmp/sdk-tools-linux.zip && \
    mkdir -p ${ANDROID_SDK_ROOT} && \
    unzip /tmp/sdk-tools-linux.zip -d ${ANDROID_SDK_ROOT} && \
    rm /tmp/sdk-tools-linux.zip

# Accept licenses
RUN yes | sdkmanager --licenses

# Install specific tools and system images
RUN sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "emulator" "system-images;android-30;google_apis;x86_64"

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

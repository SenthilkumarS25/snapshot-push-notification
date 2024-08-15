# Use Amazon Corretto as the base image
FROM amazoncorretto:11

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common

# Add the i386 architecture
RUN dpkg --add-architecture i386

# Update again to fetch i386 packages
RUN apt-get update && \
    apt-get install -y \
    libc6-i386 \
    lib32stdc++6 \
    lib32z1 \
    libncurses5:i386 \
    libstdc++6:i386 \
    libz1:i386 \
    zlib1g:i386 \
    wget \
    unzip \
    libx11-6 \
    libxrender1 \
    libxrandr2 \
    libxcursor1 \
    libxinerama1 \
    libxi6 \
    qemu-kvm \
    sudo \
    && apt-get clean

# Set up environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$PATH"

# Install Android SDK tools and emulator
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    rm /tmp/cmdline-tools.zip && \
    yes | $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager --licenses && \
    $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_SDK_ROOT "platform-tools" "emulator" "platforms;android-30" "system-images;android-30;google_apis;x86_64"

# Create and configure the emulator
RUN echo "no" | $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin/avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64" -d pixel && \
    echo "hw.cpu.ncore=2" >> $ANDROID_SDK_ROOT/.android/avd/test.avd/config.ini

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs

# Copy your appium server and node app
WORKDIR /usr/src/app
COPY . .

# Install Node.js dependencies
RUN npm install

# Expose necessary ports
EXPOSE 4723

# Start the emulator and Appium
CMD $ANDROID_SDK_ROOT/emulator/emulator -avd test -no-window -gpu off -no-audio & \
    adb wait-for-device && \
    node index.js

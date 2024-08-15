# Use Amazon Corretto as the base image
FROM amazoncorretto:11

# Install dependencies
RUN yum update -y && \
    yum install -y \
    glibc.i686 \
    libstdc++ libstdc++.i686 \
    zlib.i686 \
    ncurses-compat-libs \
    wget \
    unzip \
    libX11 \
    libXrender \
    libXrandr \
    libXcursor \
    libXinerama \
    libXi \
    qemu-kvm \
    sudo \
    && yum clean all

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
RUN curl -fsSL https://rpm.nodesource.com/setup_14.x | sudo bash - && \
    yum install -y nodejs

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

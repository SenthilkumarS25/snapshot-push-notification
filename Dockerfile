# Use Amazon Corretto as a base image
FROM amazoncorretto:11

# Set environment variables for non-interactive installs and paths
ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    gnupg \
    unzip \
    libc6-i386 \
    lib32stdc++6 \
    lib32z1 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Download and install Android SDK command-line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip \
    && unzip tools.zip -d latest \
    && rm tools.zip

# Ensure sdkmanager is executable
RUN chmod +x $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager

# Accept the licenses
RUN yes | sdkmanager --licenses

# Update SDK manager and install required SDK packages
RUN sdkmanager --update \
    && sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "emulator" "system-images;android-30;google_apis;x86_64"

# Create and start the emulator
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;google_apis;x86_64"
RUN $ANDROID_SDK_ROOT/emulator/emulator @test -no-skin -no-audio -no-window &

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy the application files
COPY . /app
WORKDIR /app

# Install Node.js dependencies
RUN npm install

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define the entry point
ENTRYPOINT ["/entrypoint.sh"]

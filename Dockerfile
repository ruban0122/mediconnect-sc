FROM debian:bullseye-slim AS build-env

# Install required dependencies
RUN apt-get update && apt-get install -y \
  curl file git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget && \
  rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME=/flutter
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME
ENV PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

# Install Android SDK command line tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV CMDLINE_TOOLS_VERSION=10406996
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
  cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip -O cmdline-tools.zip && \
  unzip cmdline-tools.zip && \
  mv cmdline-tools latest && \
  rm cmdline-tools.zip

# Update SDK & install build tools + platform tools + platforms
ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
RUN sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Set environment variables
ENV PATH="${ANDROID_SDK_ROOT}/build-tools/35.0.0:${PATH}"

# Configure Flutter to use Android SDK
RUN flutter doctor --android-licenses
RUN flutter doctor

# Build stage
WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build apk --release


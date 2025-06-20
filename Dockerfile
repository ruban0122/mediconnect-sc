# Use Flutter official image
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy everything into the container
COPY . .

# Install dependencies
RUN flutter pub get

# Build APK
RUN flutter build apk --release

# Optional: this is not for running, just for build output
CMD ["echo", "Flutter build completed."]

# Use a Flutter image with Dart 3.5.4+ (Flutter 3.22+)
FROM cirrusci/flutter:latest

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Install dependencies
RUN flutter pub get

# Build APK
RUN flutter build apk --release

CMD ["echo", "Flutter build completed."]

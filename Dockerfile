# Dockerfile (option 1 - package only)
FROM debian:bullseye-slim

# Set working directory
WORKDIR /app

# Copy release APK into image
COPY ci_output/app-release.apk .

# Optionally expose the APK path or define CMD if running container
CMD ["echo", "APK copied into image. Use docker cp to extract."]


# ============================
# Stage 1: Build Flutter Web
# ============================
FROM cirrusci/flutter:latest AS build

WORKDIR /app

# Copy project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build the Flutter web app
RUN flutter build web


# =============================
# Stage 2: Serve with Nginx
# =============================
FROM nginx:alpine

# Remove default nginx config
RUN rm -rf /usr/share/nginx/html/*

# Copy built web app to Nginx's web directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

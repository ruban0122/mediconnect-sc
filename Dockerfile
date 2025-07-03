# =============================
# Stage 1: Flutter Web Builder
# =============================
FROM cirrusci/flutter:latest AS build

WORKDIR /app

# Copy Flutter project files into container
COPY . .

# Get dependencies
RUN flutter pub get

# Build Flutter web
RUN flutter build web

# ==========================
# Stage 2: Web Server Layer
# ==========================
FROM nginx:alpine

# Remove default nginx config
RUN rm -rf /usr/share/nginx/html/*

# Copy built web app from stage 1 to nginx html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"]

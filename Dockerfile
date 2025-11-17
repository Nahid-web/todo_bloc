# Stage 1: Build the Flutter web application
# We use a stable Flutter image from ghcr.io (GitHub Container Registry).
FROM ghcr.io/cirruslabs/flutter:stable AS builder

# Set the working directory inside the container.
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock first to leverage Docker's layer caching.
# This step is only re-run when these files change, speeding up subsequent builds.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the project files into the container.
COPY . .

# Build the Flutter web application in release mode.
# The output will be in the /app/build/web directory.
RUN flutter build web --release

# Stage 2: Serve the web application using Nginx
# We use a lightweight nginx image based on Alpine Linux.
FROM nginx:alpine

# Copy the built web app from the 'builder' stage to the nginx public directory.
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80 to allow traffic to the web server.
EXPOSE 80

# Start nginx when the container launches.
CMD ["nginx", "-g", "daemon off;"]
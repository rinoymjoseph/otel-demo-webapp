# Stage 1: Build the React app
FROM registry.access.redhat.com/ubi9/nodejs-18-minimal AS build

# Set work directory
WORKDIR /app

# Copy package files and set permissions
COPY --chown=1001:0 package.json package-lock.json ./

# Ensure appropriate permissions
RUN chmod 664 package.json package-lock.json

# Install dependencies as non-root user (default in ubi minimal images)
USER 1001
RUN npm install --legacy-peer-deps

# Copy the rest of the app source code
COPY --chown=1001:0 . ./

# Build the app
RUN npm run build

# Stage 2: Serve the app with Apache HTTPD
FROM registry.access.redhat.com/ubi9/httpd-24:1-336.1729775640

# Copy the build output from the first stage
COPY --from=build /app/build /var/www/html

# Expose the default HTTP port
EXPOSE 8080

# Start the Apache HTTP server
CMD ["httpd", "-D", "FOREGROUND"]
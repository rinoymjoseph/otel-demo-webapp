# Stage 1: Build the React app
FROM registry.access.redhat.com/ubi9/nodejs-18-minimal AS build

# Set work directory
WORKDIR /app

# Ensure permissions for the /app directory
RUN chown -R 1001:0 /app && chmod -R 775 /app

# Switch to a non-root user (default user for ubi minimal images)
USER 1001

# Install dependencies
COPY package.json package-lock.json ./
RUN npm install --legacy-peer-deps

# Copy the rest of the app source code
COPY . ./

# Build the app
RUN npm run build

# Stage 2: Serve the app with Apache HTTPD
FROM registry.access.redhat.com/ubi9/httpd-24-minimal

# Copy the build output from the first stage
COPY --from=build /app/build /var/www/html

# Expose the default HTTP port
EXPOSE 8080

# Start the Apache HTTP server
CMD ["httpd", "-D", "FOREGROUND"]
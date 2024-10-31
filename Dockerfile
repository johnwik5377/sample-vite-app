# Use an official Node.js runtime as a parent image
FROM node:16

# Install Tor
RUN apt-get update && apt-get install -y tor

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the Vite project
RUN npm run build

# Create a directory for Tor hidden services
RUN mkdir -p /var/lib/tor/hidden_service && \
    chown -R debian-tor:debian-tor /var/lib/tor/hidden_service

# Configure Tor to map the hidden service to the Vite port
RUN echo "HiddenServiceDir /var/lib/tor/hidden_service/\nHiddenServicePort 80 127.0.0.1:5173" >> /etc/tor/torrc

# Add a script to log the onion URL
RUN echo '#!/bin/bash\n\
# Wait for Tor to start\n\
sleep 5\n\
\n\
# Read the onion URL from the hostname file\n\
ONION_URL=$(cat /var/lib/tor/hidden_service/hostname)\n\
\n\
# Log the URL\n\
echo "Onion URL: $ONION_URL"\n' > /get_onion_url.sh && chmod +x /get_onion_url.sh

# Start Tor and the Vite preview server
CMD ["sh", "-c", "service tor start && npm run preview -- --host 0.0.0.0 --port 5173 & /get_onion_url.sh"]

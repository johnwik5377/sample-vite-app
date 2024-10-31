# Use an official Node.js runtime as a parent image
FROM node:16

# Install Tor and gosu
RUN apt-get update && apt-get install -y tor gosu

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
    chown -R debian-tor:debian-tor /var/lib/tor/hidden_service && \
    chmod 700 /var/lib/tor/hidden_service 

# Configure Tor to map the hidden service to the Vite port
RUN echo "HiddenServiceDir /var/lib/tor/hidden_service/\nHiddenServicePort 80 127.0.0.1:5173" >> /etc/tor/torrc 

# Add a script to log the onion URL
RUN echo '#!/bin/bash\n\
# Start Tor as debian-tor\n\
gosu debian-tor tor &\n\
\n\
# Wait for Tor to establish the hidden service\n\
sleep 10\n\
\n\
# Read the onion URL from the hostname file\n\
ONION_URL=$(cat /var/lib/tor/hidden_service/hostname)\n\
\n\
# Log the URL\n\
echo "Onion URL: $ONION_URL"\n' > /get_onion_url.sh && chmod +x /get_onion_url.sh

# Start both Tor and the Vite preview server
CMD ["sh", "-c", "/get_onion_url.sh && npm run preview -- --host 0.0.0.0 --port 5173"]

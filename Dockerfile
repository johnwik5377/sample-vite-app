FROM node:16

# Install Tor
RUN apt-get update && apt-get install -y tor

# Create the directory for the hidden service
RUN mkdir -p /var/lib/tor/hidden_service && \
    chown -R debian-tor:debian-tor /var/lib/tor/hidden_service && \
    chmod 700 /var/lib/tor/hidden_service

# Copy your application code
WORKDIR /app
COPY . .

# Install dependencies
RUN npm install

# Build your Vite application
RUN npm run build

# Expose the port your app will run on
EXPOSE 5173

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Start the entrypoint script
CMD ["sh", "/usr/local/bin/entrypoint.sh"]

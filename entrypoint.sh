#!/bin/sh

# Start Tor in the background
service tor start

# Start the Vite application
npm run preview --host 0.0.0.0 --port 5173

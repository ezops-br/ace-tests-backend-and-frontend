# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Install app dependencies
# A wildcard is used to ensure both package.json and package-lock.json are copied when available
COPY package*.json ./

# Install only production dependencies to keep the image small
RUN npm install --production --silent

# Bundle app source
COPY . .

# Set environment for production
ENV NODE_ENV=production
ENV PORT=3000

# Use a non-root user for security (node user exists in official Node images)
USER node

# Expose the port the app runs on
EXPOSE 3000

# Start the app
CMD ["npm", "start"]

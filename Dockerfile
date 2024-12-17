# Build environment
FROM node:16-alpine as builder

# Install necessary build dependencies
RUN apk add --no-cache bash python3 make g++

# Set up application directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Set environment path
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# Disable strict SSL for npm to bypass the self-signed certificate issue
RUN npm config set strict-ssl false

# Copy package.json and install dependencies
COPY package.json /usr/src/app/package.json

# Clean npm cache and install dependencies
RUN npm cache clean --force
RUN npm install

# Install react-scripts globally
RUN npm install react-scripts@1.1.1 -g --silent

# Copy the rest of the application
COPY . /usr/src/app

# Build the application
RUN npm run build

# Production environment
FROM nginx:1.13.9-alpine

# Copy build from builder stage to NGINX container
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# Expose port 80 for the container
EXPOSE 8080

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]

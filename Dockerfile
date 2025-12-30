# --- STEP 1: Build the React app ---
FROM node:20-alpine AS build-stage
WORKDIR /app

# Accept the API Key from Google Cloud Build
ARG GEMINI_API_KEY
ENV VITE_GEMINI_API_KEY=$GEMINI_API_KEY

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all your project files
COPY . .

# Create the .env.local file so Vite sees the key during build
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Run the build (This creates the 'dist' folder)
RUN npm run build

# --- STEP 2: Serve the app with Nginx ---
FROM nginx:alpine

# Copy our custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output from the build-stage
# Vite always puts the final website in 'dist'
COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

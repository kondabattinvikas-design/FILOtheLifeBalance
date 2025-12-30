# --- STEP 1: Build Stage ---
FROM node:20-alpine AS build-stage

# Set the working directory
WORKDIR /app

# Copy package files first (helps with faster building)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of your code
COPY . .

# Set up the API Key
# We use a default value "missing" so the build doesn't crash if the key is empty
ARG GEMINI_API_KEY=missing
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Build the project
RUN npm run build

# --- STEP 2: Serve Stage ---
FROM nginx:alpine

# Copy our custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the build output (dist folder) to Nginx
# Note: Vite always outputs to 'dist'. 
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Cloud Run uses port 8080
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

# STEP 1: Build the React app
FROM node:20-alpine AS build-stage
WORKDIR /app

# Accept the API Key
ARG GEMINI_API_KEY
ENV VITE_GEMINI_API_KEY=$GEMINI_API_KEY

COPY package*.json ./
RUN npm install
COPY . .

# Create the .env file for Vite
RUN echo "VITE_GEMINI_API_KEY=${GEMINI_API_KEY}" > .env.local

# Build the app
RUN npm run build

# STEP 2: Serve with Nginx
FROM nginx:alpine

# --- FIX: We create the nginx config directly inside the Dockerfile ---
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Copy the build output (dist folder)
COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

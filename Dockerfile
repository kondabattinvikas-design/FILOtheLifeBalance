# Step 1: Build the React app
FROM node:20-alpine AS build-stage
WORKDIR /app

# Accept the API Key as a build argument
ARG GEMINI_API_KEY="temporary_key_for_build

COPY package*.json ./
RUN npm install

COPY . .

# Write the API Key to .env.local before building
# Note: If you use this key in your React code, it should be VITE_GEMINI_API_KEY
RUN echo "VITE_GEMINI_API_KEY=$GEMINI_API_KEY" > .env.local

RUN npm run build

# Step 2: Serve the app using Nginx
FROM nginx:alpine
# Copy the custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the build output from the first stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

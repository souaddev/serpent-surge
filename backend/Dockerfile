FROM node:alpine

WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl 

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
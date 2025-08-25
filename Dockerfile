FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production || npm install
COPY . .
ENV PORT=3000
EXPOSE 3000
CMD ["sh","-c","${START_CMD}"]

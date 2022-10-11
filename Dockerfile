FROM node:14-alpine

WORKDIR /app

COPY package.json .
COPY package-lock.json .

RUN npm install

COPY . .

RUN npm run build --production

RUN npm install -g serve

CMD [ "serve", "-s", "build" ]
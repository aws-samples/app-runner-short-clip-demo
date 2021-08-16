FROM node:12.22.4-stretch-slim

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY ./index.js ./

CMD [ "node", "index.js" ]

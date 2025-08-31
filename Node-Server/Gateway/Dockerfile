FROM mcr.microsoft.com/devcontainers/typescript-node

WORKDIR /Utils
COPY Utils/ .

WORKDIR /App

COPY Gateway/package*.json .
COPY Gateway/tsconfig.json .
COPY Gateway/src .

RUN npm install

CMD ["npm", "run", "start"]
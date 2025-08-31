FROM mcr.microsoft.com/devcontainers/typescript-node

WORKDIR /Utils
COPY Utils/ .

WORKDIR /App

COPY Registry/package*.json .
COPY Registry/tsconfig.json .
COPY Registry/src .

RUN npm install

CMD ["npm", "run", "start"]
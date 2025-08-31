FROM mcr.microsoft.com/devcontainers/typescript-node

WORKDIR /Utils
COPY Utils/ .

WORKDIR /App

COPY Database/package*.json .
COPY Database/tsconfig.json .
COPY Database/src .

RUN npm install

CMD ["npm", "run", "start"]
FROM mcr.microsoft.com/devcontainers/typescript-node

WORKDIR /Utils
COPY Utils/ .

WORKDIR /App

COPY Logic/package*.json .
COPY Logic/tsconfig.json .
COPY Logic/src .

RUN npm install

CMD ["npm", "run", "start"]
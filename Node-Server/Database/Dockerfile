FROM mcr.microsoft.com/devcontainers/typescript-node

COPY package*.json .
COPY tsconfig.json .
COPY src .

RUN npm install

CMD ["npm", "run", "start"]
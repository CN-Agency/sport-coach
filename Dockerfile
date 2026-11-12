FROM node:26.12.1-alpine AS builder
RUN npm install -g npm@11

WORKDIR /app

COPY package.json ./
RUN npm i

COPY . .
RUN npm run build


FROM node:26.12.1-alpine AS runner
RUN npm install -g npm@11
RUN npm install -g serve@14.2.6

WORKDIR /app

ENV NO_UPDATE_CHECK=1

COPY serve.json ./
COPY --from=builder /app/dist ./dist

USER node

EXPOSE 8000

CMD ["serve", "dist", "--config", "/app/serve.json", "--listen", "8000", "--no-clipboard", "--no-request-logging"]

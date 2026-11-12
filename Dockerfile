FROM node:26.12.1-alpine AS builder
RUN npm install -g npm@11

WORKDIR /app

COPY package.json ./
RUN npm i

COPY . .
RUN npm run build


FROM node:26.12.1-alpine AS runner
RUN npm install -g npm@11

# serve@14.2.x pins compression to exactly 1.8.1 (CVE-2026-87776, fixed in 1.8.2) and npm
# overrides are ignored by `npm install -g`, hence a local install. Drop the override once
# serve ships with compression >= 1.8.2.
# The wrapper package.json must not be named "serve": image scanners read it as an ancient
# serve@1.0.0 and report every serve CVE prior to 10.1.2.
WORKDIR /opt/serve
RUN printf '%s' '{"name":"sport-runtime","private":true,"overrides":{"compression":"1.8.2"}}' > package.json \
	&& npm install --omit=dev --no-fund --no-audit serve@14.2.6 \
	&& npm cache clean --force
ENV PATH=/opt/serve/node_modules/.bin:$PATH

WORKDIR /app

ENV NO_UPDATE_CHECK=1

COPY serve.json ./
COPY --from=builder /app/dist ./dist

USER node

EXPOSE 8000

CMD ["serve", "dist", "--config", "/app/serve.json", "--listen", "8000", "--no-clipboard", "--no-request-logging"]

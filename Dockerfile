FROM node:20-alpine

# Configure the repositories for the correct Alpine version
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/v3.13/community" >> /etc/apk/repositories

# Install Chrome and tini
USER root
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto-emoji \
    tini
   # wqy-zenhei # pacote nao encontrado no APK. Se for necessário temos que achar um substituto

COPY local.conf /etc/fonts/local.conf

# Playwright
ENV CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/ \
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# App
RUN mkdir -p /app && chown -R node:node /app
WORKDIR /app
USER node

COPY --chown=node package.json package-lock.json ./
RUN npm i
COPY --chown=node  ./ ./

ENTRYPOINT ["tini", "--"]
CMD [ "node", "index.js" ]

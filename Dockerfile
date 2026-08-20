# Use OpenClaw's official release image rather than rebuilding it from mutable
# Git and package-manager inputs. The amd64 digest makes the deployed bytes
# immutable even if the version tag is ever moved.
FROM ghcr.io/openclaw/openclaw:2026.7.1@sha256:165b4992f1b4b74ffdd7a02c887ba006f9f5dc951eca420eef573a8b233b543f

USER root
WORKDIR /wrapper

# npm ci enforces the reviewed lockfile. Lifecycle scripts are unnecessary for
# this small wrapper and are disabled to reduce supply-chain exposure.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts \
  && npm cache clean --force

COPY --chown=node:node src ./src

# Seed an empty Railway volume with non-root ownership.
RUN install -d -m 0700 -o node -g node \
      /data \
      /data/.openclaw \
      /data/workspace

ENV NODE_ENV=production \
    OPENCLAW_ENTRY=/app/openclaw.mjs \
    OPENCLAW_NODE=node \
    OPENCLAW_STATE_DIR=/data/.openclaw \
    OPENCLAW_WORKSPACE_DIR=/data/workspace \
    OPENCLAW_DISABLE_BONJOUR=1

EXPOSE 8080

# Railway volumes are mounted root-owned. The bootstrap performs the minimal
# ownership fix required for /data, then permanently drops to the node user
# before importing the wrapper server.
USER root
ENTRYPOINT ["tini", "-s", "--"]
CMD ["node", "/wrapper/src/bootstrap.js"]

# syntax=docker/dockerfile:1.3
FROM node:22.21.1@sha256:3f2d9ba6fd4c85d101624e10080b51eca5e14f9ef2327b27a6ceb63fc22894d2
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupmod -g "${GROUP_ID}" node && usermod -u "${USER_ID}" -g "${GROUP_ID}" node
USER node
WORKDIR /app

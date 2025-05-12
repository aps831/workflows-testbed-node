# syntax=docker/dockerfile:1.3
FROM node:22.15.0@sha256:3806a879a4e284e2960445f8316f4a92df8e502b5d4175056eff7b7752f5f23c
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupmod -g "${GROUP_ID}" node && usermod -u "${USER_ID}" -g "${GROUP_ID}" node
USER node
WORKDIR /app

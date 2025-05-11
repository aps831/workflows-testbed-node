# syntax=docker/dockerfile:1.3
FROM node:20.9.0@sha256:cb7cd40ba6483f37f791e1aace576df449fc5f75332c19ff59e2c6064797160e AS build
USER node
WORKDIR /app

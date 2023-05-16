# syntax=docker/dockerfile:1.3
FROM node:20.1.0@sha256:0efc3ef3fea2822c9d16da084c40181ed7f74b6f45141100580f9887ccc8e9a1 AS build
USER node
WORKDIR /app
COPY --chown=node:node . /app
RUN --mount=type=cache,uid=1000,gid=1000,target=/home/node/.npm \
    --mount=type=cache,uid=1000,gid=1000,target=/home/node/.cache \
    echo "0" > EXIT_STATUS_FILE_0 && \
    echo "0" > EXIT_STATUS_FILE_1 && \
    echo "0" > EXIT_STATUS_FILE_2 && \
    echo "0" > EXIT_STATUS_FILE_3 && \
    (rm -rf checks && mkdir checks) && \
    (rm -rf coverage && mkdir coverage) && \
    (rm -rf dist && mkdir dist) && \
    (npm ci || echo $? > EXIT_STATUS_FILE_0) && \
    (npm audit --omit=dev > checks/audit.txt || true) && \
    (npm_config_yes=true npx depcheck > checks/depcheck.txt || true) && \
    (npm run test:unit:once || echo $? > EXIT_STATUS_FILE_1) && \
    (npm run build || echo $? > EXIT_STATUS_FILE_2) && \
    (npm run test:integration:headless || echo $? > EXIT_STATUS_FILE_3)

FROM scratch AS output
COPY --from=build /app/checks/ /checks
COPY --from=build /app/coverage/ /coverage
COPY --from=build /app/dist/ /dist

FROM alpine:3.14 AS status
COPY --from=build /app/EXIT_STATUS_FILE_0/ /EXIT_STATUS_FILE_0
COPY --from=build /app/EXIT_STATUS_FILE_1/ /EXIT_STATUS_FILE_1
COPY --from=build /app/EXIT_STATUS_FILE_2/ /EXIT_STATUS_FILE_2
COPY --from=build /app/EXIT_STATUS_FILE_3/ /EXIT_STATUS_FILE_3
RUN exit "$(cat /EXIT_STATUS_FILE_0)"
RUN exit "$(cat /EXIT_STATUS_FILE_1)"
RUN exit "$(cat /EXIT_STATUS_FILE_2)"
RUN exit "$(cat /EXIT_STATUS_FILE_3)"

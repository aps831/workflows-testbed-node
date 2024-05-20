# syntax=docker/dockerfile:1.3
FROM node:22.2.0@sha256:a8ba58f54e770a0f910ec36d25f8a4f1670e741a58c2e6358b2c30b575c84263 AS build
USER node
WORKDIR /app
COPY --chown=node:node . /app
RUN --mount=type=cache,uid=1000,gid=1000,target=/home/node/.npm \
    --mount=type=cache,uid=1000,gid=1000,target=/home/node/.cache \
    echo "0" > EXIT_STATUS_FILE_0 && \
    echo "0" > EXIT_STATUS_FILE_1 && \
    echo "0" > EXIT_STATUS_FILE_2 && \
    echo "0" > EXIT_STATUS_FILE_3 && \
    (rm -rf outputs && rm -rf dist) && \
    (mkdir -p outputs/checks) && \
    (mkdir -p outputs/coverage) && \
    (mkdir -p outputs/sbom) && \
    (mkdir dist) && \
    (npm ci || echo $? > EXIT_STATUS_FILE_0) && \
    (npm audit --omit=dev > outputs/checks/audit.txt || true) && \
    (npm_config_yes=true npx depcheck > outputs/checks/depcheck.txt || true) && \
    (npm_config_yes=true npx @cyclonedx/cyclonedx-npm --output-file outputs/sbom/cyclonedx.json || true) && \
    (npm run-script test:unit:once || echo $? > EXIT_STATUS_FILE_1) && \
    (npm run-script build || echo $? > EXIT_STATUS_FILE_2) && \
    (npm run-script test:integration:headless || echo $? > EXIT_STATUS_FILE_3)

FROM scratch AS output
COPY --from=build /app/outputs/checks/ /outputs/checks
COPY --from=build /app/outputs/unit-tests/ /outputs/unit-tests
COPY --from=build /app/outputs/coverage/ /outputs/coverage
COPY --from=build /app/outputs/integration-tests/ /outputs/integration-tests
COPY --from=build /app/outputs/sbom/ /outputs/sbom
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

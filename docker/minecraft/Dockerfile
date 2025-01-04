FROM alpine AS builder
RUN apk add --no-cache openjdk21-jre-headless

ARG UID=1000
ARG GID=1000
USER "${UID}:${GID}"

ADD --chmod=755 \
    --checksum=sha256:c9f646908d340d84773948a9a7d98bc1dae250d35e1016dc6e2b8459760b5598 \
    https://github.com/packwiz/packwiz-installer/releases/download/v0.5.14/packwiz-installer.jar /opt/packwiz-installer.jar

ADD --chmod=755 \
    --checksum=sha256:62edf170bdcc41edea85d33acf3eb85474258699b3d41f9418d286c836cb088d \
    https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar /opt/fabric-installer.jar

COPY ./pack                         /pack
COPY ./docker/minecraft/build.sh    /build.sh

WORKDIR /server
WORKDIR /build
RUN --mount=type=cache,target=/build,uid=${UID},gid=${GID} \
    ["/build.sh"]

FROM gcr.io/distroless/java21-debian12
ARG UID=1000
ARG GID=1000
USER "${UID}:${GID}"

WORKDIR /data
VOLUME /data
VOLUME /server/logs

COPY --from=builder --chown=${UID}:${GID} /server /server

WORKDIR /server
ENTRYPOINT ["java"]
CMD ["-Xmx1G", "-jar", "/server/fabric-server-launch.jar", "--nogui", "--universe", "/data"]

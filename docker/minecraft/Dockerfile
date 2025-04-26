FROM bellsoft/liberica-runtime-container:jre-21-slim-musl AS builder
ARG UID=1000
ARG GID=1000
USER "${UID}:${GID}"

ADD --chmod=555 \
    --checksum=sha256:c9f646908d340d84773948a9a7d98bc1dae250d35e1016dc6e2b8459760b5598 \
    https://github.com/packwiz/packwiz-installer/releases/download/v0.5.14/packwiz-installer.jar /opt/packwiz-installer.jar

ADD --chmod=555 \
    --checksum=sha256:38aa82ab1ef829b7aa3f2143fcc93bba706a8e18835be731d0fdf231d274b07f \
    https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.3/fabric-installer-1.0.3.jar /opt/fabric-installer.jar

WORKDIR /pack
COPY . .

WORKDIR /server
WORKDIR /build
RUN --mount=type=cache,target=/build,uid=${UID},gid=${GID} \
    ["/pack/docker/minecraft/build.sh"]

FROM bellsoft/liberica-runtime-container:jre-21-slim-musl
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

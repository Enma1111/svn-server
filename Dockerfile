FROM alpine:3.24.4
LABEL org.opencontainers.image.source="https://github.com/Enma1111/svn-server" \
      org.opencontainers.image.description="Subversion server (svnserve) container, unofficial" \
      org.opencontainers.image.licenses="Apache-2.0"
RUN apk add --no-cache subversion ca-certificates tini \
 && adduser -D -u 1000 svnsrv \
 && mkdir -p /data /config \
 && chown svnsrv:svnsrv /data
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --chmod=755 metrics.sh /usr/local/bin/metrics.sh
USER 1000
WORKDIR /data
VOLUME /data
EXPOSE 3690 9100
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD nc -z localhost 3690 || exit 1
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]
CMD ["svnserve", "-d", "--foreground", "-r", "/data", "--listen-port", "3690"]
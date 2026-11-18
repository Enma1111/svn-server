#!/bin/sh
set -eu

DATA=/data
CONF_DIR="${SVN_CONFIG_DIR:-/config}"

# Optional: Repository beim ersten Start anlegen
if [ -n "${SVN_REPO:-}" ] && [ ! -d "$DATA/$SVN_REPO" ]; then
  echo "Creating repository $SVN_REPO"
  svnadmin create "$DATA/$SVN_REPO"
fi

# Eigene Konfiguration hat Vorrang, sonst eine sichere Standardkonfiguration
CONF_FILE="$CONF_DIR/svnserve.conf"
if [ ! -f "$CONF_FILE" ]; then
  CONF_FILE=/tmp/svnserve.conf
  if [ -f "$CONF_DIR/passwd" ]; then
    printf '[general]\nanon-access = none\nauth-access = write\npassword-db = %s/passwd\n' \
      "$CONF_DIR" > "$CONF_FILE"
  elif [ "${SVN_ANON_READ:-false}" = "true" ]; then
    printf '[general]\nanon-access = read\nauth-access = none\n' > "$CONF_FILE"
  else
    echo "No $CONF_DIR/passwd found. Mount one, or set SVN_ANON_READ=true (read-only demo)." >&2
    exit 1
  fi
fi

# Optional: Metrics auf Port 9100 (/metrics)
if [ "${METRICS:-true}" = "true" ]; then
  /usr/local/bin/metrics.sh &
  httpd -p 9100 -h /tmp/metrics
fi

exec "$@" --config-file "$CONF_FILE"
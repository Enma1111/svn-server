#!/bin/sh
DIR=/tmp/metrics
mkdir -p "$DIR"
while true; do
  {
    echo '# TYPE svn_repo_youngest_revision gauge'
    echo '# TYPE svn_repo_size_bytes gauge'
    for r in /data/*/; do
      [ -f "$r/format" ] || continue
      n=$(basename "$r")
      echo "svn_repo_youngest_revision{repo=\"$n\"} $(svnlook youngest "$r")"
      echo "svn_repo_size_bytes{repo=\"$n\"} $(( $(du -sk "$r" | cut -f1) * 1024 ))"
    done
  } > "$DIR/metrics.tmp" && mv "$DIR/metrics.tmp" "$DIR/metrics"
  sleep 30
done
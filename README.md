# svn-server

Unofficial Subversion server container (`svnserve`), based on Alpine. Rebuilt weekly so security updates of the base image arrive automatically.

```
ghcr.io/enma1111/svn-server:latest
```

Tags: `latest`, Subversion version (`1.14`, `1.14.5`) and build date (`YYYYMMDD`).

## Quick start (read-only demo)

```bash
docker run --rm -p 3690:3690 -p 9100:9100 \
  -e SVN_REPO=demo -e SVN_ANON_READ=true \
  ghcr.io/enma1111/svn-server:latest

svn info svn://localhost/demo
```

## With users

Mount a `passwd` file to `/config`:

```
[users]
jan = secret
```

```bash
docker run -d -p 3690:3690 \
  -v svn-data:/data \
  -v ./config:/config:ro \
  -e SVN_REPO=myrepo \
  ghcr.io/enma1111/svn-server:latest
```

Without `/config/passwd` and without `SVN_ANON_READ=true` the container refuses to start. Anonymous access is never on by default.

## Configuration

| Variable / path | Meaning |
|---|---|
| `SVN_REPO` | Create this repository in `/data` on first start |
| `SVN_ANON_READ` | `true` = anonymous read-only access (demo only) |
| `SVN_CONFIG_DIR` | Config directory, default `/config` |
| `METRICS` | `false` disables the metrics endpoint (default `true`) |
| `/data` | Repositories (use a persistent volume) |
| `/config/svnserve.conf` | Own config, takes precedence over the generated one |
| `/config/passwd` | User database |

## Health and metrics

- Health: TCP check on port 3690 (`HEALTHCHECK` in the image; use `tcpSocket` probes in Kubernetes).
- Metrics: `http://<host>:9100/metrics` in Prometheus format, per repository `svn_repo_youngest_revision` and `svn_repo_size_bytes`.

## Kubernetes

```yaml
securityContext:
  runAsUser: 1000
  fsGroup: 1000
livenessProbe:
  tcpSocket: { port: 3690 }
readinessProbe:
  tcpSocket: { port: 3690 }
```

Mount `/data` as a PersistentVolumeClaim and the `passwd` file as a Secret at `/config`.

## Security notes

- `svn://` is **not encrypted** and passwords in `passwd` are stored in plain text. Use it only inside a cluster network, behind a VPN or a tunnel, never openly on the internet.
- Plan backups (`svnadmin hotcopy` or `svnadmin dump`) for `/data`.

## License

Apache-2.0. Not affiliated with the Apache Software Foundation.
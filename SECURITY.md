# Deployment security

- OpenClaw is inherited from the official GHCR release image and pinned by
  architecture-specific SHA-256 digest in `Dockerfile`.
- The wrapper runs as the image's unprivileged `node` user.
- Wrapper dependencies install with `npm ci --ignore-scripts` from the
  committed lockfile.
- GitHub Actions are pinned to immutable commit SHAs and have read-only
  repository permissions.
- `/data` is the only persistent mount and contains credentials, sessions,
  configuration, and the workspace. Backups must be encrypted.
- The temporary public Railway domain is for initial setup only. Remove it
  after an outbound messaging channel is connected.
- Never commit provider credentials. Enter them through the authenticated
  setup flow or Railway sealed variables.

## Updating OpenClaw

1. Read the upstream release notes and security advisories.
2. Resolve the desired official GHCR image tag to its amd64 manifest digest.
3. Update both the readable tag and digest in `Dockerfile`.
4. Run unit tests and build the complete Docker image.
5. Review the diff before merging or deploying.

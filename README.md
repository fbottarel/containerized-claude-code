# Claude Code in Docker

A containerized [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) environment on Ubuntu 26.04, with a mounted project folder and a login that survives container rebuilds.

## Quick start

```bash
cp .env.example .env        # then edit it (see below)
docker compose up -d --build
docker compose exec claude claude
```

On the first run, Claude Code prints a login URL. Open it, sign in, and paste the code back into the terminal. You only need to do this once.

## Configuration (`.env`)

| Variable        | Purpose                                       | Default       |
|-----------------|-----------------------------------------------|---------------|
| `WORKSPACE_DIR` | Host folder mounted at `/workspace`           | `./claude-workspace` |
| `UID` / `GID`   | Container user IDs; match your host (`id -u`, `id -g`) so file ownership lines up | `1000` |

## How the persistent login works

`CLAUDE_CONFIG_DIR` points to `/home/dev/.claude-config`, which is backed by the `claude-config` named volume. Credentials and settings live in that volume, not in this repo, so they persist across `docker compose down` and image rebuilds.

To log out completely and start fresh:

```bash
docker compose down -v      # -v removes the claude-config volume
```

### Optional: token-based login

Instead of the browser login, run `claude setup-token` on a machine with Claude Code installed, put the token in `.env` as `CLAUDE_CODE_OAUTH_TOKEN=...`, and uncomment the `environment` block in `compose.yaml`. Never commit `.env` once it holds a token.

## Included tooling

Git, ripgrep, build-essential, CMake, GDB, and Python 3 with pip and venv. Edit the `apt-get install` line in the `Dockerfile` to add or remove packages.

## Updating Claude Code

The binary is installed at build time. Rebuild to get the latest version:

```bash
docker compose build --no-cache
docker compose up -d
```

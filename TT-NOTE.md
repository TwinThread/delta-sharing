# TwinThread Fork — Delta Sharing Server

## Fork Setup

This is TwinThread's fork of [delta-io/delta-sharing](https://github.com/delta-io/delta-sharing).

**Remotes:**
- `origin` → `TwinThread/delta-sharing` (this fork)
- `upstream` → `delta-io/delta-sharing` (community)

**Branch strategy:**
- `main` — tracks upstream main (do not commit here)
- `tt/main` — our customization branch, based on release tags

## What We Changed

The only addition is a `Dockerfile` for building a `linux/amd64` image of the delta-sharing-server.

The upstream project stopped publishing Docker Hub images at `0.7.8`, and from `0.7.0` onward only `arm64` images were published. No `1.x` images were ever published. We build our own `amd64` image.

## Building

```bash
docker buildx build --platform linux/amd64 \
  -t <your-registry>/delta-sharing-server:<version> \
  --load .

docker push <your-registry>/delta-sharing-server:<version>
```

## Pulling Upstream Updates

When a new community release is tagged (e.g. `v1.3.11`):

```bash
git fetch upstream --tags
git checkout tt/main
git merge v1.3.11
# Resolve any conflicts (unlikely — we only add files)
git push origin tt/main
```

Then rebuild and push the Docker image with the new version tag.

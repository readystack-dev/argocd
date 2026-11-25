# Argo CD: ReadyStack build kit

The offline build kit for the Docker image `readystack/argocd:v3.6.2-CE-ubuntu24.04-r2`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v3.6.2-CE-ubuntu24.04-r2](https://github.com/readystack-dev/argocd/releases/tag/v3.6.2-CE-ubuntu24.04-r2)
- Image: [`docker.io/readystack/argocd:v3.6.2-CE-ubuntu24.04-r2`](https://hub.docker.com/r/readystack/argocd/tags), manifest digest `sha256:6f9db9a862430fd368d5994c960c0a20e4af83565e2e53a2ce6cbfbd96752d29`
- Product page: https://readystack.dev/products/argocd
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=argocd

Argo CD is distributed under its upstream licence (Apache-2.0); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [v3.6.2-CE-ubuntu24.04-r2 release](https://github.com/readystack-dev/argocd/releases/tag/v3.6.2-CE-ubuntu24.04-r2): `ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.tar.gz` (673.9 MB), SHA-256 `1d540917d7d011fc854ce1b0378111d23732a74befa6a890b7647fd5532f10a3`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.rebuild.json.sigstore ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.tar.gz
cd v3.6.2-CE-ubuntu24.04-r2
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/argocd/recipe. The complete kit is the release download. Each release is a tag here.

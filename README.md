# Argo CD: ReadyStack build kit

The offline build kit for the Docker image `readystack/argocd:v3.6.3-CE-ubuntu24.04-r1`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v3.6.3-CE-ubuntu24.04-r1](https://github.com/readystack-dev/argocd/releases/tag/v3.6.3-CE-ubuntu24.04-r1)
- Image: [`docker.io/readystack/argocd:v3.6.3-CE-ubuntu24.04-r1`](https://hub.docker.com/r/readystack/argocd/tags), manifest digest `sha256:3cd491049cfb4f7719833a3ff491831b7f998150ee0671123bb4a30196825c1b`
- Product page: https://readystack.dev/products/argocd
- Source and build recipe: https://readystack.dev/products/argocd/recipe
- Build trail: https://readystack.dev/products/argocd/trail/v3.6.3-CE-ubuntu24.04-r1
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=argocd

## The image

SINGLE self-contained container. The Argo CD components (argocd-server, argocd-repo-server, argocd-application-controller) and redis run INSIDE this one image under supervisord, next to an embedded k3s that serves as the Kubernetes API and datastore. There is no argocd-dex-server in this image (no dex process; /api/dex answers 404). This is NOT a Kubernetes deployment / Helm install / kubectl apply of the install manifests — the image IS the complete running instance. Argo CD can manage external clusters once you register them, but the control plane itself is this one container.

## Who uses Argo CD and why

Platform and DevOps teams who deploy applications to Kubernetes clusters.

Argo CD treats a Git repository as the source of truth for what should run. It compares each cluster with Git, shows the differences, and syncs the cluster back to the declared state.

A typical use: A team keeps the manifests for its services in Git. A change merged there is what reaches staging and production: Argo CD notices the new target state and applies it, and if someone edits a cluster by hand, the application shows as out of sync until it is brought back in line.

From the upstream project's own description: https://github.com/argoproj/argo-cd, https://argo-cd.readthedocs.io/en/stable/.

## This release

- Docker Scout policy grade at release: **A** (94%), graded 2026-11-25 with `docker scout policy` (CLI 1.26.0, docker-default configuration).
  - Docker Scout counts 123 packages with copyleft licences (GPL, LGPL, MPL), all of them operating-system packages (it counts only packages whose licence it can read; the SBOM lists every component).
- Signed with ReadyStack's release key (fingerprint `04daa92344a52dbc`): https://readystack.dev/keys/cosign.pub.
- Runs as a non-root user (`999`).
- Attestations on the image: an SPDX SBOM and SLSA provenance v1.
- Rebuilt from this kit with network egress blocked on 2026-11-25; the rebuilt image digest is the published one.
- Base: Ubuntu 24.04.

The current grade, measured again every day, is on https://readystack.dev/products/argocd.

Argo CD is distributed under its upstream licence (Apache-2.0); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [v3.6.3-CE-ubuntu24.04-r1 release](https://github.com/readystack-dev/argocd/releases/tag/v3.6.3-CE-ubuntu24.04-r1): `ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r1.tar.gz` (673.9 MB), SHA-256 `a6c5acf5e9dedb6a0f9b3241bb2543dc9c81f874511a261ec1ac0bcb672e20d1`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r1.rebuild.json.sigstore ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r1.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r1.tar.gz
cd v3.6.3-CE-ubuntu24.04-r1
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r1.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/argocd/recipe. The complete kit is the release download. Each release is a tag here.

— ReadyStack · https://readystack.dev

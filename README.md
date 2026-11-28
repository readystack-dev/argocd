[![ReadyStack](https://readystack.dev/logo.svg)](https://readystack.dev)

**Stable, Open-source Releases, Automated** · [readystack.dev](https://readystack.dev)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-readystack%2Fargocd-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/readystack/argocd) [![Docker pulls](https://img.shields.io/docker/pulls/readystack/argocd)](https://hub.docker.com/r/readystack/argocd) [![Grade at release](https://img.shields.io/badge/grade%20at%20release-A%20%2894%25%29-2ea44f)](https://readystack.dev/products/argocd) [![Signed: cosign](https://img.shields.io/badge/signed-cosign-2ea44f)](https://readystack.dev/keys/cosign.pub) ![SBOM: SPDX](https://img.shields.io/badge/SBOM-SPDX-2ea44f) ![Provenance: SLSA v1](https://img.shields.io/badge/provenance-SLSA%20v1-2ea44f) ![Offline rebuild: verified](https://img.shields.io/badge/offline%20rebuild-verified-2ea44f)

# Argo CD: ReadyStack build kit

The offline build kit for the Docker image `readystack/argocd:v3.6.3-CE-ubuntu24.04-r2`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v3.6.3-CE-ubuntu24.04-r2](https://github.com/readystack-dev/argocd/releases/tag/v3.6.3-CE-ubuntu24.04-r2)
- Image: [`docker.io/readystack/argocd:v3.6.3-CE-ubuntu24.04-r2`](https://hub.docker.com/r/readystack/argocd/tags), manifest digest `sha256:28c1e0786de4f0d58f9b8a6433a723c038feac7af45a687d9703ecb8d1804934`
- Product page: https://readystack.dev/products/argocd
- Source and build recipe: https://readystack.dev/products/argocd/recipe
- Build trail: https://readystack.dev/products/argocd/trail/v3.6.3-CE-ubuntu24.04-r2
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=argocd

## The image

SINGLE self-contained container. The Argo CD components (argocd-server, argocd-repo-server, argocd-application-controller) and redis run INSIDE this one image under supervisord, next to an embedded k3s that serves as the Kubernetes API and datastore. There is no argocd-dex-server in this image (no dex process; /api/dex answers 404). This is NOT a Kubernetes deployment / Helm install / kubectl apply of the install manifests — the image IS the complete running instance. Argo CD can manage external clusters once you register them, but the control plane itself is this one container.

## Who uses Argo CD and why

Platform and DevOps teams who deploy applications to Kubernetes clusters.

Argo CD treats a Git repository as the source of truth for what should run. It compares each cluster with Git, shows the differences, and syncs the cluster back to the declared state.

A typical use: A team keeps the manifests for its services in Git. A change merged there is what reaches staging and production: Argo CD notices the new target state and applies it, and if someone edits a cluster by hand, the application shows as out of sync until it is brought back in line.

From the upstream project's own description: https://github.com/argoproj/argo-cd, https://argo-cd.readthedocs.io/en/stable/.

## This release

- Docker Scout policy grade at release: **A** (94%), graded 2026-11-28 with `docker scout policy` (CLI 1.26.0, docker-default configuration).
  - Docker Scout counts 123 packages with copyleft licences (GPL, LGPL, MPL), all of them operating-system packages (it counts only packages whose licence it can read; the SBOM lists every component).
- Signed with ReadyStack's release key (fingerprint `04daa92344a52dbc`): https://readystack.dev/keys/cosign.pub.
- Runs as a non-root user (`999`).
- Attestations on the image: an SPDX SBOM and SLSA provenance v1.
- Rebuilt from this kit with network egress blocked on 2026-11-28; the rebuilt image digest is the published one.
- Base: Ubuntu 24.04.

The current grade, measured again every day, is on https://readystack.dev/products/argocd.

Argo CD is distributed under its upstream licence (Apache-2.0); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [v3.6.3-CE-ubuntu24.04-r2 release](https://github.com/readystack-dev/argocd/releases/tag/v3.6.3-CE-ubuntu24.04-r2): `ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r2.tar.gz` (673.9 MB), SHA-256 `838157a003f8e045ff540549cf4cb6e21ace189d04ec134bcf9c22feeb8b1fb0`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r2.rebuild.json.sigstore ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r2.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r2.tar.gz
cd v3.6.3-CE-ubuntu24.04-r2
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-argocd-v3.6.3-CE-ubuntu24.04-r2.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/argocd/recipe. The complete kit is the release download. Each release is a tag here. How to report a vulnerability: [SECURITY.md](SECURITY.md).

## About ReadyStack

**Stable, Open-source Releases, Automated.** ReadyStack releases popular open-source apps every week with every available critical and high security fix applied, plus full documentation, reference data, tests and a build recipe that recreates each release bit-for-bit. Each release is rebuilt from its pinned inputs with the network off, checked against its published digest, signed, and scanned and graded again every day. The images and build kits are free, and ReadyStack is soon to be a nonprofit.

[readystack.dev](https://readystack.dev) · [All products](https://readystack.dev/products.html) · [Build kits on GitHub](https://github.com/readystack-dev) · [Defect log](https://readystack.dev/defects.html) · contact@readystack.dev

— ReadyStack · https://readystack.dev

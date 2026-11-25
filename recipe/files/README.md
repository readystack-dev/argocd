<!-- readystack:kit-readme begin (written at packaging; the kit's own README follows the end marker) -->

# Build kit for `readystack/argocd:v3.6.2-CE-ubuntu24.04-r2`

This archive rebuilds the linux/amd64 image `readystack/argocd:v3.6.2-CE-ubuntu24.04-r2` from its own contents, with the network off, and checks the result against the image digest ReadyStack published, `sha256:6f9db9a862430fd368d5994c960c0a20e4af83565e2e53a2ce6cbfbd96752d29` (also in `TARGET_DIGEST.txt`). It holds everything the build needs, not the image itself.

## Rebuild it

You need linux/amd64 Docker with `buildx` 0.30 or later, `jq` and `tar` (docs/REBUILD.md lists the rest, if any, and the hardware ReadyStack used).

```
tar -xpzf ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.tar.gz    # -p keeps each file's mode
cd v3.6.2-CE-ubuntu24.04-r2
./BUILD_OFFLINE.sh            # builds with the network off, from this archive alone
./VERIFY_OFFLINE.sh           # compares the rebuilt digest with the published one, then checks the image
```

`./VERIFY_OFFLINE.sh --online` also checks that the Docker Hub tag holds the digest you rebuilt.

File modes are build input: a Dockerfile `COPY` carries them into the image. Unpacked without `-p`, your umask changes them (664 becomes 644 under umask 022). `FILE_MODES.tsv` records the mode of every file and directory as packed; `BUILD_OFFLINE.sh` puts back any that differ before it builds, and `./BUILD_OFFLINE.sh --restore-modes` does only that.

## Check ReadyStack's signature (optional)

ReadyStack signs this archive's `rebuild.json` with its release key once the finished archive has passed the release gate, and records the signature in the public Sigstore transparency log. The signature is made after the archive is sealed, so it is published beside it rather than inside it. Download it and the public key next to this directory, not into it: a file added inside the kit changes the tree hash that `rebuild.json` records, and `validate` then refuses the kit.

```
curl -fsSLo ../cosign.pub https://readystack.dev/keys/cosign.pub
curl -fsSLo ../ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.rebuild.json.sigstore https://readystack.dev/api/kit/argocd/v3.6.2-CE-ubuntu24.04-r2/files/ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.rebuild.json.sigstore
python3 docs/rebuild-bundle/rebuild_bundle.py validate . --key ../cosign.pub --signature ../ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.rebuild.json.sigstore
```

`validate` needs Python 3 and cosign. Without building anything it checks the signature over `rebuild.json`, every file's checksum, the tree hash over every file's path, mode and content, each base image layout's digest and the builder archive. `verify`, with the same arguments, also rebuilds with the builder's network egress blocked and exits 0 only when the rebuilt digest is the published one (docs/REBUILD.md).

## What else is here

- `docs/REBUILD.md`: the full rebuild guide: requirements, what `rebuild.json` records, the verifier's exit codes, and SLSA provenance on your own build platform
- `docs/VERIFY.md`: checking the published image, its signature and its attestations without rebuilding
- `docs/PROVENANCE.md`: where every input came from
- `docs/PINS.md`: every pinned input and why it was chosen
- `docs/RELEASE_NOTES.md`: what this release changed, and its known issues
- `docs/admin-guide/ADMIN_HANDBOOK.md`: running the product

<!-- readystack:kit-readme end -->

# argocd build kit (rootless k3s, USER 999, hermetic offline rebuild)

Single self-contained, **non-root** Argo CD appliance: supervisord runs k3s (`--rootless --disable-agent`,
the Kubernetes API that holds argocd's config and CRDs), redis, and argocd-repo-server,
argocd-application-controller and argocd-server (`--insecure`, port 8080) as plain processes.

- **Dockerfile.vendor** (online, `--target export`): builds the UI from source (pnpm + webpack), vendors five Go
  trees with the CVE floors applied raise-only (`floor()`, mirrors `strategies/argocd.json` `dep_bumps`):
  argo-cd v3.6.2, helm v4.3.2, kustomize v5.8.3, git-lfs v3.8.1 and k3s v1.37.2+k3s1 (`./cmd/server`, with its
  manifests and the two sha256-pinned charts embedded as upstream's `scripts/build` does); downloads the apt
  dist-upgrade closure plus runtime packages from the pinned ubuntu:24.04.
- **Dockerfile.offline.pinned** (`--network=none`): compiles all five binaries on golang:1.27.3 with
  `GOPROXY=off -mod=vendor`, dpkg-installs the vendored debs on the pinned ubuntu:24.04, freezes `/etc/shadow`
  to `SOURCE_DATE_EPOCH`, and assembles the image. **Dockerfile** and **Dockerfile.offline** are byte copies.
- Nothing is fetched by hand and nothing FROMs a locally built image: the old `argocd-discovery`/`argocd-base:offline`
  images, `offline-kit.sh` and the hand-placed `k3s` / `manifests/install.yaml` are gone. `install.yaml` comes from
  the vendored argo-cd tree at the tag.

Non-root mechanism: k3s `--rootless --disable-agent` keeps all state under `$HOME` (/home/argocd) and runs as uid
999 in the container's own user namespace (k3s starts rootlesskit, and so needs `uidmap` + /etc/sub{u,g}id, only when
it also runs an agent); plain `docker run` (no `--privileged`).

Why k3s is built from source: the k3s release binary is a self-extracting wrapper (`cmd/k3s`). Scout scans only
the wrapper; the server that actually runs is `data/<hash>/bin/k3s` inside a zstd payload no scanner opens. On
chain 414 (2026-10-21) the wrapper was go1.26.8 (11 fixable C/H, the verdict's whole residual) and the hidden server
binary go1.26.8 + x/crypto 0.47.0 + x/net 0.55.0 + x/mod 0.38.0 (10 critical + 21 high fixable). No k3s release is
built on Go 1.26.9 yet (every branch's go.mod is still 1.26.8), so the kit builds `./cmd/server` from source with
the argocd floors (k3s pins x/crypto and x/net by `replace`, so `floor()` raises the replace) and ships that binary
with no wrapper. Build tags are upstream's linux set minus `static_build libsqlite3 seccomp`
(they need C libraries the pinned builder does not carry; sqlite comes from mattn/go-sqlite3's bundled amalgamation,
and seccomp is only used by containerd/runc, which never run under `--disable-agent`). The agent side (containerd,
runc, CNI, k3s-root userland) is not in the image: this k3s never runs pods. Two consequences of dropping the wrapper:
`k3s kubectl ...` is kept by `k3s-cli.sh` (installed as /usr/local/bin/k3s; the server binary is
/usr/local/lib/k3s/k3s and runs kubectl only under the name `kubectl`, so /usr/local/bin/kubectl links to it), and the
server runs with `--flannel-backend=none` (it otherwise looks up the host-local CNI plugin at start, which the
wrapper's extracted userland used to provide).

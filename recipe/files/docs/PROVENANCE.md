# Provenance — Argo CD (`v3.6.2-CE-ubuntu24.04-r2`)

Every item below is copied from a record in this archive; the record is named in brackets.

## Source

- Upstream repository: https://github.com/argoproj/argo-cd.git
- Revision built: `v3.6.2` (commit `8e8268ef2f3df99ca95663f5080fa6056f156805`)
- Source tree: `f7bcddea681e7b03c64ce3e35b4069e8c44a63a41e4c0d9191ddc602d6142536` over 6104 files [`docs/provenance/SOURCE_TREE_HASH.json`]
- Community Edition only: enterprise code is removed or refused before the build (CE audit at acquire).

## Build

- Method: `source-rebuild-go`; base image `ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289`
- Compiled with `--network=none` from vendored source, dependencies and base images; BuildKit pinned to `moby/buildkit:v0.31.2` (shipped in `toolchain/`).
- SOURCE_DATE_EPOCH: `1795543208` [`SOURCE_DATE_EPOCH.txt`]
- Frozen inputs: [`docs/provenance/FREEZE_MANIFEST.json`], build recipe: [`docs/provenance/BUILD_RECIPE.json`].

## Output

- Published image: `readystack/argocd:v3.6.2-CE-ubuntu24.04-r2` — index digest `sha256:d887a3683186aa189f712106771dcf8ee142e36e4f86f53dc0733673902e6c9d` [`docs/provenance/LOCKED_DIGEST.txt`]
- linux/amd64 image digest `sha256:6f9db9a862430fd368d5994c960c0a20e4af83565e2e53a2ce6cbfbd96752d29` — reproduced from this archive before publishing [`docs/provenance/REPRO_VERIFICATION.json`].

## Attestations and signature

- SBOM + SLSA provenance attached to the image: attached: an SPDX SBOM and SLSA v1 provenance [`docs/provenance/SCOUT_VERDICT.json`]
- cosign signature by the ReadyStack release key: verified before publishing. Check it: `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/argocd:v3.6.2-CE-ubuntu24.04-r2`

## Pinned inputs, and why

- 60 pinned inputs, each with where it came from, why this one, how it was checked and when it was decided: `docs/PINS.md` [`docs/provenance/PINS.json`] (upstream source 2, base and build images 2, image digests 3, language runtimes and toolchains 1, dependency versions readystack sets 21, pins in the kit's dockerfiles 28, readystack's build engine 1, dependencies upstream chose 2).

## Build trail

- How this release passed through the ReadyStack harness, record by record (every chain, drive, stage, review round, defect and check, each naming the record it is copied from): `ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.trail.json`, published beside this archive and signed with the release key (`ReadyStack-argocd-v3.6.2-CE-ubuntu24.04-r2.trail.json.sigstore`), and readable at https://readystack.dev/products/argocd/trail/v3.6.2-CE-ubuntu24.04-r2.


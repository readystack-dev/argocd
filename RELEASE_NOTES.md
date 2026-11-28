# Argo CD v3.6.3 — ReadyStack release `v3.6.3-CE-ubuntu24.04-r2`

Generated 2026-11-28 from this release's build records and strategy. Statements that come from a single record name it in brackets; the others come from this release's strategy and build log.

## Release

- **Image:** `readystack/argocd:v3.6.3-CE-ubuntu24.04-r2` (linux/amd64). Index digest `sha256:87d2dbf508966425924409624ff576494edffb973be6d92d2917d96fecb3fd54` [`docs/provenance/LOCKED_DIGEST.txt`].
- **Image manifest digest:** `sha256:28c1e0786de4f0d58f9b8a6433a723c038feac7af45a687d9703ecb8d1804934` [`TARGET_DIGEST.txt`].
- **Upstream:** Argo CD v3.6.3 built from source at `v3.6.3` of https://github.com/argoproj/argo-cd — upstream notes: https://github.com/argoproj/argo-cd/releases/tag/v3.6.3 [`docs/provenance/BUILD_RECIPE.json`].
- **Build:** `source-rebuild-go`, compiled offline with `--network=none`.
- **Supersedes:** ReadyStack release `v3.6.3-CE-ubuntu24.04-r1`.

## What changed in this release

- Upstream version unchanged (v3.6.3); ReadyStack rebuild.
- Minimum dependency versions ReadyStack enforces on top of upstream (raised only where upstream's own version was lower); shipped versions from the SBOM [`docs/sbom/SBOM.json`]:
  - `github.com/go-git/go-git/v5` at least `v5.19.2`: not raised, upstream already pins `v5.19.2` (shipped: `v5.19.2`)
  - `google.golang.org/grpc` at least `v1.83.2`: not raised, upstream already pins `v1.84.0` (shipped: `v1.83.2`)
  - `golang.org/x/crypto` at least `v0.56.0`: not raised, upstream already pins `v0.58.0` (shipped: `v0.56.0`)
  - `golang.org/x/net` at least `v0.62.0`: not raised, upstream already pins `v0.62.0` (shipped: `v0.62.0`)
  - `golang.org/x/text` at least `v0.41.0`: not raised, upstream already pins `v0.43.0` (shipped: `v0.42.0`)
  - `oras.land/oras-go/v2` at least `v2.6.2`: not raised, upstream already pins `v2.6.2` (shipped: `v2.6.2`)
  - `github.com/klauspost/compress` at least `v1.20.2`: not raised, upstream already pins `v1.20.2` (shipped: `v1.20.2`)
  - `golang.org/x/mod` at least `v0.40.0`: not raised, upstream already pins `v0.41.0` (shipped: `v0.41.0`)
  - `github.com/nats-io/nats-server/v2` at least `v2.14.3` (shipped: `v2.14.3`)
  - `github.com/pion/dtls/v3` at least `v3.1.4` (shipped: `v3.1.4`)
  - `github.com/pion/stun/v3` at least `v3.1.5` (shipped: `v3.1.5`)
  - `github.com/quic-go/webtransport-go` at least `v0.11.1` (shipped: `v0.11.1`)
  - `go.opentelemetry.io/otel/trace` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.47.0`)
  - `go.opentelemetry.io/otel` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.47.0`)
  - `go.opentelemetry.io/otel/sdk` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.47.0`)
  - `go.opentelemetry.io/otel/metric` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.47.0`)
  - `go.opentelemetry.io/otel/exporters/otlp/otlptrace` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.46.0`)
  - `go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc` raised from upstream's `v1.46.0` to at least `v1.47.0` (shipped: `v1.46.0`)
- Argo CD v3.6.3 is unchanged from the release this supersedes (v3.6.3-CE-ubuntu24.04-r1); this release rebuilds it. Changes: libexpat1 moves from 2.6.1-2ubuntu0.6 to 2.6.1-2ubuntu0.7 (USN-9196-1). Settings and ports are those of v3.6.3-CE-ubuntu24.04-r1. The image itself holds no data you must carry over: state lives in the volume the Admin Handbook documents; remove the old container and run this image with the same settings, including that volume.

## Security status at release (measured 2026-11-28)

- **Docker Scout:** 0 fixable critical/high vulnerabilities after 1 OpenVEX statement of ours (`docs/security/VEX.openvex.json`; Docker Scout's default policy does not read them and counts it as fixable); runs as `999` (non-root); SBOM + provenance attestations present (SPDX SBOM + SLSA v1) [`docs/provenance/SCOUT_VERDICT.json`].
- **OSV cross-check:** no fixable critical/high vulnerability beyond Docker Scout's findings.
- **Signature:** cosign signature verified by ReadyStack's release gate before publishing; check it yourself with `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/argocd:v3.6.3-CE-ubuntu24.04-r2` (signatures are recorded in the public Sigstore transparency log).
- **ReadyStack release check at release:** passed (ReadyStack's own test, not a Docker Scout grade). Vulnerabilities are disclosed every day and the image never changes, so it is re-checked daily, beside Docker Scout's own dated grade, at https://readystack.dev/queue.

## Reproducibility

Rebuilds offline from this archive to the identical image digest `sha256:28c1e0786de4f0d58f9b8a6433a723c038feac7af45a687d9703ecb8d1804934`: run `./BUILD_OFFLINE.sh`, then `./VERIFY_OFFLINE.sh` (add `--online` to confirm the Docker Hub tag holds the same digest). Before publishing, ReadyStack rebuilt the kit with `./BUILD_OFFLINE.sh` and compared the result with the published digest [`docs/provenance/REPRO_VERIFICATION.json`], then ran `./BUILD_OFFLINE.sh` and `./VERIFY_OFFLINE.sh` from this archive (without `--online`).

## Validation

- 13 of 13 use cases passed (14 authored, 13 kept in the suite; 1 not exercised, see below) against the running image [`docs/validation/test-results.json`].
- 1 further authored check was not exercised and is not counted above: it used a method this release's API does not offer on that path (listed under Not exercised in `docs/validation/FAILED_TESTS.md`).

## Known issues

- **medium** (ReadyStack package): CVE-2026-123158 in openssh-client 1:9.6p1-3ubuntu13.20 is on CISA's Known Exploited Vulnerabilities list — CVE-2026-123158 (https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) [`RSD-argocd-4d3b8a22a0`] (carried from `v3.6.1-CE-ubuntu24.04-r1`, recorded there as `RSD-argocd-762e530319`)
- **low** (ReadyStack package): Security report: sbom/SBOM.json: otlptrace v1.47.0 sourced from /usr/local/bin/argocd, v1.46.0 from /usr/local/lib/k3s/k3s; the table prints only one version and reads as a floor violation. [`RSD-argocd-d23900aa25`] (carried from `v3.6.2-CE-ubuntu24.04-r1`, recorded there as `RSD-argocd-293be09c1a`)

## Verify this archive

```
sha256sum -c CHECKSUMS.sha256
./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/argocd:v3.6.3-CE-ubuntu24.04-r2
```

ReadyStack records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags.


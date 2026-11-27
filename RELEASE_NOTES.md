# Argo CD v3.6.3 — ReadyStack release `v3.6.3-CE-ubuntu24.04-r1`

Generated 2026-11-25 from this release's build records and strategy. Statements that come from a single record name it in brackets; the others come from this release's strategy and build log.

## Release

- **Image:** `readystack/argocd:v3.6.3-CE-ubuntu24.04-r1` (linux/amd64). Index digest `sha256:ab94bb8d54d320fec046f066482c8a66fc27eeaa650702253d4e3bf5560d2985` [`docs/provenance/LOCKED_DIGEST.txt`].
- **Image manifest digest:** `sha256:3cd491049cfb4f7719833a3ff491831b7f998150ee0671123bb4a30196825c1b` [`TARGET_DIGEST.txt`].
- **Upstream:** Argo CD v3.6.3 built from source at `v3.6.3` of https://github.com/argoproj/argo-cd — upstream notes: https://github.com/argoproj/argo-cd/releases/tag/v3.6.3 [`docs/provenance/BUILD_RECIPE.json`].
- **Build:** `source-rebuild-go`, compiled offline with `--network=none`.
- **Supersedes:** ReadyStack release `v3.6.2-CE-ubuntu24.04-r2`.

## What changed in this release

- Upstream version v3.6.2 → v3.6.3.
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
- This release moves Argo CD from 3.6.2 to 3.6.3, a newer release of upstream's 3.6.x line. Upstream's release notes list what changed: https://github.com/argoproj/argo-cd/releases/tag/v3.6.3. Upstream's 3.6.3 fixes four high-severity Argo CD advisories (GHSA-mfgm-4p7x-3ccr, GHSA-w7rw-fg89-2cjf, GHSA-rxm8-qc6h-3c8h, GHSA-rvmf-gjc9-wjgq) and three moderate ones (GHSA-q4f6-wc8m-r246, GHSA-v2hj-322q-6cg4, GHSA-8cfq-7w4v-ggm3) that 3.6.2 carries. One change can stop an existing Application from syncing: Helm release names (spec.source.helm.releaseName, including from .argocd-source.yaml) are now passed to Helm literally and must be valid Helm release names (lowercase letters, digits, '-' and '.', starting and ending with a letter or digit, at most 53 characters), so manifest generation fails for one whose release name is not valid or relied on template syntax. Settings, ports and the /home/argocd volume are those of v3.6.2-CE-ubuntu24.04-r2: replace the container with this image on the same volume.

## Security status at release (measured 2026-11-25)

- **Docker Scout:** 0 fixable critical/high vulnerabilities after 1 OpenVEX statement of ours (`docs/security/VEX.openvex.json`; Docker Scout's default policy does not read them and counts it as fixable); runs as `999` (non-root); SBOM + provenance attestations present (SPDX SBOM + SLSA v1) [`docs/provenance/SCOUT_VERDICT.json`].
- **OSV cross-check:** no fixable critical/high vulnerability beyond Docker Scout's findings.
- **Signature:** cosign signature verified by ReadyStack's release gate before publishing; check it yourself with `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/argocd:v3.6.3-CE-ubuntu24.04-r1` (signatures are recorded in the public Sigstore transparency log).
- **ReadyStack release check at release:** passed (ReadyStack's own test, not a Docker Scout grade). Vulnerabilities are disclosed every day and the image never changes, so it is re-checked daily, beside Docker Scout's own dated grade, at https://readystack.dev/queue.

## Reproducibility

Rebuilds offline from this archive to the identical image digest `sha256:3cd491049cfb4f7719833a3ff491831b7f998150ee0671123bb4a30196825c1b`: run `./BUILD_OFFLINE.sh`, then `./VERIFY_OFFLINE.sh` (add `--online` to confirm the Docker Hub tag holds the same digest). Before publishing, ReadyStack rebuilt the kit with `./BUILD_OFFLINE.sh` and compared the result with the published digest [`docs/provenance/REPRO_VERIFICATION.json`], then ran `./BUILD_OFFLINE.sh` and `./VERIFY_OFFLINE.sh` from this archive (without `--online`).

## Validation

- 17 of 22 use cases passed (23 authored, 22 kept in the suite; 1 not exercised, see below) against the running image [`docs/validation/test-results.json`].
- Failed cases are listed in `docs/validation/FAILED_TESTS.md`.
- 1 further authored check was not exercised and is not counted above: it used a method this release's API does not offer on that path (listed under Not exercised in `docs/validation/FAILED_TESTS.md`).

## Known issues

- **medium** (ReadyStack package): CVE-2026-123158 in openssh-client 1:9.6p1-3ubuntu13.20 is on CISA's Known Exploited Vulnerabilities list — CVE-2026-123158 (https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/) [`RSD-argocd-25ce6ce89c`] (carried from `v3.6.1-CE-ubuntu24.04-r1`, recorded there as `RSD-argocd-762e530319`)
- **low** (ReadyStack package): Security report: sbom/SBOM.json: otlptrace v1.47.0 sourced from /usr/local/bin/argocd, v1.46.0 from /usr/local/lib/k3s/k3s; the table prints only one version and reads as a floor violation. [`RSD-argocd-fe8899480c`] (carried from `v3.6.2-CE-ubuntu24.04-r1`, recorded there as `RSD-argocd-293be09c1a`)
- Build-time check `argocd-list-settings-plugins-probe` (GET http://127.0.0.1:8080/api/v1/settings/plugins) returned 500, expected 200.
- Build-time check `argocd-get-account-password-probe` (GET http://127.0.0.1:8080/api/v1/account/password) returned 404, expected 200. The check itself was wrong: this release's API offers PUT on that path, not GET.
- Build-time check `argocd-get-write-repositories-probe` (GET http://127.0.0.1:8080/api/v1/write-repositories) returned 501, expected 200.
- Build-time check `argocd-get-applicationsets-generate-probe` (GET http://127.0.0.1:8080/api/v1/applicationsets/generate) returned 404, expected 200. The check itself was wrong: this release's API offers POST on that path, not GET.
- Build-time check `argocd-get-applications-manifests-with-files-probe` (GET http://127.0.0.1:8080/api/v1/applications/manifestsWithFiles) returned 403, expected 200. The check itself was wrong: this release's API offers POST on that path, not GET.

## Verify this archive

```
sha256sum -c CHECKSUMS.sha256
./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/argocd:v3.6.3-CE-ubuntu24.04-r1
```

ReadyStack records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags.


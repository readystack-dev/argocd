# =====================================================================
# Argo CD v3.6.3 L-009 HERMETIC OFFLINE BUILD — the canonical, attestation-producing build. build_kit runs
#   docker buildx build --builder readystack-builder-max --network=none
#     --attest type=provenance,mode=max --attest type=sbom --push <git-context>
# Pinned-public-base + vendored model (the container builder cannot see host images, so nothing here
# FROMs a locally built image): golang 1.27.4 + ubuntu 24.04 pinned BY DIGEST (BASE_IMAGE_DIGESTS.lock);
# vendored/{argocd,helm,kustomize,gitlfs,k3s}-src are fully vendored Go trees (GOPROXY=off, -mod=vendor), all five
# compiled here on the one pinned Go; vendored/debs is the apt closure, dpkg offline.
# Dockerfile and Dockerfile.offline are byte copies of this file (the repo-wide convention).
#
# SHAPE: one self-contained, NON-ROOT container (USER 999). supervisord runs k3s (--rootless
# --disable-agent: the Kubernetes API that holds argocd's config/CRDs, no nodes, no pods), redis, and
# argocd-repo-server / -application-controller / -server (--insecure on :8080) as plain processes.
# k3s is its server binary (./cmd/server) built from source, not the release's self-extracting wrapper. Under
# --disable-agent nothing from the wrapper's extracted userland runs: --rootless only relocates the data dir to
# $HOME (k3s calls rootlesskit only when it also runs an agent), and no containerd/runc/CNI ever starts.
# =====================================================================
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS argocd-build
WORKDIR /src
COPY vendored/argocd-src/ .
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off
# The ldflags upstream's Makefile stamps (argocd-all), with the values fixed to the v3.6.3 tag:
# buildDate is the release's cut date (SOURCE_DATE_EPOCH 1795614817), not the wall clock.
RUN go build -trimpath -ldflags "-s -w \
      -X github.com/argoproj/argo-cd/v3/common.version=3.6.3 \
      -X github.com/argoproj/argo-cd/v3/common.buildDate=2026-11-25T13:53:37Z \
      -X github.com/argoproj/argo-cd/v3/common.gitCommit=b4accc482028fd529b3e4508ef9f28977b552b50 \
      -X github.com/argoproj/argo-cd/v3/common.gitTreeState=clean \
      -X github.com/argoproj/argo-cd/v3/common.gitTag=v3.6.3 \
      -X github.com/argoproj/argo-cd/v3/common.kubectlVersion=v0.37.0" \
      -o /out/argocd ./cmd
# Fail closed on a stale toolchain: `go version <binary>` reads the toolchain recorded in the binary.
RUN v=$(go version /out/argocd | awk '{print $2}') && echo "argocd built with $v" && \
    [ "$(printf '%s\n%s\n' go1.27.4 "$v" | sort -V | head -n1)" = go1.27.4 ] || \
    { echo "argocd was built with '$v', older than the go1.27.4 floor" >&2; exit 1; }
# Fail closed on a CVE floor that did not reach the binary: Dockerfile.vendor raises each module in the module graph
# (strategies/argocd.json dep_bumps); `go version -m` lists the modules actually linked in (a replace `=>` line wins over
# its dep line). A module the binary does not link has nothing to raise. Each build stage below checks its own binary.
RUN binfloor() { b=$1; shift; go version -m "$b" > /tmp/buildinfo || return 1; while [ $# -gt 1 ]; do \
        v=$(awk -v m="$1" '$1=="dep"{d=($2==m); if(d)v=$3; next} $1=="=>"&&d{v=$3} END{print v}' /tmp/buildinfo); \
        if [ -n "$v" ] && [ "$(printf '%s\n%s\n' "$2" "$v" | sort -V | head -n1)" != "$2" ]; then \
          echo "$b links $1 $v, below its CVE minimum $2" >&2; return 1; fi; echo "$b: $1 ${v:-not linked}"; shift 2; done; } && \
    binfloor /out/argocd github.com/go-git/go-git/v5 v5.19.2 google.golang.org/grpc v1.83.2 golang.org/x/crypto v0.56.0 \
      golang.org/x/net v0.62.0 golang.org/x/text v0.41.0 oras.land/oras-go/v2 v2.6.2 github.com/klauspost/compress v1.20.2 \
      github.com/go-jose/go-jose/v4 v4.1.6 \
      go.opentelemetry.io/otel v1.47.0 \
      go.opentelemetry.io/otel/trace v1.47.0 \
      go.opentelemetry.io/otel/sdk v1.47.0 \
      go.opentelemetry.io/otel/metric v1.47.0 \
      go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.47.0 \
      go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc v1.47.0
RUN /out/argocd version --client --short | tee /tmp/argocd.version && grep -q 'v3\.6\.3' /tmp/argocd.version

FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS helm-build
WORKDIR /helm
COPY vendored/helm-src/ .
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off
RUN go build -trimpath -ldflags "-s -w \
      -X helm.sh/helm/v4/internal/version.version=v4.3.2 \
      -X helm.sh/helm/v4/internal/version.gitCommit=8346aaa55e7161f7c547212d0a87f01367976727 \
      -X helm.sh/helm/v4/internal/version.gitTreeState=clean" \
      -o /out/helm ./cmd/helm && \
    /out/helm version | grep -q 'v4\.3\.2'
RUN binfloor() { b=$1; shift; go version -m "$b" > /tmp/buildinfo || return 1; while [ $# -gt 1 ]; do \
        v=$(awk -v m="$1" '$1=="dep"{d=($2==m); if(d)v=$3; next} $1=="=>"&&d{v=$3} END{print v}' /tmp/buildinfo); \
        if [ -n "$v" ] && [ "$(printf '%s\n%s\n' "$2" "$v" | sort -V | head -n1)" != "$2" ]; then \
          echo "$b links $1 $v, below its CVE minimum $2" >&2; return 1; fi; echo "$b: $1 ${v:-not linked}"; shift 2; done; } && \
    binfloor /out/helm google.golang.org/grpc v1.83.2 golang.org/x/crypto v0.56.0 golang.org/x/net v0.62.0 \
      golang.org/x/text v0.41.0 oras.land/oras-go/v2 v2.6.2 github.com/klauspost/compress v1.20.2 github.com/go-jose/go-jose/v4 v4.1.6

FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS kustomize-build
WORKDIR /kz
COPY vendored/kustomize-src/ .
WORKDIR /kz/kustomize
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off
RUN go build -trimpath -ldflags "-s -w \
      -X sigs.k8s.io/kustomize/api/provenance.version=kustomize/v5.8.3 \
      -X sigs.k8s.io/kustomize/api/provenance.gitCommit=6e4452f7b136fb9a261afe60830867a875183a71 \
      -X sigs.k8s.io/kustomize/api/provenance.buildDate=2026-10-08T11:35:59Z" \
      -o /out/kustomize . && \
    /out/kustomize version | grep -q '5\.8\.3'
RUN binfloor() { b=$1; shift; go version -m "$b" > /tmp/buildinfo || return 1; while [ $# -gt 1 ]; do \
        v=$(awk -v m="$1" '$1=="dep"{d=($2==m); if(d)v=$3; next} $1=="=>"&&d{v=$3} END{print v}' /tmp/buildinfo); \
        if [ -n "$v" ] && [ "$(printf '%s\n%s\n' "$2" "$v" | sort -V | head -n1)" != "$2" ]; then \
          echo "$b links $1 $v, below its CVE minimum $2" >&2; return 1; fi; echo "$b: $1 ${v:-not linked}"; shift 2; done; } && \
    binfloor /out/kustomize golang.org/x/crypto v0.56.0 golang.org/x/net v0.62.0 golang.org/x/text v0.41.0 \
      github.com/go-jose/go-jose/v4 v4.1.6 github.com/klauspost/compress v1.20.2

FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS gitlfs-build
WORKDIR /lfs
COPY vendored/gitlfs-src/ .
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off
RUN go build -trimpath -ldflags "-s -w \
      -X github.com/git-lfs/git-lfs/v3/config.GitCommit=a662a6dbfedf706cfa9fc7a5b7bcc7ba2e2c8a65" \
      -o /out/git-lfs . && \
    /out/git-lfs version | grep -q '3\.8\.1'
RUN binfloor() { b=$1; shift; go version -m "$b" > /tmp/buildinfo || return 1; while [ $# -gt 1 ]; do \
        v=$(awk -v m="$1" '$1=="dep"{d=($2==m); if(d)v=$3; next} $1=="=>"&&d{v=$3} END{print v}' /tmp/buildinfo); \
        if [ -n "$v" ] && [ "$(printf '%s\n%s\n' "$2" "$v" | sort -V | head -n1)" != "$2" ]; then \
          echo "$b links $1 $v, below its CVE minimum $2" >&2; return 1; fi; echo "$b: $1 ${v:-not linked}"; shift 2; done; } && \
    binfloor /out/git-lfs golang.org/x/crypto v0.56.0 golang.org/x/net v0.62.0 golang.org/x/text v0.41.0 \
      github.com/go-jose/go-jose/v4 v4.1.6 github.com/klauspost/compress v1.20.2

# k3s v1.37.2+k3s1 ./cmd/server built from source: upstream scripts/build's k3s step (same package, same version
# stamps, CGO for kine's sqlite). The release binary is not used: it is a self-extracting wrapper whose payload (the
# server binary that actually runs) is upstream's go1.26.8 build with stale x/crypto/x/net/x/mod, hidden from scanners.
# buildDate is the k3s tag commit's committer date, not the wall clock. Tags = upstream's linux set minus three that
# need C libraries the pinned builder does not carry: static_build + libsqlite3 (a static musl link against the
# system sqlite; here mattn/go-sqlite3's bundled amalgamation, dynamically linked to glibc) and seccomp (libseccomp,
# used only by containerd/runc on the agent side, which never runs under --disable-agent).
FROM golang:1.27.4-bookworm@sha256:4fa7c968ba93f1635670522dbb01a2c78150443e1385746924566079f36570ea AS k3s-build
WORKDIR /k3s
COPY vendored/k3s-src/ .
ENV CGO_ENABLED=1 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off
RUN CGO_CFLAGS="-DSQLITE_ENABLE_DBSTAT_VTAB=1 -DSQLITE_USE_ALLOCA=1" go build -trimpath \
      -tags "ctrd netcgo osusergo providerless urfave_cli_no_docs sqlite_omit_load_extension apparmor selinux" \
      -ldflags "-s -w \
      -X github.com/k3s-io/k3s/pkg/version.Version=v1.37.2+k3s1 \
      -X github.com/k3s-io/k3s/pkg/version.GitCommit=f6973cb8 \
      -X k8s.io/client-go/pkg/version.gitVersion=v1.37.2+k3s1 \
      -X k8s.io/client-go/pkg/version.gitCommit=f6973cb850e9b245585363d15bde80904ac862fd \
      -X k8s.io/client-go/pkg/version.gitTreeState=clean \
      -X k8s.io/client-go/pkg/version.buildDate=2026-10-29T22:47:29Z \
      -X k8s.io/component-base/version.gitVersion=v1.37.2+k3s1 \
      -X k8s.io/component-base/version.gitCommit=f6973cb850e9b245585363d15bde80904ac862fd \
      -X k8s.io/component-base/version.gitTreeState=clean \
      -X k8s.io/component-base/version.buildDate=2026-10-29T22:47:29Z \
      -X sigs.k8s.io/cri-tools/pkg/version.Version=v1.37.0-k3s1 \
      -X github.com/containerd/containerd/v2/version.Version=v2.3.7-k3s1 \
      -X github.com/containerd/containerd/v2/version.Package=github.com/k3s-io/containerd/v2 \
      -X github.com/cloudnativelabs/kube-router/v2/pkg/version.Version=v2.11.1-k3s1 \
      -X github.com/cloudnativelabs/kube-router/v2/pkg/version.BuildDate=2026-10-29T22:47:29Z \
      -X github.com/Mirantis/cri-dockerd/cmd/version.Version=v0.3.19-k3s5 \
      -X github.com/Mirantis/cri-dockerd/cmd/version.GitCommit=HEAD \
      -X github.com/Mirantis/cri-dockerd/cmd/version.BuildTime=2026-10-29T22:47:29Z \
      -X go.etcd.io/etcd/api/v3/version.GitSHA=HEAD \
      -X github.com/k3s-io/helm-controller/pkg/controllers/chart.DefaultJobImage=rancher/klipper-helm:v0.13.3-build20261021" \
      -o /out/k3s ./cmd/server
RUN v=$(go version /out/k3s | awk '{print $2}') && echo "k3s built with $v" && \
    [ "$(printf '%s\n%s\n' go1.27.4 "$v" | sort -V | head -n1)" = go1.27.4 ] || \
    { echo "k3s was built with '$v', older than the go1.27.4 floor" >&2; exit 1; }
RUN binfloor() { b=$1; shift; go version -m "$b" > /tmp/buildinfo || return 1; while [ $# -gt 1 ]; do \
        v=$(awk -v m="$1" '$1=="dep"{d=($2==m); if(d)v=$3; next} $1=="=>"&&d{v=$3} END{print v}' /tmp/buildinfo); \
        if [ -n "$v" ] && [ "$(printf '%s\n%s\n' "$2" "$v" | sort -V | head -n1)" != "$2" ]; then \
          echo "$b links $1 $v, below its CVE minimum $2" >&2; return 1; fi; echo "$b: $1 ${v:-not linked}"; shift 2; done; } && \
    binfloor /out/k3s golang.org/x/crypto v0.56.0 golang.org/x/net v0.62.0 golang.org/x/mod v0.40.0 golang.org/x/text v0.41.0 \
      google.golang.org/grpc v1.83.2 github.com/go-jose/go-jose/v4 v4.1.6 github.com/klauspost/compress v1.20.2 \
      github.com/nats-io/nats-server/v2 v2.14.3 \
      github.com/pion/dtls/v3 v3.1.4 \
      github.com/pion/stun/v3 v3.1.5 \
      github.com/quic-go/webtransport-go v0.11.1 \
      go.opentelemetry.io/otel v1.47.0 \
      go.opentelemetry.io/otel/trace v1.47.0 \
      go.opentelemetry.io/otel/sdk v1.47.0 \
      go.opentelemetry.io/otel/metric v1.47.0
# kubectl is dispatched by argv[0] (the server binary's `k3s kubectl` subcommand only works behind the wrapper).
RUN /out/k3s --version | tee /tmp/k3s.version && grep -q 'k3s version v1\.37\.2+k3s1 (f6973cb8)' /tmp/k3s.version && \
    ln -s k3s /out/kubectl && /out/kubectl version --client | grep -q 'v1\.37\.2+k3s1' && rm /out/kubectl

FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289
ENV DEBIAN_FRONTEND=noninteractive
# Reproducibility: /etc/shadow field 3 is days-since-epoch AT BUILD TIME, written by every RUN that adds a user: the
# dpkg RUN below (redis-tools' postinst adds the redis user) and the argocd user's RUN. An image layer is the bytes its
# own RUN left, so each of those RUNs must see SOURCE_DATE_EPOCH (noble's useradd then stamps the epoch's day) and
# freeze the file itself: a freeze in a later RUN replaces /etc/shadow in the filesystem but not in the earlier layer.
# Chain 981 (r2): the dpkg RUN ran before this ARG, so its layer carried the build day; the image built on 2026-11-11
# and G8's rebuild of the sale tar on 2026-11-12 differed in that one file (redis:!:20768 vs redis:!:20769), and r1's
# layer carries its build day 20766 under a SOURCE_DATE_EPOCH of day 20761. ARG, never ENV: an ENV would persist into
# the image config and change the digest.
ARG SOURCE_DATE_EPOCH=1795614817
# Offline apt: dpkg-install the vendored closure (CVE upgrades + runtime packages) with no network.
# A Pre-Depends is only met by a CONFIGURED package, so each pass installs one more level of the
# python3.12-minimal -> python3-minimal -> python3 chain; --skip-same-version keeps a later pass from
# re-unpacking (un-configuring) what an earlier one finished. Two blind passes left python3 never
# installed and supervisor + python3-pkg-resources unconfigured (no /etc/supervisor/supervisord.conf,
# so a bare `supervisorctl status` failed), hidden by the `|| true`. Now fail closed: every package ii.
# The installed apt, libapt-pkg6.0t64 and libpcre2-8-0 must meet strategies/argocd.json apt_refresh (CVE-2026-109518 and
# the pcre2 mediums): a stale vendored/debs fails here instead of shipping the base's older packages.
# The removed paths are wall-clock or host-derived (dpkg/apt logs, the ldconfig aux-cache).
# vendored/debs: bind-mounted (read-only), so never a layer of the image (kit migration vendored-bind-mount)
RUN --mount=type=bind,source=vendored/debs,target=/tmp/debs \
    for pass in 1 2 3 4 5; do dpkg -i --skip-same-version /tmp/debs/*.deb >/dev/null 2>&1 && break; done; \
    dpkg --configure -a && \
    bad=$(dpkg-query -W -f='${db:Status-Abbrev} ${Package}\n' | awk '$1 != "ii"') && \
    { [ -z "$bad" ] || { echo "packages not fully installed: $bad" >&2; exit 1; }; } && \
    for m in apt=2.8.4ubuntu0.1 libapt-pkg6.0t64=2.8.4ubuntu0.1 libpcre2-8-0=10.42-4ubuntu2.2; do p=${m%%=*} v=${m#*=}; \
      dpkg --compare-versions "$(dpkg-query -W -f='${Version}' "$p" 2>/dev/null)" ge "$v" || \
        { echo "$p is below $v, the CVE minimum of strategies/argocd.json apt_refresh" >&2; exit 1; }; done && \
    rm -rf /var/lib/apt/lists/* \
           /var/log/dpkg.log /var/log/alternatives.log /var/log/apt \
           /var/cache/ldconfig/aux-cache /var/cache/fontconfig && \
    : "${SOURCE_DATE_EPOCH:?SOURCE_DATE_EPOCH must be set for a reproducible build}" && \
    sed -ri "s/^([^:]*:[^:]*):[0-9]*:/\\1:$((SOURCE_DATE_EPOCH/86400)):/" /etc/shadow && \
    rm -f /etc/passwd- /etc/shadow- /etc/group- /etc/gshadow-
# argocd runs as uid/gid 999 like upstream. /etc/sub{u,g}id + uidmap give rootless k3s its user
# namespace; its state, kubeconfig, runtime dir and logs all live under $HOME. /app/config is
# upstream's argocd-base layout (ssh known_hosts, tls, gpg keys).
RUN groupadd -g 999 argocd && useradd -r -u 999 -g argocd -d /home/argocd -m argocd && \
    echo 'argocd:100000:65536' > /etc/subuid && echo 'argocd:100000:65536' > /etc/subgid && \
    mkdir -p /home/argocd/.rancher/k3s/data /home/argocd/.kube /home/argocd/run /home/argocd/log \
             /opt/argocd /app/config/ssh /app/config/tls /app/config/gpg/source /app/config/gpg/keys /data && \
    touch /app/config/ssh/ssh_known_hosts && ln -sf /app/config/ssh/ssh_known_hosts /etc/ssh/ssh_known_hosts && \
    chown -R 999:999 /home/argocd /app/config/gpg/keys /data && chmod 700 /home/argocd/run /app/config/gpg/keys && \
    : "${SOURCE_DATE_EPOCH:?SOURCE_DATE_EPOCH must be set for a reproducible build}" && \
    sed -ri "s/^([^:]*:[^:]*):[0-9]*:/\\1:$((SOURCE_DATE_EPOCH/86400)):/" /etc/shadow && \
    rm -f /etc/passwd- /etc/shadow- /etc/group- /etc/gshadow-
COPY --from=argocd-build /out/argocd /usr/local/bin/argocd
COPY --from=helm-build /out/helm /usr/local/bin/helm
COPY --from=kustomize-build /out/kustomize /usr/local/bin/kustomize
COPY --from=gitlfs-build /out/git-lfs /usr/local/bin/git-lfs
# The k3s server binary lives in /usr/local/lib/k3s; /usr/local/bin/k3s is k3s-cli.sh, which keeps `k3s kubectl ...`
# (documented for this appliance) working by handing it to the kubectl argv[0] link, as the release wrapper did.
COPY --from=k3s-build /out/k3s /usr/local/lib/k3s/k3s
COPY --chmod=0755 k3s-cli.sh /usr/local/bin/k3s
COPY --chmod=0755 vendored/argocd-src/hack/gpg-wrapper.sh vendored/argocd-src/hack/git-verify-wrapper.sh /usr/local/bin/
COPY --chmod=0755 bootstrap.sh /usr/local/bin/bootstrap.sh
COPY --chmod=0644 vendored/argocd-src/manifests/install.yaml /opt/argocd/install.yaml
COPY --chmod=0644 supervisord.conf /etc/supervisor/conf.d/argocd.conf
# One binary, dispatched by argv[0] (upstream's final stage makes the same links). /etc/gitconfig gets the
# LFS filters that upstream's argocd-base writes with `git lfs install --system`, but in a FIXED order: git-lfs
# sets them by ranging over a Go map (lfs/attribute.go filterAttribute), so the key order, and with it this
# layer's digest, changes between builds (chain 414's canonical build and its bit-for-bit rebuild differed in
# exactly this file, 2026-10-21). The four keys are written in git-lfs's source order, then `git lfs install
# --system` runs as a check: it rewrites nothing when every value is already right, and it fails when one is
# wrong, so `cmp` proves the file is exactly what git-lfs itself would accept. A bare `supervisorctl status`
# reads /etc/supervisord.conf before the package's /etc/supervisor/supervisord.conf (whose socket is
# /var/run/supervisor.sock), so the link points it at the config supervisord runs with.
RUN for c in argocd-server argocd-repo-server argocd-cmp-server argocd-application-controller argocd-dex \
             argocd-dex-server argocd-notifications argocd-notifications-controller argocd-applicationset-controller \
             argocd-k8s-auth argocd-commit-server; do ln -s /usr/local/bin/argocd /usr/local/bin/$c; done && \
    ln -s /usr/local/lib/k3s/k3s /usr/local/bin/kubectl && \
    ln -s /etc/supervisor/conf.d/argocd.conf /etc/supervisord.conf && \
    git config --system filter.lfs.clean 'git-lfs clean -- %f' && \
    git config --system filter.lfs.smudge 'git-lfs smudge -- %f' && \
    git config --system filter.lfs.process 'git-lfs filter-process' && \
    git config --system filter.lfs.required true && \
    cp /etc/gitconfig /tmp/gitconfig.want && git lfs install --system && \
    cmp /etc/gitconfig /tmp/gitconfig.want && rm /tmp/gitconfig.want
ENV HOME=/home/argocd XDG_RUNTIME_DIR=/home/argocd/run KUBECONFIG=/home/argocd/.kube/config \
    USER=argocd GRPC_ENABLE_TXT_SERVICE_CONFIG=false
HEALTHCHECK --interval=30s --timeout=10s --start-period=180s --retries=3 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:8080/healthz || exit 1
EXPOSE 8080
WORKDIR /home/argocd
USER 999
ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/argocd.conf"]
# >>> readystack OCI labels: strategies/argocd.json image_labels plus the standard OCI labels,
# the set a generated kit carries (gen_dockerfile.label_lines). Written by scripts/kit_migrations.py;
# scripts/retarget.py re-renders it with every retarget. Never edit it by hand.
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.title="Argo CD"
LABEL org.opencontainers.image.source="https://github.com/argoproj/argo-cd.git"
LABEL org.opencontainers.image.version="v3.6.3-CE-ubuntu24.04-r1"
LABEL org.opencontainers.image.revision="b4accc482028fd529b3e4508ef9f28977b552b50"
# <<< readystack OCI labels

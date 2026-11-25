#!/usr/bin/env bash
export HOME=/home/argocd
export KUBECONFIG=/home/argocd/.kube/config
for i in $(seq 1 60); do
  /usr/local/bin/k3s kubectl get --raw /healthz 2>/dev/null | grep -q ok && break
  sleep 3
done
echo "k3s API ready; applying argocd config (server-side)"
/usr/local/bin/k3s kubectl create namespace argocd 2>/dev/null || true
/usr/local/bin/k3s kubectl apply -n argocd --server-side --force-conflicts -f /opt/argocd/install.yaml 2>&1 | tail -2
/usr/local/bin/k3s kubectl config set-context --current --namespace=argocd 2>/dev/null
/usr/local/bin/k3s kubectl wait --for condition=established --timeout=60s crd/applications.argoproj.io 2>/dev/null || true
echo "bootstrap done"

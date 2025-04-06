#!/bin/bash

set -euo pipefail

NAMESPACE="kube-system"
RELEASE_NAME="cilium"

echo "🔍 Verificando instalação do Cilium..."
helm status "$RELEASE_NAME" -n "$NAMESPACE" || {
  echo "❌ Cilium não está instalado via Helm no namespace $NAMESPACE."
  exit 1
}

echo "🔧 Desabilitando Hubble no Cilium via Helm upgrade..."
helm upgrade "$RELEASE_NAME" cilium/cilium \
  --namespace "$NAMESPACE" \
  --reuse-values \
  --set hubble.enabled=false \
  --set hubble.relay.enabled=false \
  --set hubble.ui.enabled=false \
  --set envoy.enabled=false

echo "✅ Hubble desativado com sucesso!"

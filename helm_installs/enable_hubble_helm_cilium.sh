#!/bin/bash

set -euo pipefail

# Configurações
NAMESPACE="kube-system"
RELEASE_NAME="cilium"

echo "🔍 Verificando instalação atual do Cilium..."
helm status "$RELEASE_NAME" -n "$NAMESPACE" || {
  echo "❌ Cilium não está instalado via Helm no namespace $NAMESPACE."
  exit 1
}

echo "🔍 Exportando valores atuais do Helm release..."
helm get values "$RELEASE_NAME" -n "$NAMESPACE" -o yaml > /tmp/cilium-values.yaml

echo "🛠️ Corrigindo valores obrigatórios com merge via yq (incluindo limites de memória para Envoy)..."
yq eval '
  .hubble.enabled = true |
  .hubble.relay.enabled = true |
  .hubble.ui.enabled = true |
  .envoy.enabled = true |
  .envoy.config.enabled = true |
  .envoy.resources.limits.memory = "256Mi" |
  .envoy.resources.requests.memory = "128Mi" |
  .imagePullSecrets = [] |
  .authentication.mutual.spire.install.server.image = {"repository": "", "tag": ""} |
  .authentication.mutual.spire.install.agent.image = {"repository": "", "tag": ""} |
  .clustermesh.apiserver.service.externalTrafficPolicy = "Cluster" |
  .clustermesh.apiserver.service.internalTrafficPolicy = "Cluster"
' /tmp/cilium-values.yaml > /tmp/cilium-values-hubble.yaml

echo "🚀 Executando upgrade do Cilium com os valores corrigidos..."
helm upgrade "$RELEASE_NAME" cilium/cilium -n "$NAMESPACE" -f /tmp/cilium-values-hubble.yaml

echo "✅ Hubble ativado com sucesso!"

# (Opcional) Instalar a CLI do Hubble
echo "📥 Instalando Hubble CLI (opcional)..."
ARCH=$(uname -m)
case $ARCH in
  x86_64) HUBBLE_CLI_URL="https://github.com/cilium/hubble/releases/latest/download/hubble-linux-amd64.tar.gz" ;;
  aarch64 | arm64) HUBBLE_CLI_URL="https://github.com/cilium/hubble/releases/latest/download/hubble-linux-arm64.tar.gz" ;;
  *) echo "❌ Arquitetura $ARCH não suportada para Hubble CLI."; exit 1 ;;
esac

curl -L "$HUBBLE_CLI_URL" -o /tmp/hubble.tar.gz
tar -xzvf /tmp/hubble.tar.gz -C /tmp
chmod +x /tmp/hubble
# mv /tmp/hubble /usr/local/bin/hubble
echo "⚠️ Hubble CLI está em /tmp/hubble — será movido via Ansible com sudo se desejar."

echo "✅ Hubble CLI instalado com sucesso! Use 'hubble observe' ou 'hubble status' para testar."

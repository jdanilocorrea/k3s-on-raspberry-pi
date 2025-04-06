#!/bin/bash

set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

echo "🔍 Verificando se o Helm está instalado..."
if ! command -v helm &> /dev/null; then
    echo "❌ Helm não encontrado. Instale o Helm antes de continuar."
    exit 1
fi
echo "✅ Helm encontrado."

echo "🔍 Verificando se o kubectl está instalado..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl não encontrado. Instale o kubectl antes de continuar."
    exit 1
fi
echo "✅ kubectl encontrado."

echo "🔧 Criando namespace 'monitoring' se não existir..."
kubectl get ns monitoring &> /dev/null || kubectl create ns monitoring

echo "➕ Adicionando repositório Helm da Grafana..."
helm repo add grafana https://grafana.github.io/helm-charts || true

echo "🔄 Atualizando repositórios Helm..."
helm repo update

echo "📦 Instalando ou atualizando Loki Stack com Promtail (sem Grafana)..."
helm upgrade --install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set promtail.enabled=true

echo "✅ Instalação ou atualização do Loki + Promtail concluída com sucesso!"

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

echo "✅ Loki Stack instalado com sucesso!"

# 📁 Provisionando datasource Loki no Grafana
echo "📁 Criando datasource Loki no Grafana (sem isDefault)..."

DATASOURCE_DIR="/etc/grafana/provisioning/datasources"
sudo mkdir -p "$DATASOURCE_DIR"

sudo tee "$DATASOURCE_DIR/loki.yaml" > /dev/null <<EOF
apiVersion: 1
datasources:
  - name: Loki
    type: loki
    access: proxy
    url: http://loki.monitoring.svc.cluster.local:3100
    isDefault: false
    jsonData:
      maxLines: 1000
EOF

echo "✅ Datasource Loki provisionado (isDefault: false)"

# 🔁 Reiniciar o Grafana para aplicar o datasource
echo "🔄 Reiniciando Grafana para aplicar datasource..."
sudo systemctl restart grafana-server || sudo docker restart grafana || true

echo "🎉 Finalizado com sucesso!"

#!/usr/bin/env bash
set -euo pipefail

# Cores para mensagens
BLUE='\033[1;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 Verificando se Helm está instalado...${NC}"
if ! command -v helm &>/dev/null; then
  echo -e "${RED}❌ Helm não encontrado. Instale com: sudo apt install helm ou brew install helm${NC}"
  exit 1
fi

echo -e "${BLUE}🔍 Verificando se kubectl está instalado...${NC}"
if ! command -v kubectl &>/dev/null; then
  echo -e "${RED}❌ kubectl não encontrado. Instale com: sudo apt install kubectl ou brew install kubectl${NC}"
  exit 1
fi

echo -e "${BLUE}➕ Adicionando repositório Helm do KubeCost...${NC}"
if ! helm repo list | grep -q "kubecost"; then
  helm repo add kubecost https://kubecost.github.io/cost-analyzer/
else
  echo -e "${GREEN}✔ Repositório kubecost já existe — pulando${NC}"
fi

echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update

echo -e "${BLUE}📁 Criando namespace 'kubecost' (se necessário)...${NC}"
kubectl create namespace kubecost --dry-run=client -o yaml | kubectl apply -f -

echo -e "${BLUE}🚀 Instalando KubeCost via Helm...${NC}"
helm upgrade --install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --set kubecostToken="cluster-rpi-k3s" \
  --set prometheus.kubeStateMetrics.enabled=false \
  --set prometheus.nodeExporter.enabled=false \
  --set global.prometheus.enabled=false

echo -e "${GREEN}✅ KubeCost instalado com sucesso no namespace 'kubecost'!${NC}"




# #!/usr/bin/env bash
# set -euo pipefail

# # Cores
# BLUE='\033[1;34m'
# GREEN='\033[0;32m'
# YELLOW='\033[1;33m'
# RED='\033[0;31m'
# NC='\033[0m'

# # Cluster config
# KUBECOST_NAMESPACE="kubecost"
# KUBECOST_TOKEN="cluster-rpi-k3s"
# PROMETHEUS_URL="http://monitoring-kube-prometheus-prometheus.monitoring.svc:9090"

# # Verificação de dependências
# echo -e "${BLUE}🔍 Verificando dependências...${NC}"

# for cmd in helm kubectl; do
#   if ! command -v "$cmd" &>/dev/null; then
#     echo -e "${RED}❌ '$cmd' não encontrado. Instale com: sudo apt install $cmd${NC}"
#     exit 1
#   fi
# done

# # Adiciona repositório Helm
# echo -e "${BLUE}➕ Verificando repositório Helm do Kubecost...${NC}"
# if ! helm repo list | grep -q "kubecost"; then
#   helm repo add kubecost https://kubecost.github.io/cost-analyzer/
#   echo -e "${GREEN}✔ Repositório Kubecost adicionado.${NC}"
# else
#   echo -e "${YELLOW}ℹ️  Repositório Kubecost já existe. Pulando.${NC}"
# fi

# echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
# helm repo update

# # Criação do namespace
# echo -e "${BLUE}📁 Criando namespace '${KUBECOST_NAMESPACE}' (se necessário)...${NC}"
# kubectl create namespace "$KUBECOST_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# # Testa conectividade com Prometheus
# echo -e "${BLUE}🌐 Testando conexão com o Prometheus em: ${PROMETHEUS_URL}${NC}"
# kubectl run --rm -i --tty curl-prom --image=curlimages/curl --restart=Never \
#   -- curl -s -o /dev/null -w "%{http_code}" "$PROMETHEUS_URL/api/v1/status/buildinfo" | grep -q "200" \
#   && echo -e "${GREEN}✔ Conexão com Prometheus bem-sucedida.${NC}" \
#   || { echo -e "${RED}❌ Falha ao se conectar ao Prometheus. Verifique a URL e conectividade dentro do cluster.${NC}"; exit 1; }

# # Instalação do Kubecost via Helm
# echo -e "${BLUE}🚀 Instalando Kubecost via Helm...${NC}"

# helm upgrade --install kubecost kubecost/cost-analyzer \
#   --namespace "$KUBECOST_NAMESPACE" \
#   --create-namespace \
#   --set kubecostToken="$KUBECOST_TOKEN" \
#   --set global.prometheus.enabled=false \
#   --set global.prometheus.fqdn="$PROMETHEUS_URL" \
#   --set prometheus.nodeExporter.enabled=false \
#   --set prometheus.kubeStateMetrics.enabled=false \
#   --set prometheus.kube-state-metrics.enabled=false \
#   --wait --timeout=10m || {
#     echo -e "${RED}❌ Falha ao instalar o Kubecost.${NC}"
#     exit 1
#   }

# # Aguarda o Pod principal ficar pronto
# echo -e "${BLUE}⏳ Aguardando pod 'kubecost-cost-analyzer' ficar pronto...${NC}"
# kubectl wait --namespace "$KUBECOST_NAMESPACE" \
#   --for=condition=ready pod \
#   --selector=app=kubecost-cost-analyzer \
#   --timeout=180s && \
#   echo -e "${GREEN}✅ Kubecost instalado com sucesso e pronto para uso!${NC}" \
#   || echo -e "${YELLOW}⚠️ Pod não ficou pronto no tempo esperado. Verifique com: kubectl get pods -n $KUBECOST_NAMESPACE${NC}"

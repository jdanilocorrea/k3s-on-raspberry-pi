#!/usr/bin/env bash
set -euo pipefail

# Cores para mensagens
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

export KUBECONFIG="$HOME/.kube/config"

echo -e "${BLUE}🔍 Verificando se Helm está instalado...${NC}"
if ! command -v helm &>/dev/null; then
  echo -e "${RED}❌ Helm não está instalado. Instale com: brew install helm${NC}"
  exit 1
fi

# 1️⃣ Adicionar repositórios Helm necessários
echo -e "${BLUE}➕ Adicionando repositório Helm: prometheus-community...${NC}"
if ! helm repo list | grep -q "prometheus-community"; then
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || {
    echo -e "${RED}❌ Falha ao adicionar repositório prometheus-community${NC}"
    exit 1
  }
else
  echo -e "${GREEN}✔ Repositório prometheus-community já existe — pulando${NC}"
fi

echo -e "${BLUE}➕ Adicionando repositório Helm: grafana...${NC}"
if ! helm repo list | grep -q "grafana"; then
  helm repo add grafana https://grafana.github.io/helm-charts || {
    echo -e "${RED}❌ Falha ao adicionar repositório grafana${NC}"
    exit 1
  }
else
  echo -e "${GREEN}✔ Repositório grafana já existe — pulando${NC}"
fi

# 🔄 Atualizando repositórios
echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update || {
  echo -e "${RED}❌ Falha ao atualizar repositórios Helm${NC}"
  exit 1
}

# 2️⃣ Criar o arquivo de configuração do Grafana para incluir o Loki
cat <<EOF > grafana-values.yaml
grafana:
  additionalDataSources:
    - name: Loki
      type: loki
      access: proxy
      url: http://loki.monitoring.svc.cluster.local:3100
      isDefault: false
      editable: true
EOF

echo -e "${BLUE}📝 Arquivo grafana-values.yaml criado com sucesso${NC}"

# 3️⃣ Instalar o kube-prometheus-stack com o Loki como Data Source no Grafana
echo -e "${BLUE}🚀 Instalando kube-prometheus-stack (Prometheus + Grafana)...${NC}"
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f grafana-values.yaml || {
  echo -e "${RED}❌ Falha ao instalar kube-prometheus-stack${NC}"
  exit 1
}

echo -e "${GREEN}✅ Monitoramento (Prometheus + Grafana) instalado com Loki configurado no Grafana!${NC}"



# #!/usr/bin/env bash
# set -euo pipefail

# # Cores para mensagens
# GREEN='\033[0;32m'
# RED='\033[0;31m'
# BLUE='\033[1;34m'
# NC='\033[0m'

# export KUBECONFIG="$HOME/.kube/config"

# echo -e "${BLUE}🔍 Verificando se Helm está instalado...${NC}"
# if ! command -v helm &>/dev/null; then
#   echo -e "${RED}❌ Helm não está instalado. Instale com: brew install helm${NC}"
#   exit 1
# fi

# # 1️⃣ Adicionar repositórios Helm necessários
# echo -e "${BLUE}➕ Adicionando repositório Helm: prometheus-community...${NC}"
# if ! helm repo list | grep -q "prometheus-community"; then
#   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || {
#     echo -e "${RED}❌ Falha ao adicionar repositório prometheus-community${NC}"
#     exit 1
#   }
# else
#   echo -e "${GREEN}✔ Repositório prometheus-community já existe — pulando${NC}"
# fi

# echo -e "${BLUE}➕ Adicionando repositório Helm: grafana...${NC}"
# if ! helm repo list | grep -q "grafana"; then
#   helm repo add grafana https://grafana.github.io/helm-charts || {
#     echo -e "${RED}❌ Falha ao adicionar repositório grafana${NC}"
#     exit 1
#   }
# else
#   echo -e "${GREEN}✔ Repositório grafana já existe — pulando${NC}"
# fi

# # 🔄 Atualizando repositórios
# echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
# helm repo update || {
#   echo -e "${RED}❌ Falha ao atualizar repositórios Helm${NC}"
#   exit 1
# }

# # 2️⃣ Instalar o kube-prometheus-stack
# echo -e "${BLUE}🚀 Instalando kube-prometheus-stack (Prometheus + Grafana)...${NC}"
# helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
#   --namespace monitoring --create-namespace || {
#   echo -e "${RED}❌ Falha ao instalar kube-prometheus-stack${NC}"
#   exit 1
# }

# echo -e "${GREEN}✅ Monitoramento (Prometheus + Grafana) instalado com sucesso!${NC}"

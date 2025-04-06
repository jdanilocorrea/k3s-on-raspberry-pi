#!/usr/bin/env bash
set -euo pipefail

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

timestamp() { date +"[%H:%M:%S]"; }

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
NAMESPACE="argocd"
RELEASE_NAME="argocd"
CHART_REPO="https://argoproj.github.io/argo-helm"

# 1. Verifica dependências
check() {
  if ! command -v "$1" &>/dev/null; then
    echo -e "$(timestamp) ${RED}❌ '$1' não encontrado. Instale com: sudo apt install $1${NC}"
    exit 1
  fi
}
check helm
check kubectl

# 2. Cria namespace se não existir
echo -e "$(timestamp) ${BLUE}📁 Verificando namespace '$NAMESPACE'...${NC}"
kubectl get ns "$NAMESPACE" &>/dev/null || kubectl create ns "$NAMESPACE"

# 3. Adiciona repositório Helm
if ! helm repo list | grep -q "argo"; then
  echo -e "$(timestamp) ${BLUE}➕ Adicionando repositório Argo Helm...${NC}"
  helm repo add argo "$CHART_REPO"
fi

echo -e "$(timestamp) ${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update

# 4. Instala ou atualiza o Argo CD com service LoadBalancer (MetalLB)
echo -e "$(timestamp) ${BLUE}🚀 Instalando/Atualizando Argo CD via Helm...${NC}"
helm upgrade --install "$RELEASE_NAME" argo/argo-cd \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set server.service.type=LoadBalancer \
  --set server.ingress.enabled=false \
  --wait --timeout 10m || {
  echo -e "$(timestamp) ${RED}❌ Falha ao instalar o Argo CD${NC}"
  exit 1
}

# 5. Espera o pod principal ficar pronto
echo -e "$(timestamp) ${BLUE}⏳ Aguardando o pod do Argo CD Server ficar pronto...${NC}"
kubectl wait -n "$NAMESPACE" \
  --for=condition=ready pod \
  -l app.kubernetes.io/component=server \
  --timeout=180s || {
  echo -e "$(timestamp) ${RED}❌ Timeout aguardando Argo CD Server${NC}"
  exit 1
}

# 6. Exibe IP atribuído pelo MetalLB
echo -e "$(timestamp) ${BLUE}🌐 IP do Argo CD via MetalLB:${NC}"
kubectl get svc -n "$NAMESPACE" | grep LoadBalancer || echo -e "${YELLOW}⚠️ Nenhum IP atribuído ainda.${NC}"

# 7. Obtém a senha inicial
echo -e "$(timestamp) ${BLUE}🔐 Senha inicial do admin:${NC}"
kubectl get secret -n "$NAMESPACE" argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# 8. Conclusão
echo -e "$(timestamp) ${GREEN}✅ Argo CD instalado com sucesso!${NC}"
echo -e "${BLUE}🔗 Acesse: http://<IP-do-Argo-CD>:80${NC}"

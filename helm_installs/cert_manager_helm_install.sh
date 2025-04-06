#!/usr/bin/env bash
set -euo pipefail

# Cores para mensagens
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

echo -e "${BLUE}🔍 Verificando se o Helm está instalado...${NC}"
if ! command -v helm &>/dev/null; then
  echo -e "${RED}❌ Helm não está instalado. Instale com: brew install helm${NC}"
  exit 1
fi
echo -e "${GREEN}✅ Helm encontrado.${NC}"

echo -e "${BLUE}➕ Adicionando repositório Helm do Cert-Manager (Jetstack)...${NC}"
helm repo add jetstack https://charts.jetstack.io 2>/dev/null || echo -e "${YELLOW}⚠️ Repositório jetstack já existe.${NC}"

echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update

echo -e "${BLUE}🔧 Criando namespace cert-manager se ainda não existir...${NC}"
kubectl get ns cert-manager &>/dev/null || kubectl create ns cert-manager

echo -e "${BLUE}📦 Instalando ou atualizando o Cert-Manager com CRDs via Helm...${NC}"
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true \
  --wait || {
    echo -e "${RED}❌ Falha ao instalar/atualizar Cert-Manager${NC}"
    exit 1
}

echo -e "${GREEN}✅ Cert-Manager instalado/atualizado com sucesso!${NC}"

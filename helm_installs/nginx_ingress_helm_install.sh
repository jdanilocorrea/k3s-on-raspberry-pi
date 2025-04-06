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

echo -e "${BLUE}➕ Adicionando repositório Helm: ingress-nginx...${NC}"
if ! helm repo list | grep -q "ingress-nginx"; then
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || {
    echo -e "${RED}❌ Falha ao adicionar repositório ingress-nginx${NC}"
    exit 1
  }
else
  echo -e "${GREEN}✔ Repositório ingress-nginx já existe — pulando${NC}"
fi

echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update || {
  echo -e "${RED}❌ Falha ao atualizar repositórios Helm${NC}"
  exit 1
}

echo -e "${BLUE}🚀 Instalando Ingress Controller NGINX com Helm...${NC}"
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --timeout=10m \
  --wait || {
  echo -e "${RED}❌ Falha ao instalar Ingress Controller NGINX${NC}"
  exit 1
}

echo -e "${GREEN}✅ Ingress Controller NGINX instalado com sucesso!${NC}"
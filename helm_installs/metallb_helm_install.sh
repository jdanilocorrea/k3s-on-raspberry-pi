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

echo -e "${BLUE}➕ Adicionando repositório Helm: MetalLB...${NC}"
if ! helm repo list | grep -q "metallb"; then
  helm repo add metallb https://metallb.github.io/metallb || {
    echo -e "${RED}❌ Falha ao adicionar repositório MetalLB${NC}"
    exit 1
  }
else
  echo -e "${GREEN}✔ Repositório MetalLB já existe — pulando${NC}"
fi

echo -e "${BLUE}🔄 Atualizando repositórios Helm...${NC}"
helm repo update || {
  echo -e "${RED}❌ Falha ao atualizar repositórios Helm${NC}"
  exit 1
}

echo -e "${BLUE}📦 Verificando/criando namespace 'metallb-system'...${NC}"
if ! kubectl get namespace metallb-system &>/dev/null; then
  kubectl create namespace metallb-system || {
    echo -e "${RED}❌ Falha ao criar namespace metallb-system${NC}"
    exit 1
  }
else
  echo -e "${GREEN}✔ Namespace 'metallb-system' já existe — pulando${NC}"
fi

echo -e "${BLUE}🚀 Instalando MetalLB com Helm...${NC}"
helm upgrade --install metallb metallb/metallb -n metallb-system || {
  echo -e "${RED}❌ Falha ao instalar MetalLB${NC}"
  exit 1
}


echo -e "${GREEN}✅ MetalLB instalado e configurado com sucesso!${NC}"
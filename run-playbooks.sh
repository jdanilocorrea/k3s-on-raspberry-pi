#!/usr/bin/env bash

set -euo pipefail

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

# Verifica se está rodando em Apple Silicon
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    echo -e "${BLUE}ℹ Detecção: Apple Silicon (ARM64 - Mac M1/M2)${NC}"
else
    echo -e "${RED}⚠ Atenção: Este script foi feito para Raspberry PI 4, mas você está usando $ARCH.${NC}"
fi

# Verifica se ansible-playbook está disponível
if ! command -v ansible-playbook &>/dev/null; then
    echo -e "${RED}[ERRO] Ansible não está instalado. Execute: brew install ansible${NC}"
    exit 1
fi

# Verifica se o inventário existe
INVENTORY="hosts"
if [[ ! -f "$INVENTORY" ]]; then
    echo -e "${RED}[ERRO] Arquivo de inventário \"$INVENTORY\" não encontrado.${NC}"
    exit 1
fi

# Lista de playbooks
PLAYBOOKS=(
  "playbooks/01-raspberry-setup-pb.yaml"
  "playbooks/02-k3s-setup-pb.yaml"
  "playbooks/03-labs-ferramentas-aux-pb.yaml"
  "playbooks/04-labs-kubeconfig-pb.yaml"
  "playbooks/05-cilium_helm-install-pb.yaml"
  "playbooks/06-labs-copy-metallb-config.yaml-pb.yaml"
  "playbooks/07-metallb-helm-install-pb.yaml"
  "playbooks/08-nginx-ingress-helm-install-pb.yaml"
  "playbooks/09-prometheus-grafana-monitoring-helm-install-pb.yaml"
  "playbooks/10-labs-install-yq-arm64.yaml"
  "playbooks/11-cert-manager-helm-install-pb.yaml"
  "playbooks/12-loki-helm-install-pb.yaml"
  "playbooks/13-kubecost-helm-install.yaml"
  "playbooks/14-obter-senha-grafana.yaml"
  "playbooks/15-obter-kubeconfig-labs.yaml"
  "playbooks/16-apply-cert-manager-pb.yaml"
  "playbooks/17-argo-helm-install.yaml"
  "playbooks/18-nginx-webserver-helm-install-pb.yaml"
  "playbooks/19-apply-nginx-ingress-controller-pb.yaml"
  
)

echo -e "${BLUE}▶ Iniciando execução dos playbooks...${NC}"

for pb in "${PLAYBOOKS[@]}"; do
    echo -e "${GREEN}🔸 Executando: $pb${NC}"

    if [[ ! -f "$pb" ]]; then
        echo -e "${RED}[ERRO] Playbook \"$pb\" não encontrado.${NC}"
        exit 1
    fi

    ansible-playbook -i "$INVENTORY" "$pb" || {
        echo -e "${RED}[ERRO] Falha ao executar $pb${NC}"
        exit 1
    }

    echo -e "${GREEN}✔ Finalizado com sucesso: $pb${NC}\n"
done

echo -e "${BLUE}✅ Todos os playbooks foram executados com sucesso.${NC}"

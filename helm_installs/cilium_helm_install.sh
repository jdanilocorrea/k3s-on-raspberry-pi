#!/usr/bin/env bash
set -euo pipefail

export KUBECONFIG="$HOME/.kube/config"

echo "🔄 Alterando contexto (se existir)..."
if kubectl config get-contexts | grep -q "k3s-local-raspberry"; then
  kubectx k3s-local-raspberry || { echo "❌ Falha ao trocar contexto"; exit 1; }
else
  echo "⚠ Contexto 'k3s-local-raspberry' não encontrado, usando o atual"
fi

echo "🔍 Verificando nós..."
if ! kubectl get nodes; then
  echo "❌ Falha ao listar nós — verifique se o KUBECONFIG está correto e se o cluster está acessível"
  exit 1
fi

echo "➕ Adicionando repositório Cilium..."
if ! helm repo list | grep -q "cilium"; then
  helm repo add cilium https://helm.cilium.io/ || { echo "❌ Falha ao adicionar repo Cilium"; exit 1; }
else
  echo "⚠ Repositório Cilium já existe — pulando"
fi

echo "🔄 Atualizando repositórios Helm..."
helm repo update || { echo "❌ Falha ao atualizar repositórios"; exit 1; }

echo "🚀 Instalando ou atualizando Cilium com Helm..."
helm upgrade --install cilium cilium/cilium \
  --version 1.14.4 \
  --namespace kube-system \
  --set k8sServiceHost=10.0.10.10 \
  --set k8sServicePort=6443 \
  --set ipam.mode=kubernetes || { echo "❌ Falha ao instalar/atualizar Cilium"; exit 1; }

echo "✅ Script executado com sucesso!"

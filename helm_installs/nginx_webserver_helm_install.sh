#!/bin/bash

set -euo pipefail

NAMESPACE="nginx-web"
RELEASE_NAME="nginx-webserver"

echo "🔧 Adicionando repositório Helm da Bitnami (NGINX Web Server)..."
helm repo add bitnami https://charts.bitnami.com/bitnami || true

echo "🔄 Atualizando repositórios Helm..."
helm repo update

echo "📁 Criando namespace '$NAMESPACE' (se ainda não existir)..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "🚀 Instalando ou atualizando NGINX Web Server via Helm..."
helm upgrade --install "$RELEASE_NAME" bitnami/nginx \
  --namespace "$NAMESPACE" \
  --set service.type=LoadBalancer

echo "✅ NGINX Web Server está instalado no namespace '$NAMESPACE'."

echo "🌐 Verifique o IP externo atribuído (MetalLB ou cloud):"
kubectl get svc -n "$NAMESPACE"

echo "📂 Você pode customizar o conteúdo servindo HTML com ConfigMap ou PVC."

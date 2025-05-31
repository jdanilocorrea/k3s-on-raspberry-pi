# Etapa 4: Instalação do Ingress Controller com suporte a TLS via Cert-Manager

### Objetivo da Etapa:

Instalar e configurar um Ingress Controller baseado no NGINX para gerenciamento das rotas HTTP/HTTPS, com integração ao Cert-Manager para provisionamento automático de certificados TLS no ambiente Bare Metal usando ACME (Let's Encrypt ou CA local).

### 4.1 Instalação do Ingress NGINX com Helm

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local
```

### 4.2 Instalação do Cert-Manager via Helm

```
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true
```

### 4.3 Configuração de ClusterIssuer (Let's Encrypt)

```
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: seu-email@exemplo.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
```

### 4.4 Resultados Esperados:

- Ingress NGINX exposto via MetalLB com IP externo
    
- Certificados TLS provisionados automaticamente para domínios válidos
    
- Serviços do cluster acessíveis de forma segura com HTTPS
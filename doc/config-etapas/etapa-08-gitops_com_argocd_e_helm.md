# Etapa 8: GitOps com ArgoCD e Helm

### Objetivo da Etapa:

Aplicar a metodologia GitOps no cluster Kubernetes utilizando o ArgoCD para gerenciar os recursos declarativos do cluster a partir de repositórios Git, com suporte à instalação de charts Helm e Kustomize, promovendo versionamento, rastreabilidade e CI/CD moderno.

### 8.1 Instalação do ArgoCD com Helm

```
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd -n argocd \
  --set server.service.type=LoadBalancer
```

### 8.2 Configuração de Acesso

- IP externo fornecido pelo MetalLB
    
- Configurar Ingress com domínio `argocd.k3s.loopback.solutions`
    
- Acesso via web UI ou CLI (`argocd login`)
    

### 8.3 Definição de Projetos e Aplicações

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-app
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/usuario/repositorio-k8s
    targetRevision: HEAD
    path: apps/nginx
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 8.4 Resultados Esperados:

- ArgoCD instalado e acessível
    
- Aplicações versionadas e sincronizadas automaticamente
    
- Alterações no Git refletidas no cluster com segurança e rastreabilidade
    
- Automação e governança sobre deploys com rollback, validação e histórico
    

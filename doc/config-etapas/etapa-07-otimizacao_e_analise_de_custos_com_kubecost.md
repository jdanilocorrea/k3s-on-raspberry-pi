# Etapa 7: Otimização e Análise de Custos com KubeCost

### Objetivo da Etapa:

Integrar o KubeCost ao cluster Kubernetes para obter visibilidade financeira, estimativa de custos por namespace, workload e recurso utilizado, promovendo otimização e governança de custos.

### 7.1 Instalação com Helm

```
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
helm install kubecost kubecost/cost-analyzer \
  --namespace monitoring \
  --set kubecostToken="abcdef123456" \
  --set global.prometheus.fqdn="kube-prometheus-stack-prometheus.monitoring.svc"
```

### 7.2 Configuração de Acesso

- Acesse via Ingress configurado com domínio `kubecost.k3s.loopback.solutions`
    
- Visualize custos por:
    
    - Namespace
        
    - Deployment
        
    - PersistentVolume
        
    - Service
        

### 7.3 Métricas e Relatórios

- Gráficos de uso por CPU, memória e armazenamento
    
- Previsão de gastos
    
- Eficiência de utilização dos recursos
    

### 7.4 Resultados Esperados:

- Visibilidade completa de custos operacionais do cluster
    
- Identificação de desperdícios e workloads subutilizados
    
- Base sólida para práticas de FinOps no ambiente Kubernetes
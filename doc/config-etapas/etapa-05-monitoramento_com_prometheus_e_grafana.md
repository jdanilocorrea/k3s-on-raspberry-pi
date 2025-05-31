# Etapa 5: Monitoramento com Prometheus e Grafana

### Objetivo da Etapa:

Implantar uma stack de monitoramento eficaz baseada em Prometheus e Grafana para coletar métricas do cluster, visualizar indicadores de saúde e uso de recursos, e fornecer alertas configuráveis para eventos críticos.

### 5.1 Instalação com Helm

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace
```

### 5.2 Configuração Inicial

- Prometheus configurado para coletar métricas de pods, nodes, containers e serviços
    
- Grafana provisionado com dashboards prontos (Kubernetes / Node / Pod Usage)
    

### 5.3 Exemplo de Dashboard Customizado

- Dashboard criado via ConfigMap com layout refinado (nome: `k8s-pod-resource-usage`)
    
- Importado automaticamente pelo Grafana ao inicializar com provisionamento
    

### 5.4 Alertas Criados (Alertmanager)

- Pod reiniciando repetidamente
    
- Memória acima de 80%
    
- CPU acima de 85%
    
- Disco com menos de 10% disponível
    

### 5.5 Resultados Esperados:

- Visualização clara do estado do cluster e consumo de recursos
    
- Alertas automáticos enviados por e-mail ou outros canais (Slack, Webhook)
    
- Stack configurada de forma profissional, com provisionamento automatizado via Helm
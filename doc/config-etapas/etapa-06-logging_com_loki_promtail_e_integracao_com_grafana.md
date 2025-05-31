# Etapa 6: Logging com Loki, Promtail e integração com Grafana

### Objetivo da Etapa:

Adicionar logging centralizado e estruturado para os pods e serviços do cluster, utilizando Grafana Loki como backend de logs e Promtail como agente de coleta nos nós do cluster.

### 6.1 Instalação com Helm

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set promtail.enabled=true
```

### 6.2 Configuração da Fonte de Dados no Grafana

- Tipo: Loki
    
- URL: `http://loki.monitoring.svc.cluster.local:3100`
    
- Nome: `Loki Logs`
    

### 6.3 Verificações e Testes

- Acessar o Grafana > Data Sources > Loki > Testar Conexão
    
- Abrir a aba "Explore" e executar queries como:
    

```
{namespace="default"} |= "error"
```

### 6.4 Resultados Esperados:

- Logs centralizados por namespace, pod e container
    
- Facilidade para debug e rastreamento de eventos no cluster
    
- Integração visual com o Grafana já provisionado
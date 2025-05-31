# Etapa 10: Observabilidade com Prometheus, Grafana e Loki

### Objetivo da Etapa:

Implantar uma stack de observabilidade completa no cluster K3s para monitorar métricas, logs e alertas utilizando ferramentas modernas e leves: **Prometheus** (métricas), **Grafana** (visualização) e **Loki** + **Promtail** (logs). Essa etapa é essencial para diagnósticos, tuning de desempenho e visibilidade da saúde do cluster.

* * *

### 10.1 Instalação via Helm (boas práticas)

Criação do namespace e adição do repositório:

```
kubectl create namespace monitoring
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Instalação do Prometheus + Grafana + Loki:

```
helm install prometheus grafana/prometheus \
  -n monitoring

helm install grafana grafana/grafana \
  -n monitoring \
  --set adminPassword='admin' \
  --set service.type=LoadBalancer

helm install loki grafana/loki-stack \
  -n monitoring \
  --set promtail.enabled=true
```

* * *

### 10.2 Configuração da Stack

- **Prometheus** coleta métricas do cluster e das aplicações.
    
- **Grafana** usa o Prometheus como data source e exibe painéis com métricas de CPU, memória, uso de pods, etc.
    
- **Loki** coleta logs com rótulos Kubernetes e permite análise por namespace, pod ou app.
    

* * *

### 10.3 Importação de Dashboards

Foram utilizados dashboards oficiais e customizados:

- Kubernetes / Cluster
    
- Pod Resource Usage
    
- Cilium Metrics
    
- Loki Logs por Aplicação
    

Importação via `ConfigMap`:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-k8s
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  dashboard.json: |
    {
      "title": "Kubernetes Pod Usage",
      ...
    }
```

* * *

### 10.4 Alertas Personalizados com PrometheusRule

Exemplo de alerta para **crash de pods**:

```
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: pod-crash-alert
  namespace: monitoring
spec:
  groups:
  - name: pod.rules
    rules:
    - alert: PodCrashLooping
      expr: kube_pod_container_status_restarts_total > 5
      for: 2m
      labels:
        severity: warning
      annotations:
        summary: "Pod {{ $labels.pod }} está em CrashLoop"
```

* * *

### 10.5 Resultados Esperados

- Visibilidade em tempo real de métricas de infraestrutura e aplicação
    
- Diagnóstico facilitado por dashboards e logs unificados
    
- Alertas proativos para anomalias e falhas operacionais
    
- Ambiente preparado para tuning de desempenho e auditoria
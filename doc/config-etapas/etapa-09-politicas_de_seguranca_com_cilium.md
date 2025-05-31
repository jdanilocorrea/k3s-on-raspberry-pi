# Etapa 9: Políticas de Segurança com Cilium

### Objetivo da Etapa:

Aplicar políticas de rede no cluster Kubernetes utilizando o Cilium, uma solução de CNI baseada em eBPF, para controlar e isolar a comunicação entre pods, aumentando a segurança e garantindo o princípio do menor privilégio.

### 9.1 Implementação da Política `default-deny-all`

```
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: default-deny-all
  namespace: default
spec:
  endpointSelector: {}
  ingress: []
  egress: []
```

Essa política nega todo o tráfego de entrada e saída no namespace `default`, servindo como base segura para liberar apenas o necessário.

### 9.2 Exemplo de Liberação Entre Serviços (Frontend → Backend)

```
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: app
spec:
  endpointSelector:
    matchLabels:
      app: backend
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: frontend
```

### 9.3 Política para Monitoramento (Prometheus acessando pods)

```
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: allow-prometheus
  namespace: monitoring
spec:
  endpointSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  egress:
  - toEndpoints:
    - matchLabels:
        app: node-exporter
    toPorts:
    - ports:
      - port: "9100"
        protocol: TCP
```

### 9.4 Resultados Esperados:

- Tráfego de rede controlado por políticas explícitas
    
- Redução da superfície de ataque na comunicação entre serviços
    
- Auditoria e segurança aprimorada em ambientes sensíveis
    
- Compatibilidade com observabilidade via Hubble
# Etapa 11: Análise de Custos e Otimização com KubeCost

### Objetivo da Etapa:

Instalar e configurar o **KubeCost** no cluster K3s com o objetivo de analisar o uso de recursos, identificar desperdícios e otimizar o consumo financeiro e computacional do ambiente. Esta etapa é essencial para tornar o cluster sustentável e eficiente, especialmente em ambientes bare metal onde o controle de recursos é crítico.

### 11.1 Sobre o KubeCost

**KubeCost** é uma ferramenta especializada em fornecer visibilidade detalhada sobre o custo e o uso de recursos de clusters Kubernetes. Ele calcula os gastos com CPU, memória, armazenamento e rede, permitindo identificar:

- Recursos ociosos (pods subutilizados)
    
- Aplicações com consumo excessivo
    
- Espaços de melhoria no uso da infraestrutura
    

### 11.2 Instalação com Helm

#### Adicionando o repositório:

```
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
helm repo update
```

#### Criando o namespace:

```
kubectl create namespace kubecost
```

#### Instalando o KubeCost:

```
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --set kubecostToken="minha-token" \
  --set global.prometheus.fqdn="http://prometheus.monitoring.svc.cluster.local" \
  --set networkCosts.enabled=true \
  --set kubecostProductConfigs.clusterName="k3s-baremetal"
```

### 11.3 Acesso e Integração

- **Painel Web**: O KubeCost pode ser acessado via LoadBalancer, NodePort ou ingress configurado.
    
- **Integração com Prometheus**: Ele consome métricas diretamente do Prometheus já instalado no cluster.
    
- **Configurações customizadas**: Permite adicionar valores reais de custo para CPU, RAM, disco, etc., mesmo em bare metal.
    

### 11.4 Principais Métricas Acompanhadas

- **Cost Allocation**: Quanto cada namespace, deployment ou pod consome.
    
- **Efficiency Score**: Avaliação da eficiência de uso dos recursos (CPU/Memory).
    
- **Idle Resources**: Identificação de recursos reservados mas não utilizados.
    
- **Request vs Usage**: Comparação entre o que foi solicitado no YAML e o que está realmente sendo usado.
    

### 11.5 Resultados Esperados

- Visibilidade detalhada do uso de recursos por aplicação, namespace e serviço.
    
- Identificação de desperdícios computacionais.
    
- Possibilidade de planejar melhor as alocações de pods e requests/limits.
    
- Base para decisões estratégicas de escala e investimento em infraestrutura.
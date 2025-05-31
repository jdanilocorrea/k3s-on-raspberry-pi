# Etapa 3: Configuração do Balanceador de Carga com MetalLB

### Objetivo da Etapa:

Permitir que serviços do cluster Kubernetes em Bare Metal recebam IPs externos, por meio da implantação do MetalLB no modo Layer 2 (ARP), proporcionando exposição estável de serviços como o Ingress Controller.

### 3.1 Instalação do MetalLB via Helm

```
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm install metallb metallb/metallb -n metallb-system --create-namespace
```

### 3.2 Configuração do IPAddressPool e L2Advertisement

```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: pool-cluster
  namespace: metallb-system
spec:
  addresses:
  - 10.0.10.100-10.0.10.120
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: advert
  namespace: metallb-system
spec:
  ipAddressPools:
  - pool-cluster
```

### 3.3 Boas Práticas Aplicadas:

- IPs reservados no range da sub-rede do cluster sem conflito com IPs dos nós
    
- Namespace dedicado `metallb-system` com monitoramento via Helm
    
- Publicação automática de ARP na LAN local
    

### 3.4 Verificação de Funcionamento

- Após aplicar os manifests, criar um `Service` com `type: LoadBalancer` e verificar se recebe IP externo do range
    
- Exemplo:
    

```
kubectl get svc
NAME                TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)
nginx-service       LoadBalancer   10.43.0.35       10.0.10.101     80:30001/TCP
```

### 3.5 Resultados Esperados:

- IPs atribuídos automaticamente a serviços do tipo LoadBalancer
    
- Comunicação entre aplicações internas e acessos externos funcionais
    
- Base preparada para expor ingressos HTTPS com Cert-Manager
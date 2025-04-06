
![Diagrama do Cluster K3s com MetalLB, NGINX, Prometheus e Grafana](imgs/projeto_cluster_k3s_metallb_nginx_prometheus_grafana(bare-metal).gif)

### 📊 **Tabela - Camadas da chamada em ambiente K3s com MetalLB + NGINX Ingress + Cilium**

| Camada | Elemento | Responsabilidade | Observação |
|--------|----------|------------------|------------|
| 1 | 🌍 **Usuário Externo (HTTP/HTTPS)** | Realiza a requisição para `https://app.exemplo.com` | Navegador, sistema externo, API client |
| 2 | 🛰️ **MetalLB (LoadBalancer IP)** | Fornece o **IP externo fixo** ao Service `nginx-ingress` | IP atribuído ao Service tipo LoadBalancer |
| 3 | 🔁 **Service LoadBalancer (nginx ingress controller)** | Recebe a requisição no IP e envia ao pod NGINX | Expõe as portas 80/443 para o Ingress Controller |
| 4 | 📥 **NGINX Ingress Controller** | Roteia com base nas regras Ingress YAML (host/path) | Pode usar annotations, mas menos recursos que Kong |
| 5 | 🔀 **Service interno da aplicação** | Encaminha a requisição ao pod da aplicação | Service tipo ClusterIP |
| 6 | 🧠 **Cilium (CNI + eBPF)** | Controla o tráfego interno entre pods + segurança | Usa policies e monitora tráfego com Hubble |
| 7 | 🎯 **Pod da aplicação destino** | Processa a requisição | A aplicação final recebe e responde |
# k3s-on-raspberry-pi

## Implementação de um Cluster Kubernetes em Bare Metal com K3s

#### Objetivo do Projeto

Criar um cluster Kubernetes leve e otimizado para servidores físicos usando K3s, explorando boas práticas de rede com MetalLB para balanceamento de carga e Cilium para segurança e redes definidas por software. A automação será feita com Ansible, e a gestão de aplicativos via Helm.

## Planejamento e Requisitos

### Hardware Necessário

- 3+ Raspberry PI 4 (servidores físicos) 
- Processador ARM
- 4GB+ RAM por nó
- Disco SSD recomendado
- Placa de rede Gigabit (mínimo)
### Software e Ferramentas

- SO: Raspberry Pi OS
- K3s: Distribuição leve do Kubernetes
- MetalLB: Balanceador de carga para Kubernetes em bare metal
- Cilium: Gerenciamento de rede e segurança via eBPF
- Helm: Gerenciamento de pacotes Kubernetes
- Ansible: Automação da configuração do cluster

![Diagrama do Cluster K3s com MetalLB, NGINX, Prometheus e Grafana](doc/imgs/projeto_cluster_k3s_metallb_nginx_prometheus_grafana(bare-metal).gif)

### 📊 **Tabela - Camadas da chamada em ambiente K3s com MetalLB + NGINX Ingress + Cilium**

| Camada | Elemento | Responsabilidade | Observação |
|--------|----------|------------------|------------|
| 1 | 🌍 **Usuário Interno/Externo (HTTP/HTTPS)** | Realiza a requisição para `https://app.exemplo.com` | Navegador, sistema externo, API client |
| 2 | 🛰️ **MetalLB (LoadBalancer IP)** | Fornece o **IP externo fixo** ao Service `nginx-ingress` | IP atribuído ao Service tipo LoadBalancer |
| 3 | 🔁 **Service LoadBalancer (nginx ingress controller)** | Recebe a requisição no IP e envia ao pod NGINX | Expõe as portas 80/443 para o Ingress Controller |
| 4 | 📥 **NGINX Ingress Controller** | Roteia com base nas regras Ingress YAML (host/path) | Pode usar annotations, mas menos recursos que Kong |
| 5 | 🔀 **Service interno da aplicação** | Encaminha a requisição ao pod da aplicação | Service tipo ClusterIP |
| 6 | 🧠 **Cilium (CNI + eBPF)** | Controla o tráfego interno entre pods + segurança | Usa policies e monitora tráfego com Hubble |
| 7 | 🎯 **Pod da aplicação destino** | Processa a requisição | A aplicação final recebe e responde |

### Requisitos/Configurações do Cluster K3s

https://docs.k3s.io/installation/requirements?os=pi

### Configuração da Rede

- Definir um endereço IP fixo para cada nó
- Criar uma sub-rede dedicada para o cluster
- Habilitar IP forwarding no Linux

## Configuração da Rede no Cluster Kubernetes Bare Metal
Esta etapa garante que todos os nós do cluster (Control Plane e Workers) possam se comunicar corretamente entre si, utilizando uma sub-rede dedicada com IPs fixos. Isso é essencial para clusters Bare Metal, onde não há um provedor de rede virtual automático como em nuvens públicas.

#### Atribuir IPs fixos (estáticos) para cada nó
Para garantir previsibilidade e facilitar configurações (como DNS, MetalLB e firewall), cada nó do cluster deve possuir um endereço IP estático.

#### Editar a configuração da interface de rede:
Execute no terminal de cada nó (Control Plane e Workers):

`sudo nano /etc/network/interfaces`

Esse arquivo é responsável por definir como a interface de rede se comporta no boot do sistema (modo estático ou DHCP).

#### Exemplos de configuração por nó:

#### Control Plane (10.0.10.10)
```
auto eth0
iface eth0 inet static
    address 10.0.10.10
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 10.0.0.1
```

#### Worker 1 (10.0.10.20)
```
auto eth0
iface eth0 inet static
    address 10.0.10.20
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 10.0.0.1
```

#### Worker 2 (10.0.10.30)
```
auto eth0
iface eth0 inet static
    address 10.0.10.30
    netmask 255.255.255.0
    gateway 10.0.0.1
    dns-nameservers 10.0.0.1
```

Explicando os campos:
- address: o IP fixo do nó.
- netmask: define o tamanho da rede (255.255.255.0 = /24).
- gateway: IP do roteador para saída da rede.
- dns-nameservers: servidor DNS local ou externo.

#### Aplicar as configurações de rede
Após salvar o arquivo, reinicie o serviço de rede:
`sudo systemctl restart networking`
Isso aplica imediatamente as configurações sem precisar reiniciar o sistema.

#### Habilitar o IP forwarding no Linux
O IP forwarding permite que o Linux encaminhe pacotes entre interfaces de rede, essencial para a comunicação entre nós e serviços do cluster.
Habilitar temporariamente (até reiniciar):
`echo 1 > /proc/sys/net/ipv4/ip_forward`

#### Habilitar permanentemente:
Edite o arquivo de configurações do sistema:
`sudo nano /etc/sysctl.conf`

E descomente ou adicione a linha:
`net.ipv4.ip_forward=1`

Depois aplique com:
`sudo sysctl -p`

#### Verificação rápida
Após todas as etapas:
- Confirme com ip a ou ifconfig se os IPs foram atribuídos.
- Teste o ping entre os nós para garantir a comunicação:
```
ping 10.0.10.10   # de um worker para o Control Plane
ping 10.0.10.20   # de um worker para outro
```

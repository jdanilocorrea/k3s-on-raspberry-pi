#Etapa 1: Planejamento da Infraestrutura e Requisitos

### Objetivo da Etapa:

Preparar e planejar o ambiente físico e lógico necessário para a implantação de um cluster Kubernetes utilizando K3s em Bare Metal, com foco em custo reduzido, automação, segurança e observabilidade.

### Justificativa:

Antes de iniciar qualquer instalação ou automação, é fundamental compreender os recursos disponíveis, definir a topologia da rede, atribuir endereços IP fixos e preparar as máquinas que comporão o cluster. Esse planejamento garante que todas as etapas subsequentes ocorram de maneira ordenada e compatível com os requisitos do projeto.

* * *

### 1.1 Definição do Ambiente Físico

- **Dispositivos:** 3 unidades do Raspberry Pi 4 Model B (4 GB de RAM)
    
- **Armazenamento:** Cartões microSD classe 10
    
- **Sistema Operacional:** Raspberry Pi OS Lite (64 bits)
    
- **Energia:** Fontes independentes com nobreak
    

### 1.2 Topologia de Rede

- **Rede dedicada para o cluster:** 10.0.10.0/24
    
- **Atribuição de IPs estáticos:**
    
    - `10.0.10.10` - Control Plane (Master)
        
    - `10.0.10.20` - Worker 1
        
    - `10.0.10.30` - Worker 2
        
    - `10.0.10.40` - Estação de Gerenciamento (labs)
        

### 1.3 Requisitos para K3s

- **Desabilitar o SWAP:** K3s requer que o SWAP esteja desativado em todos os nós.
    
- **Habilitar IP Forwarding:** Necessário para roteamento de pacotes entre pods.
    
- **Firewall:** Liberação de portas para comunicação entre os nós do cluster (porta 6443 TCP para o servidor K3s, entre outras).
    

### 1.4 Ambiente de Gerenciamento

- A máquina `labs` (10.0.10.40) será utilizada para:
    
    - Executar os **playbooks Ansible**
        
    - Gerenciar o **acesso remoto via SSH** aos nós
        
    - Consolidar configurações, manifests e aplicações via **kubectl**
        

### 1.5 Lista de Ferramentas Utilizadas

- **Ansible**: Para automação da configuração dos nós e implantação de componentes
    
- **Helm**: Para instalar charts de aplicações como MetalLB, Prometheus, Loki etc.
    
- **K3s**: Distribuição leve do Kubernetes com binário único e baixo consumo
    
- **kubectl e ferramentas auxiliares:** kubectx, kubens, stern, krew, kube-ps1
    

* * *

### 1.6 Resultados Esperados da Etapa:

- Infraestrutura definida e preparada
    
- Endereços IP fixos atribuídos corretamente
    
- SWAP desativado em todos os nós
    
- IP Forwarding ativado
    
- Acesso remoto via SSH funcional
    
- Estação de gerenciamento com ferramentas instaladas
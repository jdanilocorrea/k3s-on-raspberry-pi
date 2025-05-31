# Etapa 2: Automação da Instalação do K3s com Ansible

### Objetivo da Etapa:

Instalar e configurar automaticamente o cluster Kubernetes utilizando K3s nos três nós físicos por meio de playbooks Ansible, garantindo consistência, eficiência e reprodutibilidade no processo de provisionamento.

### 2.1 Estrutura dos Playbooks

A automação foi dividida em papéis (roles) reutilizáveis, com variáveis definidas por host:

- **roles/k3s-server**: Instalação do Control Plane com K3s (flag `--flannel-backend=none`)
    
- **roles/k3s-agent**: Instalação dos Workers, apontando para o IP do Control Plane e utilizando o token de acesso
    
- **roles/common**: Desabilita o SWAP, ativa IP forwarding e instala pacotes básicos
    

### 2.2 Inventário de Hosts

O arquivo `inventory/hosts.yml` define os grupos de máquinas:

```
all:
  children:
    servers:
      hosts:
        k3s-master:
          ansible_host: 10.0.10.10
    agents:
      hosts:
        k3s-worker1:
          ansible_host: 10.0.10.20
        k3s-worker2:
          ansible_host: 10.0.10.30
```

### 2.3 Execução dos Playbooks

O comando abaixo executa a instalação do cluster:

```
ansible-playbook -i inventory/hosts.yml site.yml
```

O `site.yml` orquestra a execução em sequência:

```
- hosts: all
  roles:
    - common

- hosts: servers
  roles:
    - k3s-server

- hosts: agents
  roles:
    - k3s-agent
```

### 2.4 Verificações Após Instalação

Após a execução:

- A saída do comando `kubectl get nodes` (executado via acesso remoto ao nó master) deve listar todos os três nós prontos (STATUS: Ready)
    
- O arquivo kubeconfig foi copiado da máquina master para o host de gerenciamento (`labs`) com permissão adequada
    

### 2.5 Resultados Esperados:

- K3s instalado em todos os nós com comunicação funcional
    
- Cluster Kubernetes leve e funcional
    
- SWAP desabilitado, IP forwarding habilitado
    
- Token de acesso configurado para que os Workers se juntem ao cluster
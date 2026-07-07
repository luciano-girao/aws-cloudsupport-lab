# Lab 01 - EC2 SSH Troubleshooting

## Objetivo
Diagnosticar e resolver problemas comuns de conectividade SSH em instancias EC2 na AWS.

## Cenario
Um cliente relata que nao consegue conectar via SSH em uma instancia EC2. A instancia esta em estado `running`, mas as tentativas de conexao retornam timeout.

## Pre-requisitos
- AWS CLI configurado
- Acesso ao Console AWS
- Instancia EC2 rodando Amazon Linux 2

## Causas Comuns e Diagnostico

### 1. Security Group
```bash
# Verificar regras do Security Group
aws ec2 describe-security-groups \
  --group-ids sg-XXXXXXXX \
  --query 'SecurityGroups[*].IpPermissions'
```
**Solucao**: Adicionar regra de entrada na porta 22 (TCP) para o IP necessario.

### 2. Network ACL (NACL)
```bash
# Verificar NACLs da subnet
aws ec2 describe-network-acls \
  --filters Name=association.subnet-id,Values=subnet-XXXXXXXX
```
**Solucao**: Garantir que a NACL permite entrada na porta 22 e saida nas portas efemeras (1024-65535).

### 3. Key Pair incorreto
```bash
# Verificar qual key pair foi usado na instancia
aws ec2 describe-instances \
  --instance-ids i-XXXXXXXX \
  --query 'Reservations[*].Instances[*].KeyName'
```

### 4. EC2 Instance Connect (alternativa)
```bash
# Conectar via EC2 Instance Connect sem key pair
aws ec2-instance-connect send-ssh-public-key \
  --instance-id i-XXXXXXXX \
  --availability-zone us-east-1a \
  --instance-os-user ec2-user \
  --ssh-public-key file://~/.ssh/id_rsa.pub
```

## Checklist de Troubleshooting
- [ ] Instancia em estado `running`
- [ ] Security Group permite porta 22
- [ ] NACL permite porta 22
- [ ] Key pair correto (.pem)
- [ ] IP publico ou Elastic IP atribuido
- [ ] Route table com Internet Gateway
- [ ] SSH Agent rodando localmente

## Resultado Esperado
Conexao SSH estabelecida com sucesso:
```bash
ssh -i my-key.pem ec2-user@<PUBLIC-IP>
```

---
*Lab criado por Luciano Girao | AWS Cloud Support Lab*

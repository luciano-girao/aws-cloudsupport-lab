# Lab 03 - RDS Connection Troubleshooting

## Objetivo
Diagnosticar e resolver problemas de conexao com instancias Amazon RDS.

## Cenario
Uma aplicacao nao consegue conectar ao banco de dados RDS MySQL. O erro retornado e `Can't connect to MySQL server` ou `Connection timed out`.

## Pre-requisitos
- AWS CLI configurado
- Instancia RDS MySQL rodando
- Cliente MySQL instalado na EC2

## Arquitetura do Lab
```
[EC2 App] --> [Security Group EC2] --> [Security Group RDS] --> [RDS MySQL]
                                              |
                                        [Subnet Privada]
```

## Diagnostico Passo a Passo

### 1. Verificar status da instancia RDS
```bash
aws rds describe-db-instances \
  --db-instance-identifier NOME-DO-RDS \
  --query 'DBInstances[*].{Status:DBInstanceStatus,Endpoint:Endpoint.Address}'
```

### 2. Verificar Security Group do RDS
```bash
# O SG do RDS deve permitir porta 3306 do SG da EC2
aws ec2 describe-security-groups \
  --group-ids sg-RDS-XXXXXXXX \
  --query 'SecurityGroups[*].IpPermissions'
```

### 3. Testar conectividade de rede
```bash
# Na instancia EC2
nc -zv <RDS-ENDPOINT> 3306

# Ou com telnet
telnet <RDS-ENDPOINT> 3306
```

### 4. Testar conexao MySQL
```bash
mysql -h <RDS-ENDPOINT> -u admin -p -e "SELECT 1;"
```

### 5. Verificar se RDS esta em subnet privada acessivel
```bash
aws rds describe-db-subnet-groups \
  --db-subnet-group-name NOME-DO-SUBNET-GROUP
```

## Checklist de Troubleshooting
- [ ] RDS em estado `available`
- [ ] Security Group permite porta 3306 da origem correta
- [ ] EC2 e RDS na mesma VPC
- [ ] Route tables configuradas corretamente
- [ ] Usuario/senha corretos
- [ ] `publicly_accessible` configurado conforme necessidade
- [ ] Parameter group sem restricoes de acesso

## Solucoes Comuns

| Erro | Causa | Solucao |
|---|---|---|
| Connection timed out | SG bloqueando porta 3306 | Adicionar inbound rule no SG do RDS |
| Access denied for user | Credenciais erradas | Resetar senha via Console AWS |
| Can't connect | RDS em subnet sem rota | Verificar route table da subnet |
| SSL required | SSL forcado no RDS | Adicionar `--ssl-mode=REQUIRED` |

---
*Lab criado por Luciano Girao | AWS Cloud Support Lab*

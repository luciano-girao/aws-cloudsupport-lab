# aws-cloudsupport-lab

> Laboratórios de Cloud Support: cenários reais de troubleshooting em AWS e Linux.

![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

---

## 📌 Sobre o projeto

Coleção de **laboratórios práticos voltados para Cloud Support**, simulando cenários reais que um engenheiro de suporte enfrenta no dia a dia. Cada lab traz: o **sintoma** relatado, o **diagnóstico** e a **correção** aplicada.

Ideal para estudar **troubleshooting em AWS**, **Linux** e **redes em ambiente de nuvem**.

---

## 📂 Estrutura do repositório

```
aws-cloudsupport-lab/
├── lab-01-security-group-connectivity/
│   └── README.md    # EC2 sem resposta por porta bloqueada
├── lab-02-service-down-linux/
│   └── README.md    # Serviço Nginx parado após reboot
├── lab-03-disk-full/
│   └── README.md    # Instância inacessível por disco cheio
├── lab-04-dns-resolution/
│   └── README.md    # Falha de resolução DNS interna
├── lab-05-iam-permission-denied/
│   └── README.md    # Erro AccessDenied ao acessar S3
└── README.md
```

---

## 🔬 Labs disponíveis

### Lab 01 - EC2 sem conectividade (Security Group)
**Sintoma:** Usuário não consegue acessar aplicação na porta 80 da instância EC2.  
**Causa:** Security Group sem regra de entrada para HTTP (porta 80).  
**Correção:**
```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-XXXXXXXX \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
```
**Lição:** Sempre verificar Security Groups e NACLs antes de investigar a aplicação.

---

### Lab 02 - Nginx parado após reboot
**Sintoma:** Página web indisponível após reinicialização da instância.  
**Causa:** Nginx não configurado para iniciar automaticamente com o sistema.  
**Diagnóstico:**
```bash
systemctl status nginx
journalctl -u nginx --since "1 hour ago"
```
**Correção:**
```bash
systemctl enable nginx
systemctl start nginx
```
**Lição:** Serviços críticos devem ser habilitados com `systemctl enable`.

---

### Lab 03 - Instância inacessível (disco cheio)
**Sintoma:** SSH recusa conexão. Aplicação retorna erro 500.  
**Causa:** Disco do sistema operacional 100% utilizado.  
**Diagnóstico:**
```bash
df -h
du -sh /* | sort -rh | head -10
```
**Correção:**
```bash
# Limpar logs antigos
find /var/log -name "*.log" -mtime +7 -delete
# Ou expandir o volume EBS pelo Console AWS
```
**Lição:** Configurar alarmes no CloudWatch para uso de disco acima de 80%.

---

### Lab 04 - Falha de resolução DNS
**Sintoma:** Instâncias dentro da VPC não conseguem resolver nomes internos.  
**Causa:** DNS Resolution ou DNS Hostnames desabilitados na VPC.  
**Diagnóstico:**
```bash
nslookup meu-servico.internal
dig meu-servico.internal
```
**Correção:** Habilitar **DNS resolution** e **DNS hostnames** nas configurações da VPC.  
**Lição:** DNS é a primeira coisa a verificar em problemas de conectividade interna.

---

### Lab 05 - AccessDenied ao acessar S3
**Sintoma:** Aplicação retorna `AccessDenied` ao tentar ler objetos do S3.  
**Causa:** Role IAM anexada à instância não possui permissão `s3:GetObject`.  
**Diagnóstico:**
```bash
aws s3 ls s3://meu-bucket/ --debug 2>&1 | grep "AccessDenied"
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::ACCOUNT:role/minha-role \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::meu-bucket/*
```
**Correção:** Adicionar a policy `AmazonS3ReadOnlyAccess` ou uma policy customizada à role.  
**Lição:** Sempre usar o IAM Policy Simulator para verificar permissões antes de depurar.

---

## 📚 O que aprendi com esse projeto

- Método de troubleshooting estruturado: sintoma → diagnóstico → causa raiz → correção
- Principais causas de incidentes em AWS (SG, IAM, DNS, disco, serviços)
- Uso prático de `systemd`, `journalctl`, `df`, `du`, `nslookup` e `aws cli`
- CloudWatch como ferramenta preventiva de monitoramento
- Boas práticas de operações em ambientes cloud

---

## 👤 Autor

**Luciano Henrique Morais Girão**  
[LinkedIn](https://www.linkedin.com/in/lucianogirao) • [GitHub](https://github.com/lucianowtp1-stack)

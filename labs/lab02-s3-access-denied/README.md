# Lab 02 - S3 Access Denied Troubleshooting

## Objetivo
Diagnosticar e resolver erros de `AccessDenied` ao acessar objetos no Amazon S3.

## Cenario
Uma aplicacao EC2 retorna `AccessDenied` ao tentar fazer `s3:GetObject`. A instancia possui uma IAM Role anexada, mas o erro persiste.

## Pre-requisitos
- AWS CLI configurado
- Instancia EC2 com IAM Role
- Bucket S3 existente

## Camadas de Permissao no S3

```
[IAM Policy] + [S3 Bucket Policy] + [S3 ACL] = Acesso Final
```

O acesso e negado se **qualquer** camada negar explicitamente.

## Diagnostico Passo a Passo

### 1. Verificar IAM Role da instancia
```bash
# Na instancia EC2
aws sts get-caller-identity

# Listar permissoes da role
aws iam list-attached-role-policies --role-name NOME-DA-ROLE
```

### 2. Verificar Bucket Policy
```bash
aws s3api get-bucket-policy --bucket NOME-DO-BUCKET
```

### 3. Verificar Block Public Access
```bash
aws s3api get-public-access-block --bucket NOME-DO-BUCKET
```

### 4. Testar acesso com verbose
```bash
aws s3 cp s3://NOME-DO-BUCKET/objeto.txt . --debug 2>&1 | grep -i "denied\|error"
```

### 5. Usar IAM Policy Simulator
Acesse: https://policysim.aws.amazon.com/

## Solucoes Comuns

| Problema | Solucao |
|---|---|
| IAM Role sem permissao s3:GetObject | Adicionar policy com s3:GetObject |
| Bucket Policy com Deny explicito | Remover ou ajustar o Deny |
| Block Public Access ativo | Desativar se necessario |
| Objeto em conta diferente | Usar cross-account policy |
| KMS encryption sem permissao | Adicionar kms:Decrypt na IAM Policy |

## Policy Minima Recomendada
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::NOME-DO-BUCKET",
        "arn:aws:s3:::NOME-DO-BUCKET/*"
      ]
    }
  ]
}
```

---
*Lab criado por Luciano Girao | AWS Cloud Support Lab*

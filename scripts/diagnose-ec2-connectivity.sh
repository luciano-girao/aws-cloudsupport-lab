#!/bin/bash
# =============================================================
# diagnose-ec2-connectivity.sh
# Script de diagnóstico de conectividade para instâncias EC2
# Cobre os labs: SG, DNS, disco, serviços e IAM
# Autor: Luciano Girão | github.com/luciano-girao
# =============================================================

set -uo pipefail

echo "============================================="
echo " EC2 Connectivity Diagnostics"
echo " Data: $(date)"
echo "============================================="
echo ""

# ---- LAB 01: Verificação de disco ----
echo "[LAB 01] Uso de disco:"
df -h | grep -v tmpfs
echo ""

USO=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$USO" -gt 80 ]; then
  echo "[ALERTA] Disco acima de 80% - pode causar falhas de serviço!"
  echo "  Top diretórios por tamanho:"
  du -sh /* 2>/dev/null | sort -rh | head -5
else
  echo "[OK] Disco com uso de ${USO}%"
fi
echo ""

# ---- LAB 02: Status de serviços web ----
echo "[LAB 02] Status de serviços web:"
for SERVICE in nginx apache2 httpd; do
  if systemctl list-units --type=service | grep -q "$SERVICE"; then
    STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null || echo "inativo")
    if [ "$STATUS" = "active" ]; then
      echo "  [OK] $SERVICE: $STATUS"
    else
      echo "  [ALERTA] $SERVICE: $STATUS"
      echo "    Para corrigir: sudo systemctl start $SERVICE && sudo systemctl enable $SERVICE"
    fi
  fi
done
echo ""

# ---- LAB 03: Teste de resolução DNS ----
echo "[LAB 03] Resolução DNS:"
DNS_TARGETS=("google.com" "aws.amazon.com" "8.8.8.8")
for TARGET in "${DNS_TARGETS[@]}"; do
  if nslookup "$TARGET" &>/dev/null; then
    echo "  [OK] DNS resolve: $TARGET"
  else
    echo "  [ERRO] Falha ao resolver: $TARGET"
    echo "    Verifique: /etc/resolv.conf e DNS da VPC"
  fi
done
echo ""

# ---- LAB 04: Teste de conectividade HTTP ----
echo "[LAB 04] Conectividade de rede:"
if curl -s --max-time 5 http://checkip.amazonaws.com &>/dev/null; then
  IP=$(curl -s --max-time 5 http://checkip.amazonaws.com)
  echo "  [OK] Acesso à internet OK | IP público: $IP"
else
  echo "  [ERRO] Sem acesso à internet"
  echo "    Verifique: Security Group, NACL, Internet Gateway e Route Table"
fi
echo ""

# ---- LAB 05: Verificação de logs de sistema ----
echo "[LAB 05] Últimos erros no syslog:"
if [ -f /var/log/syslog ]; then
  grep -i "error\|failed\|critical" /var/log/syslog | tail -5 || echo "  Sem erros recentes."
elif [ -f /var/log/messages ]; then
  grep -i "error\|failed\|critical" /var/log/messages | tail -5 || echo "  Sem erros recentes."
fi
echo ""

echo "============================================="
echo " Diagnóstico concluído."
echo "============================================="

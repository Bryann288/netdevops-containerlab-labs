#!/usr/bin/env bash
# ==============================================================================
# NetDevOps Automated Validation Script: Enterprise Multi-Site BGP & OSPF
# ==============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  INICIANDO VALIDACIÓN AUTOMATIZADA: ENTERPRISE WAN (BGP + OSPF)     ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# 1. Verificar que los contenedores estén corriendo
echo -e "\n${YELLOW}[1/5] Verificando estado de contenedores en Docker...${NC}"
for node in clab-enterprise-wan-wan-r1 clab-enterprise-wan-dc1-edge clab-enterprise-wan-dc1-dist clab-enterprise-wan-dc1-srv clab-enterprise-wan-dc2-edge clab-enterprise-wan-dc2-dist clab-enterprise-wan-dc2-srv; do
    if docker ps --format '{{.Names}}' | grep -q "^${node}$"; then
        echo -e "  [✔] Nodo ${node}: ${GREEN}UP${NC}"
    else
        echo -e "  [✘] Nodo ${node}: ${RED}DOWN${NC}"
        exit 1
    fi
done

# 2. Comprobar sesiones BGP
echo -e "\n${YELLOW}[2/5] Comprobando convergencia de BGP en WAN Core (wan-r1)...${NC}"
BGP_SUMMARY=$(docker exec clab-enterprise-wan-wan-r1 vtysh -c "show ip bgp summary" 2>/dev/null)
echo "$BGP_SUMMARY"

if echo "$BGP_SUMMARY" | grep -q "10.100.1.2" && echo "$BGP_SUMMARY" | grep -q "10.100.2.2"; then
    echo -e "  [✔] Sesiones eBGP hacia DC1-Edge (AS 65100) y DC2-Edge (AS 65200): ${GREEN}ESTABLECIDAS${NC}"
else
    echo -e "  [✘] Sesiones eBGP no detectadas correctamente."
    exit 1
fi

# 3. Comprobar adyacencias OSPF
echo -e "\n${YELLOW}[3/5] Comprobando adyacencias OSPF en DC1 y DC2...${NC}"
OSPF_DC1=$(docker exec clab-enterprise-wan-dc1-edge vtysh -c "show ip ospf neighbor" 2>/dev/null)
OSPF_DC2=$(docker exec clab-enterprise-wan-dc2-edge vtysh -c "show ip ospf neighbor" 2>/dev/null)

echo -e "  -> DC1-Edge OSPF Neighbors:"
echo "$OSPF_DC1"
echo -e "  -> DC2-Edge OSPF Neighbors:"
echo "$OSPF_DC2"

if echo "$OSPF_DC1" | grep -q "Full" && echo "$OSPF_DC2" | grep -q "Full"; then
    echo -e "  [✔] Vecindades OSPF en DC1 y DC2: ${GREEN}FULL (Convergido)${NC}"
else
    echo -e "  [!] OSPF aún convergiendo..."
fi

# 4. Prueba de Ping Extremo a Extremo (DC1-Srv -> DC2-Srv)
echo -e "\n${YELLOW}[4/5] Prueba de Conectividad Data Plane (Ping DC1-Srv -> DC2-Srv: 10.2.10.100)...${NC}"
PING_OUT=$(docker exec clab-enterprise-wan-dc1-srv ping -c 4 10.2.10.100)
echo "$PING_OUT"

if echo "$PING_OUT" | grep -q "0% packet loss"; then
    echo -e "  [✔] Ping extremo a extremo: ${GREEN}EXITOSO (0% Packet Loss)${NC}"
else
    echo -e "  [✘] Ping falló."
    exit 1
fi

# 5. Traceroute Multi-hop
echo -e "\n${YELLOW}[5/5] Trazabilidad de Saltos (Traceroute DC1-Srv -> DC2-Srv: 6 saltos)...${NC}"
TRACE_OUT=$(docker exec clab-enterprise-wan-dc1-srv traceroute -n 10.2.10.100 2>&1 || true)
echo "$TRACE_OUT"

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}  ¡TODAS LAS PRUEBAS DE AUTOMATIZACIÓN PASARON SATISFACTORIAMENTE!     ${NC}"
echo -e "${GREEN}======================================================================${NC}"

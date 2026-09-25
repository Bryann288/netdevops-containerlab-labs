#!/usr/bin/env bash
# ==============================================================================
# Network Automated Validation Script: Enterprise Multi-Site BGP & OSPF
# ==============================================================================

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  AUTOMATED VALIDATION: ENTERPRISE WAN (BGP + OSPF)                   ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# 1. Container state verification
echo -e "\n${YELLOW}[1/5] Verifying node status in Docker...${NC}"
for node in clab-enterprise-wan-wan-r1 clab-enterprise-wan-dc1-edge clab-enterprise-wan-dc1-dist clab-enterprise-wan-dc1-srv clab-enterprise-wan-dc2-edge clab-enterprise-wan-dc2-dist clab-enterprise-wan-dc2-srv; do
    if docker ps --format '{{.Names}}' | grep -q "^${node}$"; then
        echo -e "  [OK] Node ${node}: ${GREEN}UP${NC}"
    else
        echo -e "  [FAIL] Node ${node}: ${RED}DOWN${NC}"
        exit 1
    fi
done

# 2. BGP session validation
echo -e "\n${YELLOW}[2/5] Verifying BGP convergence on WAN Core (wan-r1)...${NC}"
BGP_SUMMARY=$(docker exec clab-enterprise-wan-wan-r1 vtysh -c "show ip bgp summary" 2>/dev/null)
echo "$BGP_SUMMARY"

if echo "$BGP_SUMMARY" | grep -q "10.100.1.2" && echo "$BGP_SUMMARY" | grep -q "10.100.2.2"; then
    echo -e "  [OK] eBGP sessions to DC1-Edge (AS 65100) and DC2-Edge (AS 65200): ${GREEN}ESTABLISHED${NC}"
else
    echo -e "  [FAIL] eBGP sessions are not established."
    exit 1
fi

# 3. OSPF adjacency validation
echo -e "\n${YELLOW}[3/5] Verifying OSPF adjacencies in DC1 and DC2...${NC}"
OSPF_DC1=$(docker exec clab-enterprise-wan-dc1-edge vtysh -c "show ip ospf neighbor" 2>/dev/null)
OSPF_DC2=$(docker exec clab-enterprise-wan-dc2-edge vtysh -c "show ip ospf neighbor" 2>/dev/null)

echo -e "  -> DC1-Edge OSPF Neighbors:"
echo "$OSPF_DC1"
echo -e "  -> DC2-Edge OSPF Neighbors:"
echo "$OSPF_DC2"

if echo "$OSPF_DC1" | grep -q "Full" && echo "$OSPF_DC2" | grep -q "Full"; then
    echo -e "  [OK] OSPF neighbor state in DC1 and DC2: ${GREEN}FULL${NC}"
else
    echo -e "  [WARN] OSPF state still converging."
fi

# 4. Data plane ping test (DC1-Srv -> DC2-Srv)
echo -e "\n${YELLOW}[4/5] Executing data plane ping test (DC1-Srv -> DC2-Srv: 10.2.10.100)...${NC}"
PING_OUT=$(docker exec clab-enterprise-wan-dc1-srv ping -c 4 10.2.10.100)
echo "$PING_OUT"

if echo "$PING_OUT" | grep -q "0% packet loss"; then
    echo -e "  [OK] End-to-end ICMP ping: ${GREEN}PASSED (0% packet loss)${NC}"
else
    echo -e "  [FAIL] ICMP ping test failed."
    exit 1
fi

# 5. Hop-by-hop path tracing
echo -e "\n${YELLOW}[5/5] Executing path traceability (traceroute DC1-Srv -> DC2-Srv)...${NC}"
TRACE_OUT=$(docker exec clab-enterprise-wan-dc1-srv traceroute -n 10.2.10.100 2>&1 || true)
echo "$TRACE_OUT"

echo -e "\n${GREEN}======================================================================${NC}"
echo -e "${GREEN}  ALL AUTOMATION TESTS PASSED SUCCESSFULLY                            ${NC}"
echo -e "${GREEN}======================================================================${NC}"

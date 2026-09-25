.PHONY: help deploy destroy inspect graph clean deploy-enterprise destroy-enterprise verify-enterprise

LAB ?= labs/01-frr-ospf/frr-ospf.clab.yml
ENTERPRISE_LAB = labs/04-enterprise-multisite-bgp-ospf/multisite-enterprise.clab.yml

help:
	@echo "=================================================="
	@echo " NetDevOps Containerlab Helper"
	@echo "=================================================="
	@echo "Available commands:"
	@echo "  make deploy  LAB=<path>     - Deploy topology (default: $(LAB))"
	@echo "  make destroy LAB=<path>     - Destroy topology and cleanup veth pairs"
	@echo "  make inspect LAB=<path>     - Inspect node state and IP addresses"
	@echo "  make graph   LAB=<path>     - Launch web topology viewer"
	@echo "  make clean                  - Remove temporary clab-* directories"
	@echo ""
	@echo "Enterprise Multi-Site Project (BGP + OSPF):"
	@echo "  make deploy-enterprise      - Deploy full enterprise multi-site topology"
	@echo "  make verify-enterprise      - Run automated verification tests"
	@echo "  make destroy-enterprise     - Destroy enterprise topology"
	@echo ""
	@echo "Example:"
	@echo "  make deploy LAB=labs/01-frr-ospf/frr-ospf.clab.yml"

deploy:
	sudo containerlab deploy -t $(LAB) --reconfigure

destroy:
	sudo containerlab destroy -t $(LAB) --cleanup

inspect:
	sudo containerlab inspect -t $(LAB)

graph:
	sudo containerlab graph -t $(LAB)

clean:
	sudo rm -rf clab-*

deploy-enterprise:
	sudo containerlab deploy -t $(ENTERPRISE_LAB) --reconfigure

destroy-enterprise:
	sudo containerlab destroy -t $(ENTERPRISE_LAB) --cleanup

verify-enterprise:
	chmod +x tests/verify-enterprise-wan.sh
	./tests/verify-enterprise-wan.sh

.PHONY: help deploy destroy inspect graph clean deploy-enterprise destroy-enterprise verify-enterprise

LAB ?= labs/01-frr-ospf/frr-ospf.clab.yml
ENTERPRISE_LAB = labs/04-enterprise-multisite-bgp-ospf/multisite-enterprise.clab.yml

help:
	@echo "=================================================="
	@echo " NetDevOps Containerlab Helper"
	@echo "=================================================="
	@echo "Comandos disponibles:"
	@echo "  make deploy  LAB=<ruta>     - Desplegar topología (por defecto: $(LAB))"
	@echo "  make destroy LAB=<ruta>     - Destruir topología y limpiar interfaces"
	@echo "  make inspect LAB=<ruta>     - Inspeccionar estado y IPs de los nodos"
	@echo "  make graph   LAB=<ruta>     - Iniciar servidor de visualización web"
	@echo "  make clean                  - Eliminar directorios temporales clab-*"
	@echo ""
	@echo "Proyecto Enterprise Multi-Site (BGP + OSPF):"
	@echo "  make deploy-enterprise      - Desplegar topología multi-sitio completa"
	@echo "  make verify-enterprise      - Ejecutar pruebas automatizadas (BGP, OSPF, Ping, Traceroute)"
	@echo "  make destroy-enterprise     - Destruir topología multi-sitio"
	@echo ""
	@echo "Ejemplo:"
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


.PHONY: help deploy destroy inspect graph clean

LAB ?= labs/01-frr-ospf/frr-ospf.clab.yml

help:
	@echo "=================================================="
	@echo " NetDevOps Containerlab Helper"
	@echo "=================================================="
	@echo "Comandos disponibles:"
	@echo "  make deploy  LAB=<ruta>  - Desplegar topología (por defecto: $(LAB))"
	@echo "  make destroy LAB=<ruta>  - Destruir topología y limpiar interfaces"
	@echo "  make inspect LAB=<ruta>  - Inspeccionar estado y IPs de los nodos"
	@echo "  make graph   LAB=<ruta>  - Iniciar servidor de visualización web de la topología"
	@echo "  make clean               - Eliminar directorios temporales clab-*"
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

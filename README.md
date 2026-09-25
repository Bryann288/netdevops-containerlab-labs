# NetDevOps - Laboratorios con Containerlab & Docker 🌐

Este repositorio contiene el entorno y las plantillas para ejecutar laboratorios de emulación de redes y **NetDevOps** utilizando **Containerlab** y **Docker** sobre el entorno Linux (WSL2 Ubuntu-22.04).

---

## 📁 Estructura del Proyecto

```text
.
├── Makefile                      # Atajos para desplegar, destruir e inspeccionar labs
├── .gitignore                    # Filtro de artefactos de Containerlab e imágenes grandes
├── images/                       # Instrucciones y almacenamiento local de imágenes de red
│   └── README.md
└── labs/
    ├── 01-frr-ospf/              # Lab básico inicial con FRRouting (OSPF) y clientes Alpine
    │   ├── config/               # Configuraciones iniciales (daemons, frr.conf)
    │   └── frr-ospf.clab.yml
    ├── 02-srlinux-leafspine/     # Topología Leaf-Spine con Nokia SR Linux
    │   └── srlinux-clos.clab.yml
    ├── 03-arista-ceos/           # Topología de conmutación con Arista cEOS
    │   └── ceos-lab.clab.yml
    └── 04-enterprise-multisite-bgp-ospf/ # 🌟 PROYECTO PRINCIPAL: WAN Multi-Sitio con BGP + OSPF (7 nodos)
        ├── config/               # Configuraciones FRR por nodo
        ├── multisite-enterprise.clab.yml
        └── README.md

```

---

## 🚀 Inicio Rápido (Quickstart)

### 1. Acceder al entorno Linux (WSL)
Abre tu terminal en Windows y entra en tu distribución de WSL:

```bash
wsl -d Ubuntu-22.04
cd /mnt/c/Users/bryan/Documents/antigravity/silly-tesla
```

### 2. Desplegar el primer laboratorio (FRR OSPF)

Puedes usar el `Makefile` incluido o los comandos directos de Containerlab:

```bash
# Con Make:
make deploy LAB=labs/01-frr-ospf/frr-ospf.clab.yml

# O directamente con containerlab:
sudo containerlab deploy -t labs/01-frr-ospf/frr-ospf.clab.yml
```

> **Nota:** La primera vez, Docker descargará automáticamente las imágenes públicas de `frrouting/frr` y `alpine`.

---

## 🔍 Comandos Útiles

| Acción | Comando con Make | Comando directo |
| :--- | :--- | :--- |
| **Ver estado y datos de conexión** | `make inspect LAB=...` | `sudo clab inspect -t <archivo.clab.yml>` |
| **Visualizar topología en el navegador** | `make graph LAB=...` | `sudo clab graph -t <archivo.clab.yml>` |
| **Destruir laboratorio y limpiar enlaces** | `make destroy LAB=...` | `sudo clab destroy -t <archivo.clab.yml> --cleanup` |
| **Limpiar carpetas temporales** | `make clean` | `sudo rm -rf clab-*` |

---

## 🧪 Pruebas en el Laboratorio FRR OSPF (`01-frr-ospf`)

Una vez desplegado:

1. **Entrar a la CLI de R1 (VTYSH de FRR):**
   ```bash
   docker exec -it clab-frr-ospf-r1 vtysh
   ```
   Comandos dentro de `vtysh`:
   ```text
   show ip ospf neighbor
   show ip route ospf
   exit
   ```

2. **Probar conectividad extremo a extremo desde PC1 hacia PC2:**
   ```bash
   docker exec -it clab-frr-ospf-pc1 ping -c 4 192.168.20.10
   ```

---

## 📦 Soporte de Fabricantes y Sistemas Operativos de Red

- **FRRouting (FRR):** Descarga pública automática. Ideal para pruebas de enrutamiento rápido (BGP, OSPF, IS-IS).
- **Nokia SR Linux:** Descarga pública automática (`ghcr.io/nokia/srlinux:latest`). Soporta gNMI, NETCONF y CLI completa.
- **Arista cEOS:** Requiere importar previamente la imagen `ceos:latest` descargada de Arista (ver instrucciones en [images/README.md](file:///c:/Users/bryan/Documents/antigravity/silly-tesla/images/README.md)).

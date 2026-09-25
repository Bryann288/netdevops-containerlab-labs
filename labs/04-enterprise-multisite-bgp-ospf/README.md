# Laboratorio Enterprise Multi-Site WAN con BGP & OSPF 🏢🌐

Este laboratorio emula la arquitectura de una empresa multinacional o con dos centros de datos (**DC-Alpha** y **DC-Bravo**) interconectados a través de un proveedor de servicios o núcleo WAN (**WAN-Core**).

---

## 📐 Topología y Diagrama de Red

```mermaid
flowchart TD
    subgraph WAN ["🌐 Núcleo WAN (AS 65000)"]
        wan["wan-r1<br/>AS 65000"]
    end

    subgraph DC1 ["🏢 Data Center Alpha (AS 65100)"]
        dc1_edge["dc1-edge<br/>AS 65100 / OSPF Area 0"]
        dc1_dist["dc1-dist<br/>OSPF Area 0"]
        dc1_srv["dc1-srv<br/>10.1.10.100/24"]
        
        dc1_srv ---|"10.1.10.0/24"| dc1_dist
        dc1_dist ---|"10.1.0.0/30"| dc1_edge
    end

    subgraph DC2 ["🏢 Data Center Bravo (AS 65200)"]
        dc2_edge["dc2-edge<br/>AS 65200 / OSPF Area 0"]
        dc2_dist["dc2-dist<br/>OSPF Area 0"]
        dc2_srv["dc2-srv<br/>10.2.10.100/24"]
        
        dc2_srv ---|"10.2.10.0/24"| dc2_dist
        dc2_dist ---|"10.2.0.0/30"| dc2_edge
    end

    dc1_edge ===|"eBGP (10.100.1.0/30)"| wan
    wan ===|"eBGP (10.100.2.0/30)"| dc2_edge

    classDef router fill:#2d3748,stroke:#cbd5e0,stroke-width:2px,color:#fff;
    classDef host fill:#2b6cb0,stroke:#bee3f8,stroke-width:2px,color:#fff;
    class wan,dc1_edge,dc1_dist,dc2_edge,dc2_dist router;
    class dc1_srv,dc2_srv host;
```

---

## 📊 Plan de Direccionamiento IP y Enrutamiento

| Dispositivo | Interfaz | Dirección IP | Función / Protocolo |
| :--- | :--- | :--- | :--- |
| **wan-r1** | `eth1` | `10.100.1.1/30` | eBGP Peering con DC1-Edge (AS 65000 <-> 65100) |
| | `eth2` | `10.100.2.1/30` | eBGP Peering con DC2-Edge (AS 65000 <-> 65200) |
| **dc1-edge** | `eth1` | `10.100.1.2/30` | eBGP Uplink a WAN-R1 |
| | `eth2` | `10.1.0.1/30` | OSPF Area 0 con DC1-Dist (Origina ruta default) |
| **dc1-dist** | `eth1` | `10.1.0.2/30` | OSPF Area 0 con DC1-Edge |
| | `eth2` | `10.1.10.1/24` | Gateway LAN para Servidores DC1 |
| **dc1-srv** | `eth1` | `10.1.10.100/24` | Servidor aplicación DC1 (GW: 10.1.10.1) |
| **dc2-edge** | `eth1` | `10.100.2.2/30` | eBGP Uplink a WAN-R1 |
| | `eth2` | `10.2.0.1/30` | OSPF Area 0 con DC2-Dist (Origina ruta default) |
| **dc2-dist** | `eth1` | `10.2.0.2/30` | OSPF Area 0 con DC2-Edge |
| | `eth2` | `10.2.10.1/24` | Gateway LAN para Servidores DC2 |
| **dc2-srv** | `eth1` | `10.2.10.100/24` | Servidor aplicación DC2 (GW: 10.2.10.1) |

---

## ⚙️ Principios de Arquitectura Implementados

1. **Segmentación de AS (Sistemas Autónomos):** Cada Datacenter actúa como un AS privado independiente (`65100` y `65200`), mientras que el núcleo WAN actúa como proveedor de tránsito (`65000`).
2. **IGP Interno (OSPF):** Cada Datacenter ejecuta internamente OSPF en Área 0 para máxima velocidad de convergencia y aislamiento de fallos internos.
3. **Redistribución de Rutas:** Los routers de borde (`dc1-edge` y `dc2-edge`) anuncian sus prefijos internos OSPF hacia la WAN mediante BGP, e inyectan una ruta predeterminada hacia el interior del Datacenter.
4. **Validación Automatizada:** El script `tests/verify-enterprise-wan.sh` comprueba de forma automática BGP, OSPF, tablas de enrutamiento, ping de datos y trazabilidad de 6 saltos.

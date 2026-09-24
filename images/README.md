# Directorio de Imágenes de Red (NOS)

Este directorio está pensado para almacenar archivos temporales de imágenes de fabricantes que requieren descarga manual (como Arista cEOS, Cisco XRD/c8000v, etc.). 
*Nota: Este directorio está ignorado en `.gitignore` para no subir archivos pesados al repositorio.*

---

## 1. Imágenes Públicas (Descarga automática)
No necesitas descargar nada manualmente para estos entornos; Docker las descargará al hacer `deploy`:
- **FRRouting (FRR)**: `frrouting/frr:latest`
- **Nokia SR Linux**: `ghcr.io/nokia/srlinux:latest`
- **Linux Hosts**: `alpine:latest` o `ghcr.io/hellt/network-multitool`

---

## 2. Arista cEOS
1. Descarga el paquete `cEOS-lab.tar` o `cEOS64-lab.tar` desde el portal de soporte de Arista ([Arista Software Downloads](https://www.arista.com/en/support/software-download)).
2. Importa la imagen en Docker ejecutando desde WSL:
   ```bash
   docker import cEOS-lab.tar ceos:latest
   ```
3. Verifica que la imagen esté disponible:
   ```bash
   docker images | grep ceos
   ```

---

## 3. Cisco (IOL / XRd / c8000v)
Si utilizas contenedores Cisco XRd o máquinas virtuales integradas vía vrnetlab:
- Sigue las instrucciones oficiales de Containerlab: [https://containerlab.dev/manual/kinds/cisco/](https://containerlab.dev/manual/kinds/cisco/)

# Network Operating System (NOS) Images

This directory is intended for local storage of vendor network images that require manual download or licensing (such as Arista cEOS, Cisco XRd, or Cisco 8000v).

Large archive files (`*.tar`, `*.qcow2`, etc.) located in this directory are ignored by `.gitignore` to prevent committing heavy binaries.

---

## 1. Public Images (Automatic Download)

The following container images are publicly hosted and downloaded automatically during `containerlab deploy`:

- **FRRouting (FRR):** `frrouting/frr:latest`
- **Nokia SR Linux:** `ghcr.io/nokia/srlinux:latest`
- **Linux Hosts:** `alpine:latest`

---

## 2. Arista cEOS

1. Download the `cEOS-lab.tar` or `cEOS64-lab.tar` package from the [Arista Software Downloads](https://www.arista.com/en/support/software-download) portal.
2. Import the image into Docker:
   ```bash
   docker import cEOS-lab.tar ceos:latest
   ```
3. Verify local image availability:
   ```bash
   docker images | grep ceos
   ```

---

## 3. Cisco (XRd / 8000v / IOL)

Refer to the official Containerlab documentation for vendor-specific image guidelines:
- [Containerlab Cisco Kind Documentation](https://containerlab.dev/manual/kinds/cisco/)

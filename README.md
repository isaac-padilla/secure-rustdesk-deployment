# 🛡️ Secure Remote Support Infrastructure (Zero-Cost)

![Ubuntu](https://img.shields.io/badge/OS-Ubuntu_22.04_LTS-orange?logo=ubuntu)
![Docker](https://img.shields.io/badge/Orchestration-Docker_Compose-blue?logo=docker)
![Security](https://img.shields.io/badge/Security-Zero--Trust_%7C_E2EE-green)

Self-hosted, enterprise-grade remote support server architecture deploying **RustDesk** with forced **End-to-End Encryption (E2EE)**, **Tailscale Zero-Trust network segmentation**, and strict **UFW firewall hardening** on Ubuntu Server 22.04 LTS.

---

## 🏗️ Architecture Overview

```text
+-----------------------------------------------------------------------+
|                             INTERNET / PUBLIC                         |
+-----------------------------------------------------------------------+
                                    |
             [ Public Traffic Blocked by Default (UFW) ]
                                    |
  +---------------------------------+---------------------------------+
  |                                                                   |
  v (Encrypted RustDesk Traffic)                                      v (Management Tunnel)
+------------------------------------+                             +-----------------------------------+
| RustDesk Ports (21115-21119/tcp,   |                             | Tailscale Mesh Network            |
|                 21116/udp)         |                             | (tailscale0 Interface)            |
+------------------------------------+                             +-----------------------------------+
                  |                                                              |
                  v                                                              v
+-----------------------------------------------------------------------------------------------------+
| UBUNTU SERVER 22.04 LTS (HOST)                                                                      |
|                                                                                                     |
|  +---------------------------+       +---------------------------+       +-----------------------+  |
|  | UFW Firewall Engine       |       | SSH Server (Port 22)      |       | CasaOS Management UI  |  |
|  | Default Incoming: DENY    |       | ED25519 Keys Only         |       | Port 80               |  |
|  +---------------------------+       +---------------------------+       +-----------------------+  |
|                                                ^                                     ^              |
|                                                | (Tailscale Only)                    | (Tailscale)  |
|  +-----------------------------------------------------------------------------------------------+  |
|  | DOCKER CONTAINER ENGINE (HOST NETWORK MODE)                                                   |  |
|  |                                                                                               |  |
|  |   +--------------------------+                 +--------------------------+                   |  |
|  |   | rustdesk-hbbs (Signal)   | <-------------> | rustdesk-hbbr (Relay)    |                   |  |
|  |   | Forced E2EE (-k _)       |                 | Forced E2EE (-k _)       |                   |  |
|  +---|--------------------------+-----------------|--------------------------+-------------------+  |
+-----------------------------------------------------------------------------------------------------+

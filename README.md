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

🔒 Security Posture & Hardening
Identity & Access Management (IAM):

Restricted SSH access enforcing ED25519 cryptographic key pairs with passphrase protection.

Disabled root login (PermitRootLogin no) and password authentication (PasswordAuthentication no).

Zero-Trust Network Perimeter:

Network overlay configured using Tailscale.

Uncomplicated Firewall (UFW) default deny incoming policy.

Management interfaces (SSH / CasaOS) exposed exclusively over the tailscale0 VPN mesh.

Application Encryption:

Enforced End-to-End Encryption (E2EE) on RustDesk (hbbs/hbbr) via mandatory public key verification (-k _).

🚀 Quickstart & Reproduction Guide
Prerequisites
Linux Server (Ubuntu 22.04 LTS recommended)

Docker & Docker Compose installed

Tailscale installed and authenticated

1. Clone the Repository
Bash
git clone [https://github.com/isaac-padilla/secure-rustdesk-deployment.git](https://github.com/isaac-padilla/secure-rustdesk-deployment.git)
cd secure-rustdesk-deployment
2. Configure Environment Variables
Bash
cp .env.example .env
# Edit .env and set RELAY_IP to your Tailscale IP or Server Domain
nano .env
3. Apply Firewall Hardening Script
Bash
sudo ./scripts/setup-ufw.sh
4. Deploy Infrastructure
Bash
docker compose up -d
5. Retrieve Public Key for Clients
Bash
cat ./data/id_ed25519.pub

---

Puedes editar cada archivo haciendo clic en el icono del lápiz ✏️ en la interfaz web de tu reposit

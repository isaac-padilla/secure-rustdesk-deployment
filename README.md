# 🛡️ Secure Remote Support Infrastructure (Zero-Cost)

🌐 **Languages:** [English](#english) | [Español](#español)

---

<a name="english"></a>
# 🇬🇧 English

![Ubuntu](https://img.shields.io/badge/OS-Ubuntu_22.04_LTS-orange?logo=ubuntu)
![Docker](https://img.shields.io/badge/Orchestration-Docker_Compose-blue?logo=docker)
![Security](https://img.shields.io/badge/Security-Zero--Trust_%7C_E2EE-green)

Self-hosted, enterprise-grade remote support server architecture deploying **RustDesk** with forced **End-to-End Encryption (E2EE)**, **Tailscale Zero-Trust network segmentation**, and strict **UFW firewall hardening** on Ubuntu Server 22.04 LTS.

---

## 🔒 Security Posture & Hardening

1. **Identity & Access Management (IAM):**
   * Restricted SSH access enforcing **ED25519** cryptographic key pairs with passphrase protection.
   * Disabled root login (`PermitRootLogin no`) and password authentication (`PasswordAuthentication no`).

2. **Zero-Trust Network Perimeter:**
   * Network overlay configured using **Tailscale**.
   * **Uncomplicated Firewall (UFW)** default deny incoming policy.
   * Management interfaces (SSH / CasaOS) exposed **exclusively** over the `tailscale0` VPN mesh.

3. **Application Encryption:**
   * Enforced End-to-End Encryption (E2EE) on RustDesk (`hbbs`/`hbbr`) via mandatory public key verification (`-k _`).

---

## 🔄 Intermediary Role: How RustDesk Connects Peers

The self-hosted RustDesk infrastructure functions as an encrypted rendezvous and relay bridge between two isolated clients (Control & Target):

```text
[ Client A (Control) ]                                             [ Client B (Target) ]
         |                                                                   |
         |--------- 1. Register ID & Public Key to Signal (hbbs) ----------->|
         |                                                                   |
         |<-------- 2. Perform NAT Traversal / Direct P2P Attempt ---------->|
         |                                                                   |
         |=== IF DIRECT P2P FAILS (STRICT NAT / FIREWALL) ===================|
         |                                                                   |
         v                                                                   v
  +---------------------------------------------------------------------------------+
  |                       RUSTDESK RELAY SERVER (hbbr)                              |
  |     (Relays E2EE encrypted video & control stream without inspecting data)      |
  +---------------------------------------------------------------------------------+
```

1. **Signaling & Rendezvous (`hbbs`):**
   * Acts as the directory service. Both clients register their ID, IP, and public key with `hbbs`.
   * When Client A requests a session with Client B, `hbbs` matches their metadata and attempts to establish a direct Peer-to-Peer (P2P) hole-punched connection.

2. **Traffic Relay Proxy (`hbbr`):**
   * If firewalls or strict NAT configurations block direct P2P traffic, both clients automatically fallback to `hbbr`.
   * `hbbr` acts as a high-throughput encrypted proxy, passing raw encrypted control streams bidirectionally between the peers.
   * **Zero-Knowledge Security:** Because End-to-End Encryption (`-k _`) is enforced, the relay server carries the payload without reading screen data or input commands.

---

## 🚀 Quickstart & Reproduction Guide

### Prerequisites
* Linux Server (Ubuntu 22.04 LTS recommended)
* Docker & Docker Compose installed
* Tailscale installed and authenticated

### 1. Clone the Repository
```bash
git clone [https://github.com/isaac-padilla/secure-rustdesk-deployment.git](https://github.com/isaac-padilla/secure-rustdesk-deployment.git)
cd secure-rustdesk-deployment
```

### 2. Configure Environment Variables
```bash
cp .env.example .env
# Edit .env and set RELAY_IP to your Tailscale IP or Server Domain
nano .env
```

### 3. Apply Firewall Hardening Script
```bash
sudo ./scripts/setup-ufw.sh
```

### 4. Deploy Infrastructure
```bash
docker compose up -d
```

### 5. Retrieve Public Key for Clients
```bash
cat ./data/id_ed25519.pub
```

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
```

---

<a name="español"></a>
# 🇪🇸 Español

![Ubuntu](https://img.shields.io/badge/SO-Ubuntu_22.04_LTS-orange?logo=ubuntu)
![Docker](https://img.shields.io/badge/Orquestaci%C3%B3n-Docker_Compose-blue?logo=docker)
![Security](https://img.shields.io/badge/Seguridad-Zero--Trust_%7C_E2EE-green)

Arquitectura de servidor de soporte remoto auto-hospedada y de nivel empresarial utilizando **RustDesk** con **Cifrado de Extremo a Extremo (E2EE)** forzado, **segmentación de red Zero-Trust con Tailscale** y **bastionamiento estricto de firewall con UFW** sobre Ubuntu Server 22.04 LTS.

---

## 🔒 Postura de Seguridad y Bastionamiento

1. **Gestión de Identidad y Accesos (IAM):**
   * Acceso SSH restringido forzando pares de llaves criptográficas **ED25519** protegidas con frase de paso.
   * Inicio de sesión de root desactivado (`PermitRootLogin no`) y autenticación por contraseña deshabilitada (`PasswordAuthentication no`).

2. **Perímetro de Red Zero-Trust:**
   * Red superpuesta (Overlay) configurada mediante **Tailscale**.
   * Política por defecto de rechazo entrante en **Uncomplicated Firewall (UFW)**.
   * Interfaces de gestión (SSH / CasaOS) expuestas **exclusivamente** a través de la red mesh `tailscale0`.

3. **Cifrado a Nivel de Aplicación:**
   * Cifrado de Extremo a Extremo (E2EE) forzado en RustDesk (`hbbs`/`hbbr`) mediante verificación obligatoria de llave pública (`-k _`).

---

## 🔄 Rol Intermediario: Cómo Conecta RustDesk a los Equipos

La infraestructura auto-hospedada de RustDesk funciona como un puente encriptado de encuentro y retransmisión entre dos clientes aislados (Controlador y Destino):

```text
[ Cliente A (Control) ]                                            [ Cliente B (Destino) ]
         |                                                                   |
         |-------- 1. Registro de ID y Llave Pública en Señal (hbbs) ------>|
         |                                                                   |
         |<------- 2. Intento de Conexión P2P Directa (NAT Traversal) ------>|
         |                                                                   |
         |=== SI EL P2P DIRECTO FALLA (FIREWALL / NAT ESTRICTO) =============|
         |                                                                   |
         v                                                                   v
  +---------------------------------------------------------------------------------+
  |                       SERVIDOR DE RELAY RUSTDESK (hbbr)                         |
  | (Retransmite el flujo de video y control cifrado E2EE sin inspeccionar datos)   |
  +---------------------------------------------------------------------------------+
```

1. **Señalización y Encuentro (`hbbs`):**
   * Funciona como directorio central. Ambos clientes registran su ID, dirección IP y llave pública en `hbbs`.
   * Cuando el Cliente A solicita conectar con el Cliente B, `hbbs` vincula sus metadatos e intenta establecer una conexión directa Punto a Punto (P2P).

2. **Proxy de Retransmisión de Tráfico (`hbbr`):**
   * Si los firewalls o configuraciones de NAT estricto bloquean el tráfico P2P directo, ambos clientes alternan automáticamente hacia `hbbr`.
   * `hbbr` actúa como un proxy cifrado de alto rendimiento, retransmitiendo el flujo cifrado de control e imagen bidireccionalmente.
   * **Seguridad de Conocimiento Cero (Zero-Knowledge):** Al estar forzado el cifrado de extremo a extremo (`-k _`), el servidor de relay transporta los paquetes sin capacidad de leer datos de pantalla o comandos de entrada.

---

## 🚀 Guía de Inicio Rápido y Reproducción

### Requisitos Previos
* Servidor Linux (Ubuntu 22.04 LTS recomendado)
* Docker y Docker Compose instalados
* Tailscale instalado y autenticado

### 1. Clonar el Repositorio
```bash
git clone [https://github.com/isaac-padilla/secure-rustdesk-deployment.git](https://github.com/isaac-padilla/secure-rustdesk-deployment.git)
cd secure-rustdesk-deployment
```

### 2. Configurar Variables de Entorno
```bash
cp .env.example .env
# Edita .env y asigna tu IP de Tailscale o Dominio en RELAY_IP
nano .env
```

### 3. Aplicar Script de Firewall
```bash
sudo ./scripts/setup-ufw.sh
```

### 4. Desplegar la Infraestructura
```bash
docker compose up -d
```

### 5. Obtener Llave Pública para Clientes
```bash
cat ./data/id_ed25519.pub
```

---

## 🏗️ Visión General de la Arquitectura

```text
+-----------------------------------------------------------------------+
|                             INTERNET / PÚBLICO                        |
+-----------------------------------------------------------------------+
                                    |
           [ Tráfico Público Bloqueado por Defecto (UFW) ]
                                    |
  +---------------------------------+---------------------------------+
  |                                                                   |
  v (Tráfico Encritado RustDesk)                                      v (Túnel de Gestión)
+------------------------------------+                             +-----------------------------------+
| Puertos RustDesk (21115-21119/tcp, |                             | Red Mesh Tailscale                |
|                  21116/udp)        |                             | (Interfaz tailscale0)             |
+------------------------------------+                             +-----------------------------------+
                  |                                                              |
                  v                                                              v
+-----------------------------------------------------------------------------------------------------+
| UBUNTU SERVER 22.04 LTS (HOST)                                                                      |
|                                                                                                     |
|  +---------------------------+       +---------------------------+       +-----------------------+  |
|  | Motor de Firewall UFW     |       | Servidor SSH (Puerto 22)  |       | Interfaz CasaOS       |  |
|  | Entrada por Defecto: DENY |       | Solo Llaves ED25519       |       | Puerto 80             |  |
|  +---------------------------+       +---------------------------+       +-----------------------+  |
|                                                ^                                     ^              |
|                                                | (Solo Tailscale)                    | (Tailscale)  |
|  +-----------------------------------------------------------------------------------------------+  |
|  | MOTOR DOCKER CONTAINER (MODO HOST NETWORK)                                                    |  |
|  |                                                                                               |  |
|  |   +--------------------------+                 +--------------------------+                   |  |
|  |   | rustdesk-hbbs (Señal)    | <-------------> | rustdesk-hbbr (Relay)    |                   |  |
|  |   | E2EE Forzado (-k _)      |                 | E2EE Forzado (-k _)      |                   |  |
|  +---|--------------------------+-----------------|--------------------------+-------------------+  |
+-----------------------------------------------------------------------------------------------------+
```

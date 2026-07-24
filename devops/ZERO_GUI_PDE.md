# Zero-GUI Cloud Personal Development Environment (PDE)

Terminal-only remote dev environment accessible over Wi-Fi from any device.

---

## Architecture

```
┌────────────────────────────────────────────────────────────────────────┐
│                   CLIENT DEVICE (Laptop, Tablet, Phone)                │
│                     Terminal Emulator / SSH Client                     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Private WireGuard Mesh (Tailscale)
┌───────────────────────────────────▼────────────────────────────────────┐
│                    REMOTE CLOUD SERVER / VPS                           │
│ ┌────────────────────────────────────────────────────────────────────┐ │
│ │ tmux (Persistent Session Engine)                                   │ │
│ │  ├── Pane 1: Neovim / OpenCode CLI (Editor & AI Assistant)         │ │
│ │  ├── Pane 2: LazyGit / LazyDocker (Terminal UI Management)         │ │
│ │  └── Pane 3: FastAPI / Scrapy Logs & Server Shell                  │ │
│ └────────────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Infrastructure

### Cloud Node

- **Hetzner**, **AWS EC2**, or **DigitalOcean** VPS
- Or run a dedicated home server

### Network Mesh (Tailscale)

1. Install Tailscale on cloud server and client devices
2. Creates encrypted WireGuard mesh — connect via private IP
3. No public SSH ports needed

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Start and authenticate
sudo tailscale up
```

### Connection Persistence (Mosh)

Use `mosh` over SSH — maintains terminal state through Wi-Fi drops and device sleep.

```bash
# Install
sudo apt install mosh

# Connect
mosh user@tailscale-ip
```

---

## Session Persistence (tmux)

tmux server stays running on the cloud node — all editor states, background processes, and AI sessions survive network disconnections.

### Commands

```bash
# Start named session
tmux new -s dev

# Detach (leave running)
# Prefix + d  (default prefix: Ctrl+b)

# Reattach
tmux attach -t dev

# List sessions
tmux ls

# Kill session
tmux kill-session -t dev
```

---

## Terminal UI Toolchain

| Capability | Graphical Tool | TUI Replacement |
|---|---|---|
| **Code Editing & AI** | VS Code / Cursor | Neovim / OpenCode CLI |
| **Version Control** | GitHub Desktop / GitKraken | lazygit |
| **Containers** | Docker Desktop | lazydocker |
| **Kubernetes** | Lens | k9s |
| **System Monitor** | Activity Monitor | btop |

### Install

```bash
# Neovim
sudo apt install neovim

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# lazydocker
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${VERSION}_Linux_x86_64.tar.gz"
tar xf lazydocker.tar.gz lazydocker
sudo install lazydocker /usr/local/bin

# btop
sudo apt install btop
```

---

## Local Parity vs Cloud Orchestration

| Environment | Tool | Purpose |
|---|---|---|
| Local dev | Docker Compose | Fast multi-container development |
| K8s testing | k3d (K3s in Docker) | Validate cluster behavior with k9s |
| Observability | OpenObserve | Logs, metrics, traces from all services |

---

## Workflow

```bash
# 1. Connect from any device
mosh user@tailscale-ip

# 2. Reattach to running session
tmux attach -t dev

# 3. Edit code (Neovim)
nvim .

# 4. Git operations (lazygit)
lazygit

# 5. Monitor containers (lazydocker)
lazydocker

# 6. Check system resources
btop
```

---

## Common Gotchas

| Gotcha | Solution |
|---|---|
| tmux session lost | Never happens — server stays running. Use `tmux attach` to reconnect |
| Mosh disconnects on sleep | Mosh is designed for this — reattaches automatically |
| Tailscale IP changes | Tailscale IPs are stable per device — won't change |
| SSH key auth fails over Tailscale | Tailscale handles auth — use password or configure SSH keys separately |

---

## Further Reading

- [PDE Guide (full doc)](../reference/pdfs/Zero-GUI%20Cloud%20Personal%20Development%20Environment%20(PDE)%20Guide.docx)
- [Tailscale Docs](https://tailscale.com/kb)
- [tmux Wiki](https://github.com/tmux/tmux/wiki)

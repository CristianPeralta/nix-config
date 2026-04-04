# Branch `lapro` — Lenovo V14 IIL (Cristian)

> Fork de [wochap/nix-config](https://github.com/wochap/nix-config) adaptado para el Lenovo V14 IIL.
> Branch: `lapro` | Host: `lenovo-v14`

---

## Hardware

| Componente | Detalle |
|---|---|
| Modelo | Lenovo V14 IIL |
| CPU | Intel Core i7-1065G7 (Ice Lake) — 4c/8t — hasta 3.9GHz |
| GPU | Intel Iris Plus Graphics G7 (integrada) — `i915` |
| RAM | 8GB DDR4 |
| Disco | Kingston SNV2S500G — NVMe 500GB |
| WiFi | Realtek RTL8822CE (PCIe) — `rtl8822ce` module |
| Bluetooth | Realtek USB — `0bda:c02f` |
| Audio | Intel Ice Lake-LP Smart Sound Technology (SOF) |
| Cámara | Acer Integrated Camera — USB `5986:1135` |
| Boot | UEFI |
| Batería | ~75% salud (22.7Wh de 30Wh diseño) |

---

## Qué cambiamos vs wochap/nix-config

### Removido
- Soporte Nvidia / AMD GPU — solo Intel Iris integrada
- Gaming (Steam, emuladores, Proton)
- AI local (Whisper, Ollama) — sin GPU, sin sentido
- Virtualización (KVM/libvirt) — 8GB RAM no alcanza cómodamente
- Módulos Lenovo Legion — no aplica
- Android SDK — no prioritario

### Adaptado
- Driver WiFi: `rtl8822ce` en lugar de `mt7921e` (wochap usa MediaTek)
- GPU: Intel `i915` + `intel-media-driver` (VAAPI) en lugar de AMD/Nvidia
- Audio: Intel SOF con `snd_sof_pci_intel_icl`
- Energía: modo `Balanced` en lugar de `Performance` (laptop con batería)
- Zona horaria: `America/Lima` (Perú)
- Usuario: `cristian`

### Conservado
- Hyprland como WM principal
- Home Manager para config de usuario
- Catppuccin Mocha como tema
- Stack dev: Neovim, tmux, git, Docker, Node.js, Python
- Syncthing (sincronización vault Obsidian)
- zsh + todas las CLI tools

---

## Fases de migración

### Fase A — Estado actual (base funcional)
- Hyprland + herramientas dev esenciales
- Sin AI local, sin gaming
- Objetivo: estar productivo rápido

### Fase B — Cuando haya tiempo
- Configurar Hyprland más keyboard-driven (inspirado en wochap)
- Explorar Neovim como editor principal
- Ajustar keybindings al flujo sin mouse
- Referencias: `hosts/glegion/` de wochap

---

## Instalación

### 1. Grabar ISO
```bash
# Desde la PC principal, descargar ISO NixOS GNOME (para tener entorno gráfico durante instalación)
wget https://channels.nixos.org/nixos-25.05/latest-nixos-gnome-x86_64-linux.iso
# Grabar en USB (reemplazar /dev/sdX con tu USB)
sudo dd if=latest-nixos-gnome-x86_64-linux.iso of=/dev/sdX bs=4M status=progress
```

### 2. Instalar NixOS base
Arrancar desde USB → instalar con particionado automático (UEFI) → usuario `cristian`.

### 3. Clonar este repo y aplicar config
```bash
nix-shell -p git
git clone git@github.com:CristianPeralta/nix-config.git ~/nix-config
cd ~/nix-config
git checkout lapro

# Generar hardware-configuration.nix de esta máquina
sudo nixos-generate-config --show-hardware-config > hosts/lenovo-v14/hardware-configuration.nix

# Aplicar configuración (boot en primera vez — config grande, no switch)
sudo nixos-rebuild boot --flake .#lenovo-v14 --max-jobs 1
sudo reboot
```

---

## Sync con upstream (wochap)

```bash
# Traer actualizaciones de wochap sin perder nuestros cambios
git fetch upstream
git rebase upstream/main
# Resolver conflictos si los hay en hosts/lenovo-v14/
```

---

## Notas conocidas

- **WiFi RTL8822CE**: si hay desconexiones, verificar `options rtl8822ce ips=0` en `hardware.nix`
- **Audio SOF**: si no hay sonido, verificar que `sof-firmware` esté instalado y `snd_sof_pci_intel_icl` cargado
- **Backlight**: completar `_custom.desktop.wluma.config.output.backlight[].name` con el nombre real del display tras instalar
- **NVMe LUKS**: si se usa cifrado, agregar UUID en `hardware.nix` para `bypassWorkqueues`
- **Batería**: enchufar siempre en sesiones largas (~2.5h máximo en activo)

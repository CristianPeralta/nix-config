{ config, pkgs, ... }:

# ============================================================
# Lenovo V14 IIL — Host Configuration
# ============================================================
# Rol: máquina de trabajo móvil (casa, casa del hermano, etc.)
# OS target: NixOS con Hyprland (Wayland)
# Fase actual: A (Hyprland base, sin gaming, sin AI local)
# Migración a Fase B: descomentar módulos marcados [FASE-B]
# ============================================================

let
  userName = "cristian";
  hmConfig = config.home-manager.users.${userName};
  configDirectory = "${hmConfig.home.homeDirectory}/nix-config";
in {
  imports = [
    ./hardware-configuration.nix  # generado por nixos-generate-config
    ./hardware.nix
  ];

  config = {
    _custom.globals.userName = userName;
    _custom.globals.homeDirectory = "/home/${userName}";
    _custom.globals.configDirectory = configDirectory;
    _custom.globals.preferDark = true;

    # ── Shell ────────────────────────────────────────────────
    _custom.programs.zsh.enable = true;
    _custom.programs.zsh.isDefault = true;
    _custom.programs.core-utils.enable = true;
    _custom.programs.core-utils-linux.enable = true;
    _custom.programs.core-utils-extra.enable = true;
    _custom.programs.core-utils-extra-linux.enable = true;
    _custom.programs.nix-direnv.enable = true;

    # ── CLI tools ────────────────────────────────────────────
    _custom.programs.bat.enable = true;
    _custom.programs.fzf.enable = true;
    _custom.programs.git.enable = true;
    _custom.programs.git.enableUser = true;
    _custom.programs.lazygit.enable = true;
    _custom.programs.lsd.enable = true;
    _custom.programs.zoxide.enable = true;
    _custom.programs.dircolors.enable = true;

    # ── TUI / Editor ─────────────────────────────────────────
    _custom.programs.neovim.enable = true;
    _custom.programs.tmux.enable = true;
    _custom.programs.tmux.systemdEnable = true;
    _custom.programs.bottom.enable = true;
    _custom.programs.less.enable = true;
    _custom.programs.taskwarrior.enable = true; # requerido por quickshell (TIMEWARRIORDB)

    # ── Dev ──────────────────────────────────────────────────
    _custom.programs.lang-nix.enable = true;
    _custom.programs.lang-web.enable = true;      # Node.js, npm, etc.
    _custom.programs.lang-python.enable = true;
    _custom.programs.tools.enable = true;

    # ── GUI ──────────────────────────────────────────────────
    _custom.programs.firefox.enable = true;
    _custom.programs.foot.enable = true;
    _custom.programs.foot.systemdEnable = true;
    _custom.programs.kitty.enable = true;
    _custom.programs.vscode.enable = true;
    _custom.programs.electron.enable = true;
    _custom.programs.gtk.enable = true;
    _custom.programs.qt.enable = true;
    _custom.programs.imv.enable = true;           # Visor de imágenes
    _custom.programs.zathura.enable = true;       # Visor PDF

    # ── Servicios ────────────────────────────────────────────
    _custom.services.docker.enable = true;
    _custom.services.docker.enableNvidia = false; # Sin Nvidia
    _custom.services.syncthing.enable = true;     # Sync vault Obsidian
    _custom.services.kdeconnect.enable = true;    # Integración celular
    _custom.services.interception-tools.enable = true; # Remap teclado

    # NO activar en esta máquina:
    # _custom.services.ai.enable = false;         # Sin GPU → sin Whisper/Ollama
    # _custom.gaming.steam.enable = false;        # No es máquina gaming
    # _custom.services.virt.enable = false;       # 8GB RAM no alcanza cómodo

    # ── Desktop / WM ─────────────────────────────────────────
    _custom.desktop.hyprland.enable = true;
    _custom.desktop.hyprland.isDefault = true;
    _custom.desktop.greetd.enable = true;
    _custom.desktop.greetd.enableAutoLogin = false;
    _custom.desktop.greetd.enablePamAutoLogin = true;
    _custom.desktop.xwaylandvideobridge.enable = false; # removido en nixpkgs 24.11+

    # Cursor
    _custom.desktop.cursor.name = "catppuccin-mocha-dark-cursors";
    _custom.desktop.cursor.size = 24;

    # Brillo automático (sin sensor de luz → none)
    _custom.desktop.wluma.enable = true;
    _custom.desktop.wluma.systemdEnable = true;
    _custom.desktop.wluma.config.als.none = { };
    _custom.desktop.wluma.config.output.backlight = [{
      name = ""; # completar con nombre del display tras instalar
      path = "/sys/class/backlight/intel_backlight";
      capturer = "wayland";
    }];

    # Temperatura de pantalla (redshift para Wayland)
    _custom.desktop.hyprsunset.enable = true;

    # Reducir consumo en laptop
    _custom.desktop.audio.enableEasyeffects = false;
    _custom.desktop.audio.enableNoisetorch = false;
    _custom.desktop.power-management.cpupowerGuiArgs =
      [ "--performance" "profile" "Balanced" ]; # Balanced > Performance en laptop

    _custom.archetypes.wm-wayland-desktop.enable = true;
    _custom.security.gnome-keyring.enable = true;

    # ── Teclado ──────────────────────────────────────────────
    services.xserver.xkb = {
      layout = "us";
      model = "pc104";
      variant = "";
      options = "compose:ralt";
    };

    # ── SSH ──────────────────────────────────────────────────
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
    users.users.${userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0GgK5D1TB3A4vPB/GrLdIv7bKV8eSvIBkJOMI3xVfH cristian@pc"
    ];

    # ── Zona horaria ─────────────────────────────────────────
    time.timeZone = "America/Lima"; # Peru

    # ── Versiones de estado ──────────────────────────────────
    # Completar con la versión de NixOS al momento de instalar
    system.stateVersion = "25.05";
    home-manager.users.${userName}.home.stateVersion = "25.05";
  };
}

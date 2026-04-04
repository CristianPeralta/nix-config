{ config, pkgs, ... }:

# ============================================================
# Lenovo V14 IIL — Host Configuration (MINIMAL)
# ============================================================
# Estrategia: mínimo viable primero, activar módulos de a poco
# Referencia glegion/default.nix para ver opciones disponibles
# ============================================================

let
  userName = "cristian";
  hmConfig = config.home-manager.users.${userName};
  configDirectory = "${hmConfig.home.homeDirectory}/nix-config";
in {
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
  ];

  config = {
    _custom.globals.userName = userName;
    _custom.globals.homeDirectory = "/home/${userName}";
    _custom.globals.configDirectory = configDirectory;
    _custom.globals.preferDark = true;

    # ── Mínimo esencial ──────────────────────────────────────
    _custom.programs.zsh.enable = true;
    _custom.programs.zsh.isDefault = true;
    _custom.programs.core-utils.enable = true;
    _custom.programs.core-utils-linux.enable = true;
    _custom.programs.git.enable = true;
    _custom.programs.git.enableUser = true;
    _custom.programs.taskwarrior.enable = true; # requerido por quickshell

    # ── Desktop mínimo ───────────────────────────────────────
    _custom.desktop.hyprland.enable = true;
    _custom.desktop.hyprland.isDefault = true;
    _custom.desktop.greetd.enable = true;
    _custom.desktop.greetd.enableAutoLogin = false;
    _custom.desktop.greetd.enablePamAutoLogin = true;
    _custom.desktop.xwaylandvideobridge.enable = false;
    _custom.desktop.cursor.name = "catppuccin-mocha-dark-cursors";
    _custom.desktop.cursor.size = 24;
    _custom.desktop.audio.enableEasyeffects = false;
    _custom.desktop.audio.enableNoisetorch = false;
    _custom.desktop.wluma.enable = false;
    _custom.desktop.hyprsunset.enable = false;

    _custom.archetypes.wm-wayland-desktop.enable = true;
    _custom.security.gnome-keyring.enable = true;

    # ── Red ─────────────────────────────────────────────────
    # RTL8822CE conflicta con iwd — usar NetworkManager
    networking.wireless.iwd.enable = false;
    networking.networkmanager.enable = true;

    # ── Usuario ──────────────────────────────────────────────
    users.users.${userName}.initialPassword = "cambiar123";
    users.users.${userName}.extraGroups = [ "networkmanager" ];

    # ── SSH ──────────────────────────────────────────────────
    services.openssh.enable = true;
    services.openssh.settings.PasswordAuthentication = false;
    users.users.${userName}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0GgK5D1TB3A4vPB/GrLdIv7bKV8eSvIBkJOMI3xVfH cristian@pc"
    ];

    # ── Sistema ──────────────────────────────────────────────
    services.xserver.xkb = {
      layout = "us";
      model = "pc104";
      variant = "";
      options = "compose:ralt";
    };

    time.timeZone = "America/Lima";

    system.stateVersion = "24.11";
    home-manager.users.${userName}.home.stateVersion = "24.11";
  };
}

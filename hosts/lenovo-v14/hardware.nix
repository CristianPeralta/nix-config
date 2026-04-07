{ config, inputs, lib, pkgs, ... }:

# ============================================================
# Lenovo V14 IIL — Hardware Configuration
# ============================================================
# Machine: Lenovo V14 IIL (reciclada, uso personal de Cristian)
# CPU:     Intel Core i7-1065G7 (Ice Lake) — 4c/8t — hasta 3.9GHz
# GPU:     Intel Iris Plus Graphics G7 (integrada, i915)
# RAM:     8GB DDR4
# Disco:   Kingston SNV2S500G — NVMe 500GB
# WiFi:    Realtek RTL8822CE (PCIe) — 802.11ac
# BT:      Realtek (USB, 0bda:c02f)
# Audio:   Intel Ice Lake-LP Smart Sound Technology (SOF)
# Camara:  Acer Integrated Camera (USB 5986:1135)
# Boot:    UEFI
# ============================================================

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    # ── CPU ─────────────────────────────────────────────────
    hardware.cpu.intel.updateMicrocode = true;

    # ── GPU (Intel Iris Plus G7 / i915) ─────────────────────
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver  # VAAPI para video acceleration (Ice Lake+)
        intel-compute-runtime
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    # ── WiFi: Realtek RTL8822CE ──────────────────────────────
    # Kernel 6.x tiene soporte nativo via rtw89 — no necesita módulo extra
    # Si WiFi no funciona, probar: boot.kernelModules = [ "rtw89_8822ce" ];
    boot.extraModprobeConfig = ''
      options rtw89_8822ce disable_ps=1
    '';

    # ── Audio: Intel SOF (Sound Open Firmware) ───────────────
    # Ice Lake usa SOF en lugar del HDA tradicional
    hardware.enableAllFirmware = true;
    boot.initrd.availableKernelModules = [ "snd_sof_pci_intel_icl" "i915" ];

    # ── Boot ─────────────────────────────────────────────────
    boot.kernelParams = [
      "i915.enable_psr=0"       # Evita flickering en pantalla (común en Ice Lake)
      "acpi_osi=Linux"
      "mem_sleep_default=deep"  # Mejor consumo en suspend
      "acpi_mask_gpe=0x43"      # Deshabilita GPE 43 (loop de interrupciones ACPI)
    ];

    # ── NVMe: optimización de rendimiento ────────────────────
    # Kingston SNV2S500G
    # bypassWorkqueues mejora latencia en SSDs modernos
    # (completar con UUID real del disco tras instalar)
    # boot.initrd.luks.devices."luks-XXXX".bypassWorkqueues = true;

    # ── Gestión de energía ───────────────────────────────────
    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;  # Gestión térmica Intel

    # ── RAM: zram swap ───────────────────────────────────────
    # 8GB RAM → zram comprimido mejora rendimiento sin swap en disco
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };

    # ── Pantalla / backlight ─────────────────────────────────
    programs.light.enable = true;  # Control de brillo sin root

    # ── Touchpad ─────────────────────────────────────────────
    services.libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };

    # ── Firmware redistribuible ──────────────────────────────
    hardware.enableRedistributableFirmware = true;
  };
}

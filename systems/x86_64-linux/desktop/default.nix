{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./disko-config.nix
    ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
	      enable = true;
	      device = "nodev";
	      efiSupport = true;
      };	
    };
  };

  networking = {
    hostName = "desktop";
    networkmanager.enable = true;
    networkmanager.dns = "none";
    useDHCP = false;
    dhcpcd.enable = false;
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    firewall.enable = false;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Lisbon";

  console = {
    # font = "Lat2-Terminus16";
    font = "${pkgs.terminus_font}/share/consolefonts/ter-120n.psf.gz";
    keyMap = "pt-latin1";
    earlySetup = true;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    # Configure keymap
    xkb.layout = "pt";
    autoRepeatDelay = 300;
    autoRepeatInterval = 20;
    # Load nvidia driver for Xorg and Wayland
    videoDrivers = ["nvidia"];
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;
    # Enable the Nvidia settings menu,
	  # accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = true;
      # Make sure to use the correct Bus ID values for your system!
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
      # amdgpuBusId = "PCI:54:0:0"; For AMD GPU
    };
  };
  # Enable bluetooth
  hardware.bluetooth.enable = true;   
  services.blueman.enable = true;
  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  security.polkit.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rui = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };
  services.getty.autologinUser = "rui";
  
  security.sudo.wheelNeedsPassword = false;


  environment.systemPackages = with pkgs; [
    git
    vim     
    wget
    curl
  ];

  programs.zsh.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "24.11";
}

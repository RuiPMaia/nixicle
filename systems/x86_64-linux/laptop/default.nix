{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
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
    initrd.luks.devices.cryptroot.device = "/dev/disk/by-label/NIXOS";
  };

  networking.hostName = "laptop"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pt-latin1";
    earlySetup = true;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = false;
  services.xserver.displayManager.startx.enable = true;
  # Configure keymap in X11
  services.xserver.xkb.layout = "pt";
  services.xserver.autoRepeatDelay = 300;
  services.xserver.autoRepeatInterval = 20;

  services.getty.autologinUser = "rui";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  # Enable bluetooth
  hardware.bluetooth.enable = true;   
  services.blueman.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
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
  
  security.sudo.wheelNeedsPassword = false;

  hardware.graphics.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
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

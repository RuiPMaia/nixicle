{
  description = "Rui Maia's Nix/NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };

    dwm = {
      url = "github:RuiPMaia/dwm";
      flake = false;
    };
    dwmblocks = {
      url = "github:RuiPMaia/dwmblocks";
      flake = false;
    };
    st = {
      url = "github:RuiPMaia/st";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        metadata = "nixicle";
        namespace = "nixicle";
        meta = {
          name = "nixicle";
          title = "Rui Maia's Nix Flake";
        };
      };

      channels-config = {
        allowUnfree = true;
      };

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
      ];

      systems.hosts.desktop.modules = with inputs; [
        nixos-hardware.nixosModules.common-cpu-intel
      ];
  };
}

{
  pkgs,
  inputs,
  ...
}:
pkgs.mkShell {
  # NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  packages = with pkgs; [
    clang-tools
    gnumake
    cmake
  ];
}

{ inputs, channels, ... }:
final: prev: {
  dwm = prev.dwm.overrideAttrs (oldAttrs: {
    src = inputs.dwm;
  });

  dwmblocks = prev.dwmblocks.overrideAttrs (oldAttrs: {
    src = inputs.dwmblocks;
  });

  st = prev.st.overrideAttrs (oldAttrs: {
    src = inputs.st;
    buildInputs = oldAttrs.buildInputs ++ [ prev.harfbuzz ];
  });
  inherit (channels.nixpkgs-stable) citrix_workspace;
}

{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    wrappers.url = "github:lassulus/wrappers";
    otter-launcher = {
      url = "github:kuokuo123/otter-launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wshowkeys = {
      url = "github:voidarclabs/wshowkeys";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    woomer = {
      url = "github:voidarclabs/woomer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {inherit system;};
    hypr = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    packages.${pkgs.stdenv.hostPlatform.system}.default = wrappers.lib.wrapPackage {
      inherit pkgs;
      package = hypr;
      runtimeInputs = with pkgs;
        [
          # Desktop apps
          kitty
          firefox
          nemo
          wlogout
          grimblast
          wpaperd

          # Autostart
          syncthing
          gotify-desktop

          # Hackstation
          wayvnc
          quickshell

          # mobile02
          way-edges
          waybar
          dunst
        ]
        ++ (let
          input = {
            package,
            output ? "default",
          }:
            inputs.${package}.packages.${pkgs.stdenv.hostPlatform.system}.${output};
        in [
          (input {package = "otter-launcher";})
          (input {package = "wshowkeys";})
          (input {package = "woomer";})
        ]);
      exePath = pkgs.lib.getExe hypr;
      flags = {
        "--config" = ./hyprland.lua;
      };
    };
  };
}

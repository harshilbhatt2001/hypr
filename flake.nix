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
    defaultRuntimePkgs = let
      input = {
        package,
        output ? "default",
      }:
        inputs.${package}.packages.${system}.${output};
    in {
      inherit
        (pkgs)
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
        ;
      otter-launcher = input {package = "otter-launcher";};
      wshowkeys = input {package = "wshowkeys";};
      woomer = input {package = "woomer";};
    };
  in {
    lib.defaultRuntimePackages.${pkgs.stdenv.hostPlatform.system} = defaultRuntimePkgs;
    packages.${pkgs.stdenv.hostPlatform.system}.default = pkgs.lib.makeOverridable wrappers.lib.wrapPackage {
      inherit pkgs;
      package = hypr;
      runtimeInputs = defaultRuntimePkgs;
      exePath = pkgs.lib.getExe hypr;
      flags = {
        "--config" = ./hyprland.lua;
      };
    };
  };
}

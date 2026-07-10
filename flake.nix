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
    woomer.url = "github:coffeeispower/woomer";
  };

  outputs = {
    self,
    nixpkgs,
    wrappers,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    hypr = inputs.hyprland.packages.${system}.default;
    defaultRuntimePkgs = let
      input = {
        package,
        output ? "default",
      }:
        inputs.${package}.packages.${system}.${output};
    in {
      inherit
        (pkgs)
        kitty
        firefox
        nemo
        wlogout
        grimblast
        wpaperd
        syncthing
        gotify-desktop
        wayvnc
        quickshell
        way-edges
        waybar
        dunst
        ;
      otter-launcher = input {package = "otter-launcher";};
      wshowkeys = input {package = "wshowkeys";};
      woomer = input {package = "woomer";};
    };

    mkWrapped = {
      pkgs,
      package,
      runtimePackages,
      exePath,
      flags,
    }:
      (wrappers.lib.wrapPackage {
        inherit pkgs package exePath flags;
        runtimeInputs = builtins.attrValues runtimePackages;
        env = {
          "MODULES_ROOT" = ./.;
        };
      }).overrideAttrs (old: {
        passthru = (old.passthru or {}) // {inherit runtimePackages;};
      });
  in {
    lib.defaultRuntimePkgs.${system} = defaultRuntimePkgs;

    packages.${system}.default = pkgs.lib.makeOverridable mkWrapped {
      inherit pkgs;
      package = hypr;
      runtimePackages = defaultRuntimePkgs;
      exePath = pkgs.lib.getExe hypr;
      flags."--config" = ./hyprland.lua;
    };
    packages.${system}.minimal = mkWrapped {
      inherit pkgs;
      package = hypr;
      exePath = pkgs.lib.getExe hypr;
      flags."--config" = ./hyprland.lua;
    };
  };
}

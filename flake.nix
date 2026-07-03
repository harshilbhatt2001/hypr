{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    wrappers.url = "github:lassulus/wrappers";
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
      exePath = pkgs.lib.getExe hypr;
      flags = {
        "--config" = ./hyprland.lua;
      };
    };
  };
}

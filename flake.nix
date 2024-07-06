{
  description = "raspberry-pi nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/9a9960b98418f8c385f52de3b09a63f9c561427a";
    u-boot-src = {
      flake = false;
      url = "https://ftp.denx.de/pub/u-boot/u-boot-2024.04.tar.bz2";
    };
    rpi-linux-6_6-src = {
      flake = false;
      url = "github:raspberrypi/linux/stable_20240529";
    };
    rpi-firmware-src = {
      flake = false;
      url = "github:raspberrypi/firmware/1.20240529";
    };
    rpi-firmware-nonfree-src = {
      flake = false;
      url = "github:RPi-Distro/firmware-nonfree/223ccf3a3ddb11b3ea829749fbbba4d65b380897";
    };
    rpi-bluez-firmware-src = {
      flake = false;
      url = "github:RPi-Distro/bluez-firmware/78d6a07730e2d20c035899521ab67726dc028e1c";
    };
    libcamera-apps-src = {
      flake = false;
      url = "github:raspberrypi/libcamera-apps/v1.4.4";
    };
    libcamera-src = {
      flake = false;
      url = "github:raspberrypi/libcamera/eb00c13d7c9f937732305d47af5b8ccf895e700f"; # v0.2.0+rpt20240418
    };
    libpisp-src = {
      flake = false;
      url = "github:raspberrypi/libpisp/v1.0.5";
    };
  };

  outputs = srcs@{ self, ... }:
    let
      pinned = import srcs.nixpkgs {
        system = "aarch64-linux";
        overlays = with self.overlays; [ core libcamera ];
      };
    in
    {
      overlays = {
        core = import ./overlays (builtins.removeAttrs srcs [ "self" ]);
        libcamera = import ./overlays/libcamera.nix (builtins.removeAttrs srcs [ "self" ]);
      };
      nixosModules.raspberry-pi = import ./rpi {
        inherit pinned;
        core-overlay = self.overlays.core;
        libcamera-overlay = self.overlays.libcamera;
      };
      packages.aarch64-linux = {
        linux = pinned.rpi-kernels.latest.kernel;
        firmware = pinned.rpi-kernels.latest.firmware;
        wireless-firmware = pinned.rpi-kernels.latest.wireless-firmware;
        uboot-rpi-arm64 = pinned.uboot-rpi-arm64;
      };
    };
}

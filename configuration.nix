# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/master)
    # reuse the current configuration
    { config = config.nixpkgs.config; };

  emacsPackages = with pkgs; [
    (emacs.override { withXwidgets = true; })
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.pt_BR
  ];

  rustPackages = with pkgs; [
    latest.rustChannels.stable.cargo
    latest.rustChannels.stable.rust
    openssl # needed by cargo-web
    pkgconfig # needed by cargo-web
    rls # rust lsp
    rust-analyzer # rust lsp
  ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./custom/i3wm.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.device = "/dev/disk/by-id/ata-KINGSTON_SV300S37A120G_50026B77630DA911-part3";
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # set $FS_UUID to the UUID of the EFI partition
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root 8E6E-4553
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
      version = 2;
    };
  };
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp6s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  environment.variables.LC_CTYPE = [ "pt_BR.UTF-8" ]; # to fix the ć in int keyboards
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  environment.variables.ROFI_TODOIST_ROOT_PATH = [ "~/dev/code/rofi-todoist" ];
  environment.variables.ROFI_TODOIST_NOTIFICATION = [ "notify-send" ];

  # Enable the GNOME 3 Desktop Environment.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "intl";
  services.xserver.xkbModel = "evdev";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Setting Emacs Daemon
  services.emacs.enable = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.squiter = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "plugdev" ];
  };

  environment.sessionVariables.TERMINAL = [ "alacritty" ];
  environment.homeBinInPath = true;

  # Adding the Nubank overlay
  # nixpkgs.overlays = [
  #   (import (builtins.fetchTarball {
  #     url = https://github.com/nubank/nixpkgs/archive/master.tar.gz;
  #   }))
  # ];

  nixpkgs.overlays = [
    # Mozilla Rust Overlay
    (import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz))
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    (rofi.override { plugins = [ rofi-calc rofi-emoji ]; })
    ag
    alacritty
    awscli2
    babashka
    bat
    bitwarden
    bitwarden-cli
    curl
    dmidecode # to see hardware information
    direnv
    docker
    docker-compose
    dropbox-cli
    duf # df alternative
    espanso
    feh
    firefox
    flameshot # screenshot tool
    fzf
    gcc
    gimp
    git
    git-crypt
    gnome3.gnome-tweak-tool
    gnumake
    go # just to have `go get` available
    google-chrome
    gotop
    gsimplecal
    guvcview # to configure webcam 🤷
    hub
    inotify-tools # to use Phoenix's live-reload function on Elixir projects
    jq
    keyutils # to be used in bwmenu
    libnotify # I use this lib to make dunst work with the workaround in my linux-setup
    lsd
    lxappearance # customize themes for GTK
    mcfly
    navi
    neofetch
    nodejs-14_x
    ntfy
    pavucontrol # audio/volume control
    peek
    unstable.pgcli
    playerctl # to use my mediakey config from i3
    python39
    python39Packages.grip
    rescuetime
    ripgrep
    slack
    spotify
    sqlite # to use in org-roam
    tdesktop # telegram-desktop
    tldr
    todoist
    tree
    typora # awesome markdown editor
    unipicker
    unstable.elixir
    unstable.elixir_ls
    unstable.terraform
    unzip
    vim
    wakatime
    wally-cli
    wget
    xclip
    xdotool # to be used in bwmenu
    xsel # to be used in bwmenu
    zeal
    zoom-us
  ]
  ++ rustPackages
  ++ emacsPackages;
  # ++ nubank.all-tools
  # ++ nubank.desktop-tools;

  fonts = {
    fonts = with pkgs; [
      dejavu_fonts
      emacs-all-the-icons-fonts
      hack-font
      ibm-plex
      (nerdfonts.override {
        fonts = [
          "Agave"
          "FiraCode"
          "Inconsolata"
          "Iosevka"
          "JetBrainsMono"
          "LiberationMono"
          "Overpass"
          "SourceCodePro"
          "Ubuntu"
          "UbuntuMono"
        ];
      })
      roboto
      symbola
    ];
  };

  # Systemd service for Dropbox, copied from: https://nixos.wiki/wiki/Dropbox
  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = [ "graphical-session.target" ];
    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };
    serviceConfig = {
      ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
      ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
      KillMode = "control-group"; # upstream recommends process
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # automatic garbage collect
  nix = {
    gc = {
      automatic = true;
      dates = "3:15";
      options = "--delete-older-than 7d";
    };
    autoOptimiseStore = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enabling the bluetooth service
  services.blueman.enable = true;

  virtualisation.docker.enable = true;

  # Enabling Ergodox Flashing
  hardware.keyboard.zsa.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}


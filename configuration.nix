# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration-zfs.nix ./zfs.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gaia.local"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp7s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "br-abnt2";
  };

  
  # Configure X11
  services.xserver = {
    	# Enable the X11 windowing system.
    	enable = true;
	videoDrivers = [ "amdgpu" ];

    	# Enable the XFCE Desktop Environment.
    	desktopManager.xfce.enable = true;
    	displayManager.lightdm.enable = true;
    	windowManager.stumpwm.enable = true;
    	windowManager.default = "stumpwm";

    	# Configure keymap in X11
    	layout = "br";
    	xkbOptions = "eurosign:e";
  }

  # Configure fonts
  fonts = {
        enableFontDir = true;
    	enableGhostscriptFonts = true;
    	fonts = with pkgs; [
      		inconsolata
      		ubuntu_font_family
	      	anonymousPro
      		dejavu_fonts
	      	liberation_ttf
      		proggyfonts
	      	source-sans-pro
      		terminus_font
	      	ttf_bitstream_vera
    	];
   };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # OpenCL 
  # install the clinfo package to verify that OpenCL is correctly setup 
  hardware.opengl.extraPackages = with pkgs; [
   	rocm-opencl-icd
   	rocm-opencl-runtime
  ];

  hardware = {
	 # Enable sound.
	 pulseaudio.enable = true;
	  
	 # Turn on BlueTooth support
	 bluetooth.enable = true;

	 # Allow hardware accelerated drivers
	 hardware.opengl.driSupport = true;
	 # Allow hardware accelerated drivers to run in 31-bit mode
	 opengl.driSupport32Bit = true;
  }

  # Not exactly sure what this accomplishes, from wiki advice...
  security.setuidPrograms = [
  	"xlaunch"
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.carlosfilho = {
     	isNormalUser = true;
     	extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };
   users.users.jessica = {
     	isNormalUser = true;
     	extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     emacs # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     
     wget
    
    # Window Management
    stumpwm
    compton
    xlaunch
    #bumblebee # https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/X11/bumblebee/default.nix

    # Audio / Media Players
    smplayer
    vlc
    mpd
    ardour
    supercollider
    ncmpcpp
    qjackctl
    pavucontrol

    # Games
    steam

    # Web
    google-chrome
    firefox
    nyxt
    qutebrowser

    # Photos and Graphics
    xfce.ristretto   # Doesn't come with PNG support.  Fix it?  Use something else instead?
    darktable
    gimp
    inkscape
    processing

    # Video
    #makemkv # NOTE: Didn't build...
    #cinelerra # NOTE: Package points to outdate Git repo url, doesn't build
    mpv
    handbrake
    zoom-us

    # Desktop Tools
    dmenu
    i3lock
    xfce.xfce4_power_manager
    xfce.xfce4terminal
    spideroak
    #smbclient # Not found, find correct package
    blueman 
    scrot
    p7zip
    gnupg
    filezilla
    fbpanel

    # Chats
    discord
    tdesktop

    # Haskell packages
    (haskellPackages.ghcWithPackages (self : [
      haskellPlatform
      self.taffybar
      self.gitAnnex
     ])) 
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "21.11"; # Did you read the comment?

}


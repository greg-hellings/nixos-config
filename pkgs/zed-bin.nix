# default.nix or zed-bin.nix
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  # Runtime dependencies for Zed Editor
  alsa-lib,
  dbus,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libglvnd,
  libxkbcommon,
  openssl,
  pipewire,
  systemd,
  vulkan-loader,
  wayland,
  wayland-protocols,
  wayland-scanner,
  xorg,
  # For the update script
  writeScriptBin,
}:

stdenv.mkDerivation rec {
  pname = "zed-bin";
  version = "0.185.16";

  # Fetch the pre-built binary tarball from GitHub releases
  src = fetchurl {
    url = "https://github.com/zed-industries/zed/releases/download/v${version}/zed-linux-x86_64.tar.gz";
    hash = "sha256-gbtkMBaeWg84P9DFOMu/c9r1KOcTITI6vPYja2vy9rw=";
  };

  # Tools needed during the build/installation phase
  nativeBuildInputs = [
    autoPatchelfHook # Automatically patches ELF binaries
    makeWrapper # To wrap the executable if needed
  ];

  # Runtime dependencies required by the Zed binary
  # autoPatchelfHook finds many, but explicit listing improves robustness
  buildInputs = [
    alsa-lib # Audio support
    dbus # D-Bus message bus system
    fontconfig # Font configuration and customization library
    freetype # Font rendering engine
    glib # Low-level core library
    gtk3 # Toolkit for creating graphical user interfaces (often used for file pickers)
    libglvnd # Vendor-neutral GL dispatch library
    libxkbcommon # Keyboard handling library
    openssl # Cryptography library
    pipewire # Graph based processing engine for audio and video
    stdenv.cc.cc.lib # Standard C++ library (libstdc++)
    systemd # System and service manager (for login sessions, dbus activation)
    vulkan-loader # Vulkan ICD loader
    wayland # Wayland display server protocol
    wayland-protocols # Wayland protocols definitions
    wayland-scanner # Wayland scanner utility
    # Xorg libraries for X11 support
    xorg.libX11
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
  ];

  # The tarball contains the 'zed' executable directly at the root
  # No sourceRoot needed

  installPhase = ''
    runHook preInstall

    # Create the bin directory in the output path
    mkdir -p $out/bin

    # Copy the executable to the output bin directory
    cp -r bin lib libexec share $out/

    # Ensure the executable has execute permissions
    chmod +x $out/bin/zed

    # Wrap the program (optional but good practice)
    # Example: Ensure dbus tools are available in PATH if needed by Zed internally
    # You might need to add more paths depending on Zed's runtime requirements
    wrapProgram $out/bin/zed --prefix PATH : ${lib.makeBinPath [ dbus ]}

    runHook postInstall
  '';

  # Passthru attribute containing a script to update the package version and hash
  passthru.updateScript = writeScriptBin "update-${pname}" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq nix-update nix-prefetch-scripts git

    set -euo pipefail # Exit on error, unset variable, or pipe failure

    # Get the latest release tag name from GitHub API
    # Fetches the latest release (not pre-release)
    latest_tag=$(curl -s "https://api.github.com/repos/zed-industries/zed/releases/latest" | jq -r '.tag_name')
    if [[ -z "$latest_tag" ]]; then
      echo "Failed to fetch latest tag from GitHub API" >&2
      exit 1
    fi
    # Remove the 'v' prefix if it exists (e.g., v0.185.16 -> 0.185.16)
    latest_version="''${latest_tag#v}"


    # Get the current version directly from this file (assumed to be default.nix or zed-bin.nix)
    # This assumes the script is run from the same directory as the Nix expression
    current_version=$(nix-instantiate --eval -E "with import ./. {}; ${pname}.version" | tr -d '"')

    # Compare versions
    if [[ "$latest_version" == "$current_version" ]]; then
      echo "${pname} is already up-to-date at version $current_version"
      exit 0
    fi

    echo "Updating ${pname} from $current_version to $latest_version..."

    # Use nix-update to automatically update the version and hash in the Nix expression
    # Adjust the attribute path (-A) if this expression is part of a larger package set
    # Assumes the attribute path is 'zed-bin' within the file being evaluated (e.g. '.')
    nix-update --commit -A ${pname} --version "$latest_version"

    echo "Update complete. Remember to verify the changes."
  '';

  # Metadata about the package
  meta = with lib; {
    description = "A high-performance, multiplayer code editor (pre-built binary)";
    homepage = "https://zed.dev/";
    # Zed's source has multiple licenses (GPL3, Apache2, SSPL).
    # The license for the pre-built binary distribution is less clear.
    # Using 'unfree' is the safest approach for distributing binaries
    # without a clear, permissive redistribution license.
    license = licenses.gpl3;
    # Replace 'yourGithubUsername' with your actual GitHub username if maintaining
    maintainers = with maintainers; [
      # yourGithubUsername
    ];
    # Specify the platform this binary is built for
    platforms = [ "x86_64-linux" ];
    # Indicate that this package contains pre-compiled binary code
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    # Set the main program
    mainProgram = "zed";
  };
}

{ lib
, stdenv
, buildNpmPackage
, fetchFromGitLab
, nodePackages
, meson
, pkg-config
, ninja
, gobject-introspection
, gtk3
, libpulseaudio
, gjs
, python3
, wrapGAppsHook
, upower
, gnome
, gtk-layer-shell
, glib-networking
, networkmanager
, libdbusmenu-gtk3
, gvfs
, libsoup_3
, libnotify
, extraPackages ? [ ]
, version ? "git"
}:

let
  gvc-src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "libgnome-volume-control";
    rev = "8e7a5a4c3e51007ce6579292642517e3d3eb9c50";
    sha256 = "sha256-FosJwgTCp6/EI6WVbJhPisokRBA6oT0eo7d+Ya7fFX8=";
  };
in
stdenv.mkDerivation rec {
  pname = "ags";
  inherit version;

  src = buildNpmPackage {
    name = pname;
    src = ../.;

    dontBuild = true;

    npmDepsHash = "sha256-ucWdADdMqAdLXQYKGOXHNRNM9bhjKX4vkMcQ8q/GZ20=";

    installPhase = ''
      mkdir $out
      cp -r * $out
    '';
  };

  prePatch = ''
    mkdir -p ./subprojects/gvc
    cp -r ${gvc-src}/* ./subprojects/gvc
  '';

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    nodePackages.typescript
    python3
    wrapGAppsHook
    gobject-introspection
  ];

  buildInputs = [
    gjs
    gtk3
    libpulseaudio
    upower
    gnome.gnome-bluetooth
    gtk-layer-shell
    glib-networking
    networkmanager
    libdbusmenu-gtk3
    gvfs
    libsoup_3
    libnotify
  ] ++ extraPackages;

  meta = with lib; {
    description = "A customizable and extensible shell";
    homepage = "https://github.com/Aylur/ags";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.gpl3;
    meta.maintainers = [ lib.maintainers.Aylur ];
  };
}

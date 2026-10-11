{ lib
, rustPlatform
, pkg-config
, makeWrapper
, wayland
, libxkbcommon
, libx11
, libxcursor
, libxrandr
, libxi
, libxcb
, vulkan-loader
, libGL
, src
}:

# Built straight from the upstream repo (flake input `craft-launcher`, flake = false).
# winit/wgpu dlopen the windowing + graphics libs at runtime, hence the wrapper.
rustPlatform.buildRustPackage {
  pname = "artcraft-launcher";
  version = "0.2.0";
  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";
  cargoBuildFlags = [ "-p" "artcraft-launcher" ];
  doCheck = false;

  nativeBuildInputs = [ pkg-config makeWrapper ];

  postInstall = ''
    mkdir -p $out/share/icons
    cp -R ${src}/assets/app-icon/hicolor $out/share/icons/
    install -Dm644 ${src}/packaging/linux/ai.storyteller.artcraft-launcher.desktop \
      $out/share/applications/ai.storyteller.artcraft-launcher.desktop

    wrapProgram $out/bin/artcraft-launcher \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        wayland libxkbcommon libx11 libxcursor libxrandr libxi libxcb vulkan-loader libGL
      ]}
  '';

  meta = {
    description = "Install, update and open the Craft App Suite";
    homepage = "https://github.com/storytold/craft-launcher";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "artcraft-launcher";
    platforms = lib.platforms.linux;
  };
}

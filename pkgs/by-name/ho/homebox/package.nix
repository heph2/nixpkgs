{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pnpm_9,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  go_1_24,
  git,
  cacert,
  nixosTests,
}:
let
  pname = "homebox";
  version = "0.22.3";
  src = fetchFromGitHub {
    owner = "sysadminsmedia";
    repo = "homebox";
    tag = "v${version}";
    hash = "1iazzrnj1r7nwjgnh5r4xgyzl48rb3p18qgc7lpxwn6sgqwy4b9g";
  };
in
buildGoModule {
  inherit pname version src;

  vendorHash = lib.fakeHash;
  modRoot = "backend";
  # the goModules derivation inherits our buildInputs and buildPhases
  # Since we do pnpm thing in those it fails if we don't explicitly remove them
  overrideModAttrs = _: {
    nativeBuildInputs = [
      go_1_24
      git
      cacert
    ];
    preBuild = "";
  };

  pnpmDeps = fetchNpmDeps {
    inherit pname version;
    src = "${src}/frontend";
    pnpm = pnpm_9;
    fetcherVersion = 1;
    hash = "sha256-gHx4HydL33i1SqzG1PChnlWdlO5NFa5F/R5Yq3mS4ng=";
  };
  pnpmRoot = "../frontend";

  env.NUXT_TELEMETRY_DISABLED = 1;

  preBuild = ''
    pushd ../frontend

    pnpm build

    popd

    mkdir -p ./app/api/static/public
    cp -r ../frontend/.output/public/* ./app/api/static/public
  '';

  nativeBuildInputs = [
    pnpmConfigHook
    pnpm_9
    nodejs
  ];

  env.CGO_ENABLED = 0;
  doCheck = false;

  tags = [
    "nodynamic"
  ];

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
    "-X main.version=${src.tag}"
    "-X main.commit=${src.tag}"
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r $GOPATH/bin/api $out/bin/

    runHook postInstall
  '';

  passthru = {
    tests = {
      inherit (nixosTests) homebox;
    };
  };

  meta = {
    mainProgram = "api";
    homepage = "https://homebox.software/";
    description = "Inventory and organization system built for the Home User";
    maintainers = with lib.maintainers; [
      patrickdag
      tebriel
    ];
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
  };
}

{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
, buildPackages
}:

buildGoModule rec {
  pname = "gnmic";
  version = "0.38.1";

  src = fetchFromGitHub {
    owner = "openconfig";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Js5l6bVZtnR6uOo2+3L2CAvFj/i0O2FFGEiGOkc2qDQ=";
  };

  vendorHash = "sha256-4TTxhcP06YuhWWufVTAVK2wTf8mCc3WLAjzFe5wKChY=";

  ldflags = [
    "-s" "-w"
    "-X" "github.com/openconfig/gnmic/app.version=${version}"
    "-X" "github.com/openconfig/gnmic/app.commit=${src.rev}"
    "-X" "github.com/openconfig/gnmic/app.date=1970-01-01T00:00:00Z"
  ];
  subPackages = [ "." ];

  nativeBuildInputs = [ installShellFiles ];
  postInstall = let emulator = stdenv.hostPlatform.emulator buildPackages; in ''
    installShellCompletion --cmd gnmic \
      --bash <(${emulator} $out/bin/gnmic completion bash) \
      --fish <(${emulator} $out/bin/gnmic completion fish) \
      --zsh  <(${emulator} $out/bin/gnmic completion zsh)
  '';

  meta = with lib; {
    description = "gNMI CLI client and collector";
    homepage = "https://gnmic.openconfig.net/";
    changelog = "https://github.com/openconfig/gnmic/releases/tag/${src.rev}";
    license = licenses.asl20;
    maintainers = with maintainers; [ vincentbernat ];
    mainProgram = "gnmic";
  };
}

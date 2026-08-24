{pkgs, config, lib, inputs, ...} :
let
  cfg = config.dev.tools;
  krewCfg = config.programs.krewfile;
  krewfileBin = inputs.krewfile.packages.${pkgs.stdenv.hostPlatform.system}.krewfile;
  krewfileContent = pkgs.writeText "krewfile" (lib.concatStringsSep "\n" krewCfg.plugins);
in {
  options = {
    dev.tools.kubernetes = {
      enable = lib.mkEnableOption "Kubernetes and container orchestration tools";
    };
  };

  config = lib.mkIf cfg.kubernetes.enable {
    home.packages = with pkgs; [ 
      kubectl
      kubernetes-helm
      kubernetes-helmPlugins.helm-diff
      fluxcd
      kustomize
      kubeconform
      k9s
      k3d
      freelens-bin
      chart-testing
      openshift
      # Custom packages
      local.openlens
      local.helm-readme-generator
    ];
    
    # kubectl extensions
    programs.krewfile = {
      enable = true;
      krewPackage = pkgs.krew;
      plugins = [
        "resource-capacity"  # https://github.com/robscott/kube-capacity
      ];
    };

    # krewfile hits the network to refresh its index, but HM activation runs before
    # the network is up at boot and while NetworkManager/dnsmasq restart during a
    # nixos-rebuild switch. Don't fail the whole generation over it.
    home.activation.krew = lib.mkForce (config.lib.dag.entryAfter [ "installPackages" ] ''
      export KREW_ROOT="${krewCfg.krewRoot}"

      run ${krewfileBin}/bin/krewfile \
        -command ${krewCfg.krewPackage}/bin/krew \
        -file ${krewfileContent} \
        || warnEcho "krewfile failed (no network?); plugins left unchanged"
    '');

    home.sessionVariables = {
      KUBECONFIG = "\$(generate_kubeconfig)";
    };
  };
}

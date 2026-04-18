{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
  gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in {
  options = {
    dev.tools.cloud = {
      enable = lib.mkEnableOption "Cloud and DevOps tools";
    };
  };

  config = lib.mkIf cfg.cloud.enable {
    home.packages = with pkgs; [ 
      awscli2
      gdk
      unstable.terraform
      terragrunt
      terraform-docs
    ];
  };
}

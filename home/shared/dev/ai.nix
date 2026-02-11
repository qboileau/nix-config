{pkgs, ...} :
{
  
  home.packages = with pkgs; [ 
    unstable.claude-code
    unstable.claude-monitor
    unstable.github-copilot-cli
    unstable.mistral-vibe
  ];

}

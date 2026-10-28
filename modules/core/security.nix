{
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;
  };
  security.sudo-rs.enable = true;

  programs.gnupg.agent.enable = true;
}

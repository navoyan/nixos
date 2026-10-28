{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.amdgpu.overdrive.enable = true;

  programs.coolercontrol.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];
}

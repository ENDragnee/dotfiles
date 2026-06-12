{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "ENDragnee";
        email = "mesfinmastwal@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };
}

{ ... }:

{
  dotenv.enable = true;
  
  languages.solidity = {
    enable = true;
    foundry.enable = true;
  };

  git-hooks.hooks = {
    forge-fmt = {
      enable = true;
      name = "forge fmt --check";
      language = "system";
      entry = "forge fmt";
      pass_filenames = false;
    };

    forge-lint = {
      enable = true;
      name = "forge lint";
      language = "system";
      entry = "forge lint";
      pass_filenames = false;
    };
  };
}

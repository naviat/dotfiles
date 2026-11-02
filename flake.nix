{
  description = "dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
    let
      # Primary account: runs ./rebuild.sh and owns /opt/homebrew
      user = "harry";
      # Every account that gets the shared Nix stack
      users = [ "harry" "harry-nix" ];
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user users; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager

          {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users = nixpkgs.lib.genAttrs users (u: {
              # harry-nix gets the repo symlinks, the others only the shared stack
              imports = [ (if u == user then ./home.nix else ./common.nix) ];
              _module.args.user = u;
            });
          }
        ];
      };
    };
}

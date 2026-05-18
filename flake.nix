{
  description = "Gentleman: Single config for all systems in one go";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";  # Home Manager repository
      inputs.nixpkgs.follows = "nixpkgs";  # Follow nixpkgs input
    };
    flake-utils.url = "github:numtide/flake-utils";  # Flake utilities
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, flake-utils, ... }:
    let
      # Support macOS systems only
      supportedSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      
      # ─── User Configuration ───
      # Change this to your macOS username
      username = "leandro.poroli";

      # Function to create home configuration for a specific system
      mkHomeConfiguration = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          
          unstablePkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          
          # Pass extraSpecialArgs to make unstablePkgs available in modules
          extraSpecialArgs = {
            inherit unstablePkgs;
          };
          
          modules = [
            ./nushell.nix  # Nushell configuration
            ./ghostty.nix  # Ghostty configuration
            ./zed.nix  # Zed configuration
            ./television.nix  # Television configuration
            ./wezterm.nix  # WezTerm configuration
            ./zellij.nix  # Zellij configuration
            ./tmux.nix  # Tmux configuration
            ./fish.nix  # Fish shell configuration
            ./starship.nix  # Starship prompt configuration
            ./nvim.nix  # Neovim configuration
            ./zsh.nix  # Zsh configuration
            ./oil-scripts.nix  # Oil.nvim scripts configuration
            # ./opencode.nix  # OpenCode AI assistant configuration
            # ./claude.nix  # Claude Code CLI configuration
            # ./engram.nix  # Engram memory layer for AI agents
            ./yabai.nix  # Yabai window manager configuration
            ./skhd.nix  # Skhd hotkey daemon configuration
            # ./simple-bar.nix  # simple-bar for Übersicht (disabled - using sketchybar)
            ./sketchybar.nix  # SketchyBar status bar
            ./raycast.nix  # Raycast scripts
            {
              # Personal data
              home.username = username;
              home.homeDirectory = "/Users/${username}";  # macOS home directory
              home.stateVersion = "24.11";  # State version

              # Base packages that should be available everywhere
              home.packages = with pkgs; [
                # ─── Terminals and utilities ───
                # zellij                 # terminal multiplexer (tmux alternative)
                tmux                     # terminal multiplexer
                fish                     # Friendly Interactive Shell
                zsh                      # Z shell
                # nushell                # modern data-oriented shell

                # ─── Window management (macOS) ───
                # yabai                  # macOS window manager (tiling)
                # skhd                   # hotkey daemon for macOS
                # unstablePkgs.sketchybar  # Use unstable for latest version

                # ─── Development tools ───
                # volta                  # JS toolchain manager (Node versions)
                carapace                 # shell completions generator
                zoxide                   # smarter cd with frecency
                atuin                    # advanced shell history (search/sync)
                jq                       # JSON processor
                # bash                     # GNU Bourne Again SHell
                starship                 # customizable shell prompt (shows git branch, etc.)
                fzf                      # fuzzy finder for terminal
                # nodejs                 # JavaScript runtime
                # bun                    # fast JS/TS runtime & bundler
                # cargo                  # Rust package manager
                # go                     # Go programming language
                # nil                    # Nix language server (LSP for Neovim)
                # unstablePkgs.nixd      # Nix language server (LSP alternative)
                # unstablePkgs.neovim    # Neovim editor
                # tree-sitter            # syntax parser for highlighting in Neovim

                # ─── External Services CLIs ───
                # supabase-cli

                # ─── Compilers and system utilities ───
                # gcc                    # GNU C/C++ compiler
                fd                       # fast find alternative
                ripgrep                  # ultra-fast text searcher (rg)
                # coreutils              # GNU basic utils (ls, cat, etc.)
                # unzip                  # extract .zip files
                bat                      # cat clone with syntax highlighting
                lazygit                  # TUI for git
                yazi                     # terminal file manager (TUI)
                television               # fast fuzzy finder TUI (fzf alternative)

                # ─── Nerd Fonts ───
                nerd-fonts.iosevka-term
              ];

              # Enable programs explicitly (critical for binaries to appear)
              # All program enables are centralized here
              programs.neovim.enable = false;
              programs.fish.enable = true;
              programs.nushell.enable = true;
              programs.starship.enable = false;
              programs.zsh.enable = false;  # Managed via home.file in zsh.nix
              programs.git.enable = true;
              programs.gh.enable = true;  # GitHub CLI
              programs.home-manager.enable = true;
              # Note: tmux is configured via home.file in tmux.nix, not programs.tmux

              # NOTE: home.sessionVariables removed - it generates a recursive .zshenv bug
              # XDG_CONFIG_HOME is set in shell configs instead

              # Allow unfree packages
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
    in
    {
      # Home Manager configurations for each system
      homeConfigurations = {
        # macOS system configurations
        "gentleman-macos-intel" = mkHomeConfiguration "x86_64-darwin";
        "gentleman-macos-arm" = mkHomeConfiguration "aarch64-darwin";
        
        # Default to Apple Silicon
        "gentleman" = mkHomeConfiguration "aarch64-darwin";
      };
    };
}

# dotfiles

Declarative macOS setup with [Nix](https://nixos.org), [nix-darwin](https://github.com/nix-darwin/nix-darwin), [Home Manager](https://github.com/nix-community/home-manager), and [nix-homebrew](https://github.com/zhaofengli/nix-homebrew).

One flake defines system defaults, Homebrew casks, CLI tools, shell config, and app preferences so a new Mac can match this setup with a single rebuild.

## Requirements

- Apple Silicon Mac (`aarch64-darwin`)
- [Determinate Nix](https://determinate.systems/nix) (or another Nix install that leaves the daemon to something other than nix-darwin)
- macOS user account you will configure

## Quick start

```bash
git clone arminsam/dotfiles 
cd /path/to/dotfiles
./rebuild.sh
```

On first run, `rebuild.sh` asks for:

| Prompt | Meaning | Default |
| --- | --- | --- |
| `hostName` | Flake attribute used as `~/.dotfiles#<hostName>` | `mac` |
| `userName` | macOS account Home Manager configures | your login user |

Answers are written to `identity.nix` (gitignored). Later runs skip the prompts and apply the flake.

`rebuild.sh` also symlinks the repo to `~/.dotfiles`, then runs:

```bash
sudo darwin-rebuild switch --flake ~/.dotfiles#<hostName>
```

## What’s managed

| Layer | File(s) | Examples |
| --- | --- | --- |
| Flake inputs / host | `flake.nix` | nixpkgs, nix-darwin, Home Manager (26.05), nix-homebrew |
| System | `configuration.nix`, `local-casks.nix` | Dock/Finder defaults, public + private Homebrew casks, nix-homebrew |
| User | `home.nix` | packages, zsh, Starship, menu-bar defaults |
| Editable configs | `home/.config/nvim`, `home/.config/wezterm` | out-of-store symlinks — edit in the repo |

Homebrew is configured with `onActivation.cleanup = "none"`: listed casks are installed/upgraded, but unlisted casks and formulae are left alone.

## Private Homebrew casks

Everyday apps live in `configuration.nix`. Sensitive or personal casks (password managers, hardware wallets, and similar) belong in `local-casks.nix`, which is gitignored.

```bash
cp local-casks.nix.example local-casks.nix
# edit local-casks.nix, then ./rebuild.sh
```

`configuration.nix` appends that list when the file exists. Without it, only the public casks are installed.

## Per-machine identity

`identity.nix` holds only:

```nix
{
  hostName = "mac";
  userName = "armin";
}
```

See `identity.nix.example`. Because `identity.nix` is not committed, each Mac can keep its own host and user without forking the flake.

## Layout

```
.
├── flake.nix / flake.lock
├── configuration.nix      # nix-darwin + Homebrew
├── home.nix               # Home Manager
├── home/.config/          # Neovim, WezTerm (symlinked)
├── identity.nix           # local only (gitignored)
├── identity.nix.example
├── local-casks.nix        # local only (gitignored)
├── local-casks.nix.example
├── rebuild.sh
└── README.md
```

## Notes

- Nix daemon management is left to Determinate (`nix.enable = false` in nix-darwin).
- After changing Control Center / menu-bar defaults, you may need `killall ControlCenter` / `killall SystemUIServer` or a re-login.
- Ice and Stats “launch at login” are one-time toggles in each app’s UI (not covered by defaults).
- `home.stateVersion` is `"26.05"`, matching the flake channels.

## License

Private / personal use unless otherwise stated.

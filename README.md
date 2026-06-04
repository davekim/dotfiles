# dotfiles
Configuration files

## Dependencies

- [Homebrew](https://brew.sh)
- [mise](https://mise.jdx.dev) — runtime version manager (Ruby, Python, Node, etc.)
- [uv](https://docs.astral.sh/uv) — Python package/tool manager
- [tmux](https://github.com/tmux/tmux)

## What's included

| File | Description |
|------|-------------|
| `zshrc` | Zsh config — prompt, git status, PATH, mise, uv |
| `gitconfig` | Git aliases and settings (machine-specific identity lives in `gitconfig.local`) |
| `tmux.conf` | Tmux status bar and key bindings |
| `gitstatus.py` | Git status script used by the prompt |

## Installation

Run the following installation script to activate the configuration files. The script will create symlinks to your home directory.

```bash
$ ruby activate.rb
```

After symlinking, install the tool versions managed by mise:

```bash
$ mise install
```

## Local (machine-specific) files

These files are gitignored and must be created manually on each machine. `activate.rb` will symlink them automatically once they exist in this directory.

### `gitconfig.local`

Machine-specific git identity and commit signing. Created at `~/.gitconfig.local` and included by `gitconfig`.

```ini
[user]
    name = YOUR_NAME
    email = YOUR_EMAIL
    signingkey = YOUR_SSH_PUBLIC_KEY

[url "git@github.com:"]
    insteadOf = https://github.com/

[gpg]
    format = ssh

[gpg "ssh"]
    # Path to your SSH signing program.
    # For 1Password: /Applications/1Password.app/Contents/MacOS/op-ssh-sign
    # For system SSH agent, omit this section and gpgsign below.
    program = PATH_TO_SSH_SIGN_PROGRAM

[commit]
    gpgsign = true
```

**Where to find values:**
- `signingkey` — the public key you want to sign commits with (e.g. from `~/.ssh/id_ed25519.pub`, or copied from 1Password)
- `gpg.ssh.program` — only needed if using a third-party SSH agent like 1Password; omit the `[gpg "ssh"]` section and set `gpgsign = false` if not signing commits

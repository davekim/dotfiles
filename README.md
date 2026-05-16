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
| `gitconfig` | Git aliases and settings |
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

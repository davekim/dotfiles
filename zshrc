if ! type vcs_info > /dev/null 2>&1; then
  # (-U autoload w/o substition, -z use zsh style)
  autoload -Uz vcs_info add-zsh-hook || return 1
fi

# run vcs_info just before a prompt is displayed (precmd)
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

# executed whenever current working directory is changed
add-zsh-hook chpwd chpwd_update_git_vars

# executed before the next prompt is displayed
add-zsh-hook precmd precmd_update_git_vars

# executed before a command is executed
add-zsh-hook preexec preexec_update_git_vars

function chpwd_update_git_vars() {
  update_current_git_vars
}

function preexec_update_git_vars() {
  case "$2" in
    git*)
      __EXECUTED_GIT_COMMAND=1
      ;;
  esac
}
function precmd_update_git_vars() {
  if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    update_current_git_vars
    unset __EXECUTED_GIT_COMMAND
  fi
}

function update_current_git_vars() {
  unset __CURRENT_GIT_STATUS

  local gitstatus="$HOME/.gitstatus.py"
  _GIT_STATUS=$(python3 ${gitstatus} 2>/dev/null)
  __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
  GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
  GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
  GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
  GIT_STAGED=$__CURRENT_GIT_STATUS[4]
  GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
  GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
  GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}

# Adapted from https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git-prompt/git-prompt.plugin.zsh
git_super_status() {
  precmd_update_git_vars
  if [ -n "$__CURRENT_GIT_STATUS" ]; then

    STATUS="%F{white}(%F{blue}$GIT_BRANCH"

    if [ "$GIT_BEHIND" -ne "0" ]; then
      STATUS="$STATUS%F{white}%{↓%G%}$GIT_BEHIND"
    fi

    if [ "$GIT_AHEAD" -ne "0" ]; then
      STATUS="$STATUS%F{white}%{↑%G%}$GIT_AHEAD"
    fi

    STATUS="$STATUS%F{white}|"

    if [ "$GIT_STAGED" -ne "0" ]; then
      STATUS="$STATUS%F{green}%{●%G%}$GIT_STAGED"
    fi

    if [ "$GIT_CONFLICTS" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{✖%G%}$GIT_CONFLICTS"
    fi

    if [ "$GIT_CHANGED" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{✚%G%}$GIT_CHANGED"
    fi

    if [ "$GIT_UNTRACKED" -ne "0" ]; then
      STATUS="$STATUS%F{red}%{…%G%}"
    fi

    if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
      STATUS="$STATUS%F{white}%{✔%G%}"
    fi

    STATUS="$STATUS%F{white})%f"
    echo "$STATUS"
  fi
}

# enable git
zstyle ':vcs_info:*' enable git

# enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true

# set custom symbols for unstaged/staged changes
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'

# show marker if there are untracked files
+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep -q '^?? ' 2> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[staged]+='%F{magenta}?'
    fi
}

### git: Show +N/-N when your local branch is ahead-of or behind remote HEAD.
# Make sure you have added misc to your 'formats':  %m
function +vi-git-st() {
    local ahead behind
    local -a gitstatus

    # Exit early in case the worktree is on a detached HEAD
    git rev-parse ${hook_com[branch]}@{upstream} >/dev/null 2>&1 || return 0

    local -a ahead_and_behind=(
        $(git rev-list --left-right --count HEAD...${hook_com[branch]}@{upstream} 2>/dev/null)
    )

    ahead=${ahead_and_behind[1]}
    behind=${ahead_and_behind[2]}

    (( $ahead )) && gitstatus+=( "↑${ahead}" )
    (( $behind )) && gitstatus+=( "↓${behind}" )

    hook_com[misc]+=${(j:/:)gitstatus}
}
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-st

# In normal formats and actionformats the following replacements are done:
#   %s : The VCS in use (git, hg, svn, etc.).
#   %b : Information about the current branch.
#   %a : An identifier that describes the action. Only makes sense in actionformats (rebase, merge, cherry-pick).
#   %r : The repository name. If %R is /foo/bar/repoXY, %r is repoXY.
#   %c : The string from the stagedstr style if there are staged changes in the repository.
#   %u : The string from the unstagedstr style if there are unstaged changes in the repository.
#
# Put the data into vcs_info_msg_*_ variables.
zstyle ':vcs_info:git:*' formats       '%F{white}(%F{blue}%b%F{white}%m|%F{red}%u%F{green}%c%f)'
zstyle ':vcs_info:git:*' actionformats '%F{white}(%F{blue}%b%F{white}%m|%a%F{red}%u%F{green}%c%f)'

# enable substitution on the prompt
setopt prompt_subst

# add git status to prompt
# %n - username
# %m - hostname
PROMPT='%F{5}[%F{2}%n%F{5}] %F{3}%3~ ${vcs_info_msg_0_}%f%# '

# to debug hooks (comment back in)
# zstyle ':vcs_info:*+*:*' debug true

export CLICOLOR=1

# Homebrew must be on PATH before any brew-installed tools are referenced
export PATH="/opt/homebrew/bin:$PATH"

# Auto-attach to or create a persistent tmux session on every new terminal
if [ -z "$TMUX" ]
then
    tmux attach -t TMUX || tmux new -s TMUX
fi

# mise manages runtime versions (Ruby, Python, Node, Java, etc.) per project
eval "$(mise activate zsh)"

# Adds ~/.local/bin to PATH; generated by uv installer for uv/uvx binaries
. "$HOME/.local/bin/env"

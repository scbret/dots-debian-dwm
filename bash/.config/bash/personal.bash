# my aliases -----------------------------------------
export EDITOR='nvim'
export ZK_NOTEBOOK_DIR="$HOME/repos/zk-notes"
HISTIGNORE="$HISTIGNORE:jrnl *"
HISTIGNORE="$HISTIGNORE:zk *"
alias v='$EDITOR'
alias vi='$EDITOR'

alias sx='startx'
alias sdn='sudo shutdown -h now'
alias sdr='sudo shutdown -r now'
alias bat='batcat'

#alias update='sudo pacman -Syyu'
alias fupdate='sudo apt update && sudo apt full-upgrade'

# zk notes
#alias zk='zk --working-dir=/home/steve/repos/zk-notes/'

# View images in current folder with wezterm + fzf
wiv() {
    local img
    img=$(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) \
          | sed 's|^\./||' \
          | fzf --prompt="Select image: " --height=40% --reverse)

    if [[ -n "$img" ]]; then
        wezterm imgcat "$img"
    else
        echo "No image selected."
    fi
}

# View images in current folder with qimvg + fzf
iv() {
    local img
    img=$(find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.webp" \) \
          | sed 's|^\./||' \
          | fzf --prompt="Select image: " --height=40% --reverse)

    if [[ -n "$img" ]]; then
        qimgv "$img"
    else
        echo "No image selected."
    fi
}


# Smart Vimwiki launcher
vw() {
    if command -v alacritty >/dev/null 2>&1; then
        if [ -n "$DISPLAY" ]; then
            alacritty --class VW -e nvim -c 'VimwikiIndex' & disown
            return
        else
            printf '%s\n' 'Alacritty is installed but no GUI session detected. Falling back to nvim.'
        fi
    fi
    nvim -c 'VimwikiIndex'
}


# MD Notes
mdn() {
    if command -v kitty >/dev/null 2>&1; then
        if [ -n "$DISPLAY" ]; then
            # Run kitty detached so it won't block the shell
            setsid -f kitty --class MDNOTES -e /home/steve/.scripts/mdnotes.sh >/dev/null 2>&1
        else
            echo "Error: no DISPLAY found (are you running in a GUI session?)" >&2
        fi
    else
        echo "Error: kitty not installed, running in current terminal." >&2
        /home/steve/.scripts/mdnotes.sh &
    fi
}

# dwm mdnotes
alias mdd='/home/steve/.scripts/md-notes-dwm.sh'

# Update jrnl entries
alias jpl='source /home/steve/.scripts/pull_jrnl.sh'
alias jps='source /home/steve/.scripts/push_jrnl.sh'

# Update vimwiki entries
alias vpl='source /home/steve/.scripts/pull_vwiki.sh'
alias vps='source /home/steve/.scripts/push_vwiki.sh'

# Update dotfiles
alias dpl='source /home/steve/.scripts/pull_dots.sh'
alias dps='source /home/steve/.scripts/push_dots.sh'

# Update mdnotes entries
alias npl='source /home/steve/.scripts/pull_mdnotes.sh'
alias nps='source /home/steve/.scripts/push_mdnotes.sh'

# Update zk-notes entries
alias zkl='source /home/steve/.scripts/pull_zknotes.sh'
alias zks='source /home/steve/.scripts/push_zknotes.sh'

# Update tasks entries
alias tkl='source /home/steve/.scripts/pull_tasks.sh'
alias tks='source /home/steve/.scripts/push_tasks.sh'

# git section
alias g='git'
alias ga='g add .'
gc() {
    local hostname=$(hostnamectl | awk -F ': ' '/Static hostname/ {print $2}')
    g commit -m "$hostname"
}
alias hn='hostnamectl | awk -F ": " "/Static hostname/ {print \$2}"'
alias gps='g push'
alias gpl='g pull'
alias gs='g status'
alias gst='g stash'
alias gsp='g stash; g pull'
# git section

alias pv='source ~/venv/.scripts/activate'
alias snake='python3 ~/py-scripts/jan-snake-game.py'
alias fh='history | fzf'
alias df='df -haT --total'
alias ht='htop'
alias bt='btop'
alias free='free -mt'
alias cputemp='sensors | grep Core'
alias fp="\$(fzf --reverse --preview 'batcat --style=numbers --color=always --line-range :500 {}')"
alias fp1="fzf --reverse --preview='batcat --color=always --line-range :500 {}' --.scriptsd shift-up:preview-page-up,shift-down:preview-page-down"
alias fd='findir'
alias tt='taskwarrior-tui'
alias tl='task list'
alias tw='task waiting'
alias tm='tmux'
alias lsd='lsd -l'
alias ftf='fastfetch'
alias nf='neofetch'
alias pf='pfetch'
alias zl='zellij'
alias qn='$EDITOR ~/repos/zk-notes/notes/2025_10_24-qnotes.md'
alias yy='yazi'
alias gt='python3 ~/repos/tasks/getTagIDsV3.py'
alias hx='helix'
alias py='python3'
alias wvi='wezterm imgcat'

alias q='exit'
alias cl='clear'
alias sb='source ~/.bashrc'
alias brc='vi ~/.config/bash/personal.bash'
alias vrc='vi ~/.config/nvim/init.vim'

#weather in terminal
alias wf='curl wttr.in/mason+city?u'
alias gw='bash ~/.scripts/wmap-weather.sh'
alias gwc='bash ~/.scripts/wmap-weather-city.sh'

# <<< open or edit previewed files with fzf >>> #
#export FZF_DEFAULT_OPTS='--height 75% --layout=reverse --border --info=inline'

fo() {
  IFS=$'\n' out=("$(fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}' --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-nvim} "$file"
  fi
}

findir() {
    local dir
    dir=$(find /home/$USER -maxdepth 3 -type d,l | fzf)
    if [[ -n "$dir" ]]; then
        cd "$dir" || return
    fi
}

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh

# Colored man with bat
#export MANPAGER="less -R --use-color -Dd+g -Du+b"
#export MANPAGER="sh -c 'col -bx | batcat -l man -p'"

figlet SwineID
#pfetch

eval "$(starship init bash)"
source "$HOME/.cargo/env"

# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

[ -f ~/.dotfiles/bash/.bash_aliases ] && source ~/.dotfiles/bash/.bash_aliases
[ -f ~/.dotfiles/bash/.bash_import ] && source ~/.dotfiles/bash/.bash_import

# Historia
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTTIMEFORMAT="%F %T "
export HISTCONTROL=erasedups:ignoredups:ignorespace
shopt -s histappend
PROMPT_COMMAND='history -a'

# COMPLETION
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [[ $- == *i* ]]; then
    bind "set completion-ignore-case on"
    bind "set show-all-if-ambiguous on"
fi

# KOLORY
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.png=01;35:*.mp3=01;35:*.wav=01;35:'

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

git() {
    if [ "$1" = "am" ]; then
        echo "Komenda 'git am' została zablokowana!"
        return 1
    fi
    command git "$@"
}

update-source() {
    source ~/.bashrc
    echo "bash source files updated"
    currentDir=$(pwd)
    source ~/.config/tmux-manager/tmux-manager.sh
    echo "tmux-manager reloaded"
    cd "$currentDir"
}

extract() {
    for archive in "$@"; do
        if [ -f "$archive" ]; then
            case $archive in
                *.tar.bz2) tar xvjf "$archive" ;;
                *.tar.gz)  tar xvzf "$archive" ;;
                *.bz2)     bunzip2 "$archive" ;;
                *.rar)     rar x "$archive" ;;
                *.gz)      gunzip "$archive" ;;
                *.tar)     tar xvf "$archive" ;;
                *.tbz2)    tar xvjf "$archive" ;;
                *.tgz)     tar xvzf "$archive" ;;
                *.zip)     unzip "$archive" ;;
                *.Z)       uncompress "$archive" ;;
                *.7z)      7z x "$archive" ;;
                *) echo "nie wiem jak rozpakować '$archive'..." ;;
            esac
        else
            echo "'$archive' nie jest prawidłowym plikiem!"
        fi
    done
}

pac() {
    local pkg
    pkg=$(pacman -Slq | fzf --multi --preview 'pacman -Si {}') || return
    sudo pacman -S --needed $pkg && echo "Zainstalowano $pkg"
}

ypac() {
    local pkg
    pkg=$(yay -Slq | fzf --multi --preview 'yay -Si {}') || return
    yay -S --needed $pkg && echo "Zainstalowano: $pkg"
}


# >>> tmux-manager <
if [[ -x "$HOME/.local/bin/tmux-manager" ]]; then
    tmux-manager auto-resume
    if [[ -z "$TMUX" ]]; then
        if [[ -n "$ZSH_VERSION" ]]; then
            _tmux_manager_fzf() { tmux-manager fzf-dirs-print; zle reset-prompt; }
            zle -N _tmux_manager_fzf
            bindkey '^F' _tmux_manager_fzf
        else
            bind -x '"\C-f": tmux-manager fzf-dirs-print'
        fi
    fi
fi
# <<< tmux-manager <

eval "$(starship init bash)"

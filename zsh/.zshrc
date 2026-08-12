[[ -o interactive ]] || return

[ -f ~/.dotfiles/bash/.bash_aliases ] && source ~/.dotfiles/bash/.bash_aliases
[ -f ~/.dotfiles/bash/.bash_import ]  && source ~/.dotfiles/bash/.bash_import

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt extended_history          
setopt inc_append_history        
setopt hist_ignore_dups          
setopt hist_ignore_all_dups      
setopt hist_ignore_space         
setopt hist_reduce_blanks
# podgląd z datą: history -i   /   history -i 1

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit   # dla completion pisanych pod bash
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # completion-ignore-case
setopt auto_list                                            # show-all-if-ambiguous
unsetopt list_ambiguous
setopt auto_menu

export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.zip=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.png=01;35:*.mp3=01;35:*.wav=01;35:'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

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
    source ~/.zshrc
    echo "zsh source files updated"
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
    local out
    local -a pkgs
    out=$(pacman -Slq | fzf --multi --preview 'pacman -Si {}') || return
    pkgs=("${(f)out}")
    (( ${#pkgs} )) || return
    sudo pacman -S --needed "${pkgs[@]}" && echo "Zainstalowano: ${pkgs[*]}"
}

ypac() {
    local out
    local -a pkgs
    out=$(yay -Slq | fzf --multi --preview 'yay -Si {}') || return
    pkgs=("${(f)out}")
    (( ${#pkgs} )) || return
    yay -S --needed "${pkgs[@]}" && echo "Zainstalowano: ${pkgs[*]}"
}

# >>> tmux-manager 
if [[ -x "$HOME/.local/bin/tmux-manager" ]]; then
    tmux-manager auto-resume
    if [[ -z "$TMUX" ]]; then
        _tmux_manager_fzf() {
            tmux-manager fzf-dirs-print
            zle reset-prompt
        }
        zle -N _tmux_manager_fzf
        bindkey '^F' _tmux_manager_fzf
    fi
fi
# <<< tmux-manager 

eval "$(starship init zsh)"

# ~/.bash_profile
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    export TERMINAL=ghostty
    exec startx
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc

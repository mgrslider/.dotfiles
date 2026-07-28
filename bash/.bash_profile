# ~/.bash_profile

export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export JAVA_HOME=/usr/lib/jvm/default
export ANDROID_NDK_ROOT="$HOME/Android/Ndk/android-ndk-r27"
export NVM_DIR="$HOME/.config/nvm"
export DIARY_PATH=/work/notes/my-diary
export DIARY_INTERVAL=10

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi

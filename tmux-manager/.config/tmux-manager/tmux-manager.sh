#!/bin/bash

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-manager/config"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

_session_name_from_path() {
    echo "$1" | sed 's|^/||; s|[/. ]|_|g'
}

_is_in_tmux() {
    [[ -n "$TMUX" ]]
}

_tmux_last_session() {
    tmux list-sessions -F "#{session_last_attached} #{session_name}" 2>/dev/null \
        | sort -rn | awk 'NR==1{print $2}'
}

_tmux_current_session() {
    tmux display-message -p '#S' 2>/dev/null
}

_tmux_list_sessions() {
    tmux list-sessions -F "#{session_name}" 2>/dev/null
}

_collect_dirs() {
    local -a scan_dirs exclude_dirs

    for d in "${TMUX_DIRS_L0[@]}"; do
        exclude_dirs+=("$d")
    done

    _is_excluded() {
        local p="$1"
        for ex in "${exclude_dirs[@]}"; do
            [[ "$p" == "$ex" || "$p" == "$ex"/* ]] && return 0
        done
        return 1
    }

    for d in "${TMUX_DIRS_L1[@]}"; do
        _is_excluded "$d" || scan_dirs+=("$d")
    done

    for d in "${TMUX_DIRS_L2[@]}"; do
        while IFS= read -r s; do
            _is_excluded "$s" || scan_dirs+=("$s")
        done < <(find "$d" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    done

    for d in "${TMUX_DIRS_L3[@]}"; do
        while IFS= read -r s; do
            _is_excluded "$s" || scan_dirs+=("$s")
        done < <(find "$d" -mindepth 1 -maxdepth 2 -type d 2>/dev/null)
    done

    for d in "${TMUX_DIRS_L4[@]}"; do
        while IFS= read -r s; do
            _is_excluded "$s" || scan_dirs+=("$s")
        done < <(find "$d" -mindepth 1 -maxdepth 3 -type d 2>/dev/null)
    done

    [[ ${#scan_dirs[@]} -eq 0 ]] && { echo "Brak folderów w configu." >&2; return 1; }
    printf '%s\n' "${scan_dirs[@]}" | sort -u
}

tmux_auto_resume() {
    [[ -n "$TMUX" ]] && return
    [[ -z "$TERM" || "$TERM" == "dumb" ]] && return

    defaultName=$(_session_name_from_path "$HOME")
    # Brak sesji — stwórz domyślną i wejdź
    if ! tmux list-sessions &>/dev/null; then
        tmux new-session -s "$defaultName" -c "$HOME"
        tmux set-option -t "$name" @root_path "$HOME"
        exec tmux attach-session -t "$defaultName"
    fi

    local last attached
    last=$(_tmux_last_session)
    [[ -z "$last" ]] && exec tmux new-session -s "$defaultName" -c "$HOME"

    attached=$(tmux list-sessions -F "#{session_name} #{session_attached}" 2>/dev/null \
        | awk -v s="$last" '$1==s{print $2}')

    [[ "$attached" == "0" ]] && exec tmux attach-session -t "$last"
}

tmux_fzf_dirs_print() {
    local dirs
    dirs=$(_collect_dirs) || return 1

    echo "$dirs" | fzf \
        --prompt="󰉋 Folder > " \
        --header="ENTER: otwórz/wznów sesję | ESC: anuluj" \
        --preview="ls --color=always -la '{}' 2>/dev/null | head -20" \
        --preview-window="right:45%" \
        --ansi \
        --border=rounded \
        ${FZF_TMUX_OPTS:-}
}

tmux_fzf_pick_and_open() {
    local tmp="$1"
    local dir
    dir=$(tmux_fzf_dirs_print) || return 0
    [[ -z "$dir" ]] && return 0
    echo "$dir" > "$tmp"
}

tmux_open_path() {
    local dir="$1"
    local name
    name=$(_session_name_from_path "$dir")

    if ! tmux has-session -t "=$name" 2>/dev/null; then
        tmux new-session -ds "$name" -c "$dir"
        tmux set-option -t "$name" @root_path "$dir"
    fi

    if _is_in_tmux; then
        local client
        client=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
        if [[ -n "$client" ]]; then
            tmux switch-client -c "$client" -t "=$name"
        else
            tmux switch-client -t "=$name"
        fi
    else
        tmux attach-session -t "=$name"
    fi
}

tmux_session_picker() {
    local sessions current selected
    sessions=$(_tmux_list_sessions)
    [[ -z "$sessions" ]] && { echo "Brak sesji." >&2; return 1; }
    current=$(_tmux_current_session)

    selected=$(echo "$sessions" | fzf \
        --prompt="  Sesja > " \
        --header="ENTER: przełącz | aktualna: ${current:-brak}" \
        --preview="tmux list-windows -t '{}' 2>/dev/null" \
        --preview-window="right:40%" \
        --border=rounded \
        ${FZF_TMUX_OPTS:-}
    )

    [[ -z "$selected" ]] && return 0
    if _is_in_tmux; then
        tmux switch-client -t "$selected"
    else
        tmux attach-session -t "$selected"
    fi
}

tmux_next_session() { tmux switch-client -n; }
tmux_prev_session() { tmux switch-client -p; }

tmux_new_named() {
    local name
    name=$(tmux display-popup -E "bash -c 'read -p \"Nazwa sesji: \" n && echo \$n'" 2>/dev/null)
    [[ -z "$name" ]] && return 0
    name=$(echo "$name" | tr ' ' '_' | tr -cd '[:alnum:]_-')

    if tmux has-session -t "$name" 2>/dev/null; then
        tmux switch-client -t "$name"
    else
        tmux new-session -ds "$name" -c "$HOME"
        tmux set-option -t "$name" @root_path "$HOME"
        tmux switch-client -t "$name"
    fi
}

_tmux_root_path() {
    current=$(_tmux_current_session)
    tmux show-option -qv -t "$current" @root_path
}

case "${1:-}" in
    auto-resume)     tmux_auto_resume ;;
    fzf-dirs-print)   tmux_fzf_dirs_print ;;
    fzf-pick)         tmux_fzf_pick_and_open "${2:?Podaj plik tymczasowy}" ;;
    open-path)       tmux_open_path "${2:?Podaj ścieżkę}" ;;
    session-picker)  tmux_session_picker ;;
    next-session)    tmux_next_session ;;
    prev-session)    tmux_prev_session ;;
    new-named)       tmux_new_named ;;
    root_path)       _tmux_root_path ;;
    *)
        echo "Użycie: tmux-manager <komenda>"
        echo "  auto-resume     — wznów ostatnią sesję"
        echo "  fzf-dirs-print  — fuzzy finder, drukuje wybraną ścieżkę"
        echo "  open-path <dir> — otwórz/wznów sesję dla ścieżki"
        echo "  session-picker  — picker aktywnych sesji"
        echo "  next-session    — następna sesja"
        echo "  prev-session    — poprzednia sesja"
        echo "  new-named       — nowa sesja z nazwą"
        echo "  root_path       - główny katalog sesji"
        ;;
esac

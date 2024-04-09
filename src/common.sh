#!/bin/bash

hash() { builtin hash "$1" 2>/dev/null; }

init_term() {
    shopt -s checkwinsize; (:;:); ((rows=LINES - 1))

    printf '\e[?1049h\e[?7l\e[?25l'
}

deinit_term() {
    printf '\e[?1049l\e[?7h\e[?25h'
}

read_keys() { read -rsn1; [[ $REPLY == $'\e' ]] && read -rsn2; }

_draw() {
    unset i cursorHist
    cursor="$rows"
    
    printf '\e[2J\e[%dH' "$LINES"
    printf '%s\n' "$@"
}

hover_interface() {
    local -n foo=$1
    local fooInit=("$@") fooCnt="${#foo[@]}"
    
    printf '\e[%dH\e[32m%s\e[m' "$cursor" "${foo[cursor-LINES]%:*}"
    
    cursorHist+=("$cursor")
    if (( ${i:=0} )); then
        printf '\e[%dH%s' "${cursorHist[0]}" "${foo[cursorHist[0]-LINES]}"
        cursorHist=("${cursorHist[@]:1}")
    else
        ((i++))
    fi

    read_keys
    case $REPLY in
        [qQ]) exit;;
        '[B'|[kKwW]) ((cursor++));;
        '[A'|[jJsS]) ((cursor--));;
    esac

    if (( ${#fooInit[@]} > rows )); then
        (( cursor < LINES-fooCnt ))&& cursor="$rows"

        if (( cursor > rows )); then
            fooInit=("${fooInit[@]:1}")
            foo=("${fooInit[@]:0:${#foo[@]}+rows}")
            _draw "${foo[@]}"
            cursor=1
        elif (( cursor < 1 )); then
            fooInit=("${fooInit[@]:1}")
            foo=("${foo[@]:0:${#foo[@]}-rows}")
            _draw "${foo[@]}"
        fi
    else
        if (( cursor > rows )); then
            ((cursor=LINES-fooCnt))
        elif (( cursor < LINES-fooCnt )); then
            cursor="$rows"
        fi
    fi
}

base_keymap() {
    for((;;)) {
        _sbar '[<] back'

        read_keys
        [[ $REPLY =~ ^'[D'$|^[hHaA]$ ]]&& return
    }
}

_sbar() { printf '\e[%dHPKM %s' "$LINES" "$1"; }
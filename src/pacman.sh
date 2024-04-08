#!/bin/bash

. ./common.sh

_query() {
    local n=0 pkg line pkgName pkgDesc

    until [[ $pkg ]]; do
        sbar 'Query: '
        
        read -r pkg
        printf '\e[T'
    done

    while read -r line; do
         if [[ $line =~ / ]]; then
            [[ $line =~ (.*)/(.*)\ (.*[0-9]) ]]&& {
                #pkgRepo="${BASH_REMATCH[1]}"
                pkgName="${BASH_REMATCH[2]}"
                #pkgVer="${BASH_REMATCH[3]}"
            }
         else
            pkgDesc="$line"
        fi

        if (( n )); then
            n=0 pkgs+=("$pkgName: $pkgDesc")
        else
            n=1
        fi
    done < <(pacman -Ss "$pkg")
    pkgsInit=("${pkgs[@]}")

    draw "${pkgs[@]}"
}

_info() {
    printf '\e[2J\r'
                
    pacman -Si "${pkgs[cursor-LINES]%:*}"

    printf '\e[?25l'
}

_install() {
    printf '\e[2J\e[H\e[?25h'
    
    sudo pacman -Ss "${pkgs[cursor-LINES]%:*}"
    
    printf '\e[?25l'
}

info_install() {
    _info

    for((;;)) {
        sbar '[<] back [>] install'
        
        read_keys
        case $REPLY in
            '[D'|[hHaA]) break;;
            '[C'|[lLdD]) _install;;
        esac
    }

    draw "${pkgs[@]}"
}

query_info_install() {
    _query

    for((;;)) {
        sbar '[<] back [>] info'

        hover_interface pkgs "${pkgsInit[@]}"

        case $REPLY in
            '[D'|[hHaA]) return ;;
            '[C'|[lLdD]) info_install;;
        esac
    }

    draw
}

_update() {
    printf '\e[2J\e[H\e[?25h'

    sudo pacman -Syu

    printf '\e[?25l'

    _keymap
}
#!/bin/bash

_delete() {
    [[ $1 ]]|| {
        _sbar 'Delete: '

        read -r pkg
    }

    printf '\e[2J\e[H'
    
    sudo pacman -Runs "${1:-$pkg}"

    printf '\e[?25l'

    base_keymap
}

list_installed() {
    printf '\e[2J'

    mapfile -t installed < <(pacman -Qqe)
    installedInit=("${installed[@]}")
    
    _draw "${installed[@]}"

    for((;;)) {
        _sbar '[<] back [>] delete'

        hover_interface installed "${installedInit[@]}"

        case $REPLY in
            '[D'|[hHaA]) return 1;;
            ''|'[C'|[lLdD])
                _delete "${installed[cursor-LINES]}"
                _draw "${installed[@]}"
            ;;
        esac
    }
}

_install() {
    [[ $1 ]]|| {
        _sbar 'Install: '

        read -r pkg
    }

    printf '\e[2J\e[H\e[?25h'
        
    sudo pacman -S "${1:-$pkg}" && base_keymap

    printf '\e[?25l'

    base_keymap

    _draw "${queries[@]-}"
}


_info() {
    [[ $1 ]]|| {
        _sbar 'Info: '

        read -r pkg
    }

    printf '\e[2J\e[H\e[?25h'

    pacman -Si "${1:-$pkg}" && base_keymap

    printf '\e[?25l'

    _draw "${queries[@]-}"
}

_query() {
    local n=0 query queries queriesInit line pkgName pkgDesc

    printf '\e[?25h'
    _sbar 'Query: '
        
    read -r query
    printf '\e[T\e[?25l'

    [[ $query ]]|| return 1

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
            n=0 queries+=("$pkgName: $pkgDesc")
        else
            n=1
        fi
    done < <(pacman -Ss "$query")
    queriesInit=("${queries[@]}")

    _draw "${queries[@]}"

    for((;;)) {
        _sbar '[<] back [>] install'

        hover_interface queries "${queriesInit[@]}"

        case $REPLY in
            '[D'|[hHaA]) return 1;;
            ''|'[C'|[lLdD]) _install "${queries[cursor-LINES]}";;
        esac
    }
}

_update() {
    printf '\e[2J\e[H\e[?25h'

    sudo pacman -Syu

    printf '\e[?25l'

    for((;;)) {
        _sbar '[*] continue'
        
        read_keys
        
        return
    }
}
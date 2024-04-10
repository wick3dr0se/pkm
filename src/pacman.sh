#!/bin/bash

_pacman() {
    printf '\e[2J\e[H\e[?25h'

    if (( $3 )); then
        sudo pacman "$1" "$2"
    else
        pacman "$1" "$2"
    fi

    printf '\e[?25l'
}

list_installed() {
    local installed installedInit
    
    mapfile -t installed < <(pacman -Qqe)
    installedInit=("${installed[@]}")
    
    printf '\e[2J'

    _draw "${installed[@]}"

    for((;;)) {
        _ibar '[<] back [>] delete'
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

_delete() {
    [[ $1 ]]|| _ibar 'Delete: ' pkg
    _pacman -Runs "${1:-$pkg}" 1
    base_keymap
}

_install() {
    local pkg

    [[ $1 ]]|| _ibar 'Install: ' pkg
    _pacman -S "${1:-$pkg}" 1
    base_keymap
    _draw "${queries[@]-}"
}


_info() {
    local pkg

    [[ $1 ]] || _ibar 'Info: ' pkg
    _pacman -Si "${1:-$pkg}"
    base_keymap
}

_query() {
    local n=0 pkg queries queriesInit line pkgName pkgDesc

    _ibar 'Query: ' pkg
    [[ $pkg ]] || return 1

    while read -r line; do
         if [[ $line =~ / ]]; then
            [[ $line =~ (.*)/(.*)\ (.*[0-9]) ]] && {
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
    done < <(pacman -Ss "$pkg")
    queriesInit=("${queries[@]}")

    _draw "${queries[@]}"

    for((;;)) {
        _ibar '[<] back [>] install'
        hover_interface queries "${queriesInit[@]}"

        case $REPLY in
            '[D'|[hHaA]) return 1;;
            ''|'[C'|[lLdD]) _install "${queries[cursor-LINES]}";;
        esac
    }
}

_update() {
    sudo pacman -Syu

    printf '\e[?25l'

    for((;;)) {
        _ibar '[*] continue' ''; read -rn1
        
        return
    }
}
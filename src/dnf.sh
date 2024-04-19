#!/bin/bash

_dnf() {
    printf '\e[2J\e[H\e[?25h'

    if (( $3 )); then
        sudo dnf "$1" "$2"
    else
        dnf "$1" "$2"
    fi

    printf '\e[?25l'
}

list_installed() {
    local installed installedInit
    
    mapfile -t installed < <(dnf repoquery --userinstalled)
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
    _dnf remove "${1:-$pkg}" 1
    base_keymap
}

_install() {
    local pkg

    [[ $1 ]] || _ibar 'Install: ' pkg
    _dnf install "${1:-$pkg}" 1
    base_keymap
    _draw "${queries[@]-}"
}

_info() {
    local pkg

    [[ $1 ]] || _ibar 'Info: ' pkg
    dnf -C info "${1:-$pkg}"
    base_keymap
}

_query() {
    local pkg queries queriesInit

    _ibar 'Query: ' pkg
    [[ $pkg ]] || return
    
    mapfile -t queries < <(dnf search "${1:-$pkg}")
    queriesInit=("${queries[@]}")
    
    printf '\e[2J'

    _draw "${queries[@]}"

    for((;;)) {
        _ibar '[<] back [>] delete'
        hover_interface queries "${queriesInit[@]}"

        case $REPLY in
            '[D'|[hHaA]) return 1;;
            ''|'[C'|[lLdD])
                _delete "${queries[cursor-LINES]%% -*}"
                _draw "${queries[@]}"
            ;;
        esac
    }
}

_update() {
    printf '\e[?25h'

    for _ in autoremove; do sudo dnf "$_" --refresh; done

    printf '\e[?25l'

    for((;;)) {
        _ibar '[*] continue' ''; read -rn1
        
        return
    }
}

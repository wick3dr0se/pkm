#!/bin/bash

_zypper() {
    printf '\e[2J\e[H\e[?25h'

    if (( $3 )); then
        sudo zypper "$1" "$2"
    else
        zypper "$1" "$2"
    fi

    printf '\e[?25l'
}

list_installed() {
    local installed installedInit
    
    mapfile -t installed < <(zypper search -i | awk '{print $3}')
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
    _zypper remove "${1:-$pkg}" 1
    base_keymap
}

_install() {
    local pkg

    [[ $1 ]] || _ibar 'Install: ' pkg
    _zypper install "${1:-$pkg}" 1
    base_keymap
    _draw "${queries[@]-}"
}


_info() {
    local pkg

    [[ $1 ]] || _ibar 'Info: ' pkg
    _zypper info "${1:-$pkg}"
    base_keymap
}

_query() {
    local pkg queries queriesInit

    _ibar 'Query: ' pkg
    [[ $pkg ]] || return
    
    mapfile -t queries < <(zypper search -i "${1:-$pkg}")
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

    ARGU=up

    if grep tumbleweed /etc/os-release > /dev/null 2>&1; then
        ARGU=dup
    fi

    for _ in $ARGU; do sudo zypper "$_" --no-allow-vendor-change; done

    printf '\e[?25l'

    for((;;)) {
        _ibar '[*] continue' ''; read -rn1
        
        return
    }
}

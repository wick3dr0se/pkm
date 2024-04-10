!/bin/bash

_apt() {
    printf '\e[2J\e[H\e[?25h'

    if (( $3 )); then
        sudo apt "$1" "$2"
    else
        apt "$1" "$2"
    fi

    printf '\e[?25l'
}

list_installed() {
    local installed installedInit
    
    mapfile -t installed < <(apt-mark showinstall)
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
    _apt purge "${1:-$pkg}" 1
    base_keymap
}

_install() {
    local pkg

    [[ $1 ]] || _ibar 'Install: ' pkg
    _apt install "${1:-$pkg}" 1
    base_keymap
    _draw "${queries[@]-}"
}


_info() {
    local pkg

    [[ $1 ]] || _ibar 'Info: ' pkg
    _apt show "${1:-$pkg}"
    base_keymap
}

_query() {
    local pkg queries queriesInit

    _ibar 'Query: ' pkg
    [[ $pkg ]] || return
    
    mapfile -t queries < <(apt-cache search "${1:-$pkg}")
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

    for _ in autoremove clean update upgrade; do sudo apt "$_"; done

    printf '\e[?25l'

    for((;;)) {
        _ibar '[*] continue' ''; read -rn1
        
        return
    }
}
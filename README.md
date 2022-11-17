# pkg
A stupid simple, lightweight, multi-package manager wrapper that simplifies arguments and usage

## Compatability
- pacman->AUR (Arch Linux)
- apt (Debian)
- rpm (RHEL)
- winget (Windows)
- brew (MacOS)

## Usage
get help from your package manager
```bash
pkg {-?|-h|--help|help}
```
update packages
```bash
pkg
# or
pkg {-u|update|sync}
```

install specified package(s)
```bash
pkg {-a|add|install} <package>
```

show information about specified package(s)
```bash
pkg {-i|info|show} <package>
```

list installed packages
```bash
pkg {-l|list}
```

list database packages
```bash
pkg {-la|list-all}
```

search for specified package(s) in database
```bash
pkg {-s|search|look} <package>
```

uninstall specified package(s)
```bash
pkg {-d|del|delete|rmv|remove|uninstall} <package>
```

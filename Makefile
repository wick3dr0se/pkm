install:
	@printf "\e[0;34m>>\e[0m pkm - A super minimal TUI package manager wrapper written in BASH v4.2+\n"
	@printf ">> Makefile made by o69mar\n"
	@read -p ">> You are about to install pkm, press ENTER to install pkm."
	@install -Dm755 -v pkm /usr/local/bin/pkm

uninstall:
	@printf "\e[0;34m>>\e[0m pkm - A super minimal TUI package manager wrapper written in BASH v4.2+\n"
	@printf ">> Makefile made by o69mar\n"
	@read -p ">> You are about to uninstall pkm, press ENTER to uninstall pkm."
	@rm -rfv /usr/local/bin/pkm


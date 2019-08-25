#!/bin/bash
##
## Copyright 2019 Luis_Pulido_Diaz
##
## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),      ##
## to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,      ##
## and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:              ##
##                                                                                                                                                         ##
## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.                          ##
##                                                                                                                                                         ##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     ##
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      ##
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS    ##
## IN THE SOFTWARE.
##
PROGRAM_NAME="aauuid installer"
PROGRAM_VERSION="0.1"
PROGRAM_URL="https://raw.githubusercontent.com/africanmx/aauuid/dev/bin/aauuid"
PROGRAM_COMMAND="aauuid"
case "$SHELL" in
	*termux*)
		case "$LANG" in
			*es_*)
				echo "Que bonito que estas usando Termux"
			;;
			*)
				echo "Beautiful it is that you are using Termux"
			;;
		esac
		LUGAR_A_INSTALAR=~/../usr/bin
	;;
	*)
		case "$(id -u)" in
			0)
				LUGAR_A_INSTALAR=/usr/bin
			;;
			*)
				LUGAR_A_INSTALAR=~/.local/bin
			;;
		esac
	;;
esac
instaladordeaauuid(){
	case "$1" in
		--version) xecho "$PROGRAM_VERSION"; ;;
		--help)
			cat <<EOF

$PROGRAM_NAME
   Version $PROGRAM_VERSION

Te instala el aauuid en tu computadora

other options:

	$0 --version 		Shows this script's version
	$0 --help 		Shows this screen.
EOF
	;;
	*)
		run "$@"
	;;
	esac
}
run(){
	case "$1" in
		--i|i|--interactive|--interactivo)
			read -p "Seguro? s/n "
			case "$REPLY" in
				S*|s*)
					instalar_aauuid
				;;
				*)
					echo Ok Bye
					exit
				;;
			esac
		;;
		*)
			instalar_aauuid
		;;
	esac
}
aborta(){
	echo "$@"
	exit 1
}
comprueba_aauuid(){
	aauuid
	aauuid
	aauuid
	echo
	echo About aauuid
	aauuid --version
	aauuid --help
}
detect_package_manager(){
        case "$SHELL" in
                *termux*) echo termux && return; ;;
                *) ;;
        esac
        test -f /etc/debian_version && echo apt && return
        test -f /etc/redhat-release && echo yum && return
        test -f /etc/arch-release && echo pacman && return
        test -f /etc/gentoo-release && echo emerge && return
        test -f /etc/SuSE-release && echo zypp && return
}
try_to_install(){
	case "$PATH" in
		*WINDOWS*)
			aborta "You need to install $1 for Windows, manually"
		;;
		*termux*)
			echo Don termux
			test -z "$(which uuid)" && apt update && apt install ossp-uuid && return
		;;
		*)
			message=$(cat <<EOF
Solamente root puede instalar paquetes que hacen falta, y en este caso
hace falta que instales $1 en este dispositivo.
Para no tener que hacerlo manualmente, puedes correr este instalador con
privilegios administrativos.

Ejemplo: curl https://luispulido.com/bins/installaauuid.sh | sudo sh

Disculpa las molestias.

EOF
)
			test "$SHELL" ! =~ termux && test "$(id -u)" -ne 0 && aborta "$message"
		        case "$(detect_package_manager)" in
		                apt)
		                        apt update
		                        apt -y install "$1"
		                ;;
		                yum)
		                        yum update
		                        yum -y install "$1"
		                ;;
		                pacman)
		                        pacman -Su
		                        yes | pacman -S -y "$1"
		                ;;
		                emerge)
		                        echo "Program $1 unavailable for Gentoo install" >&2
		                        exit 127
		                ;;
		                zypp)
		                        echo "Program $1 unavailable for Suse install" >&2
		                        exit 127
		                ;;
		        esac
		;;
	esac
}
try_to_install_uuid(){
	test "$SHELL" =~ termux && try_to_install ossp-uuid || try_to_install uuid
}
instalar_aauuid(){
	test "$(id -u)" -eq 0 && echo "Warning: You are executing as root. You can still abort in 4 seconds..." && sleep 4
	(
		cd "$LUGAR_A_INSTALAR"
		echo Descargando...
		curl -o "$PROGRAM_COMMAND" "$PROGRAM_URL" >/dev/null 2>&1
		echo Haciendo ejecutable...
		chmod +x "$PROGRAM_COMMAND"
		test -x "$(command -v aauuid)" && echo "aauuid instalado OK!" || aborta "aauuid no se pudo instalar"
		aauuid --create --force >/dev/null 2>/dev/null
		test -f ~/XCRT && comprueba_aauuid || aborta "aauuid no pudo generar el ~/XCRT"
	)
}
test -x "$(command -v aauuid)" && echo Ya tienes aauuid chav@ revisate && exit 0
instaladordeaauuid "$@"

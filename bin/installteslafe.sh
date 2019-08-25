#!/bin/bash
byecos(){
	echo "$@"
	exit
}
diecos(){
	echo "$@" >&2
	exit 1
}
installer(){
	dry_run
}
get_install_place(){
	test -d ~/../usr/bin && echo ~/../usr/bin && return
	test -d ~/.local/bin && echo ~/.local/bin && return
	test -d /usr/bin && echo /usr/bin && return
	test -d /bin && echo /bin && return
	diecos "The install directory could not be available"
}
check_sum_and_die_if_must(){
	[ "$1" = "$2" ] && echo "Checksum OK" && return
	[ -f teslafe ] && rm teslafe
	diecos "Checksum failed"
}
dry_run(){
	test -x "$(command -v teslafe)" && diecos "You already have Teslafe"
	sha256sum="31aadee1bd72c11734780e6b004718d5f5a0d2c1935b4ca75afe66e7051d4fe5  teslafe"
	url="https://luispulido.com/bins/teslafe"
	place="$(get_install_place)"
	(
		test -d "$place" && cd "$place" || continue
		curl -O "$url" 2>/dev/null
		gotsum="$(sha256sum teslafe)"
		check_sum_and_die_if_must "$gotsum" "$sha256sum"
		chmod +x teslafe
	)
	if [ -x "$(command -v teslafe)" ] ; then
		installed_ok
	else
		diecos "Teslafe could not be installed"
	fi

}
installed_ok(){
	echo "Teslafe was installed OK"
	echo "You can run teslafe now"
	echo
	echo "Teslafe: $(teslafe --verbatim)"
}
installer

test -d /Applications/VLC.app || return

vlc() {
  open -a /Applications/VLC.app $*
}

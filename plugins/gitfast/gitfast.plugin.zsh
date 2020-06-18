source "${0:A:h}/git-prompt.sh"

function git_prompt_info() {
  dirty="$(parse_git_dirty)"
  __git_ps1 "${ZSH_THEME_GIT_PROMPT_PREFIX//\%/%%}%s${dirty//\%/%%}${ZSH_THEME_GIT_PROMPT_SUFFIX//\%/%%}"
}

git_root_dir() {
  inside=$(git rev-parse --is-inside-git-dir 2> /dev/null)
  test $? -eq 0 || return

  case $inside in
    true)
      echo ${$(git rev-parse --git-dir)%.git}
      >&2 echo HAI THERE
      ;;
    false)
      git rev-parse --show-toplevel || echo '.'
      ;;
  esac
}

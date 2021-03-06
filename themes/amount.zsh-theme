# vim: set ft=zsh :
# On a mac with snow leopard, for nicer terminal colours:

# - Install SIMBL: http://www.culater.net/software/SIMBL/SIMBL.php
# - Download'Terminal-Colours': http://bwaht.net/code/TerminalColours.bundle.zip
# - Place that bundle in ~/Library/Application\ Support/SIMBL/Plugins (create that folder if it doesn't exist)
# - Open Terminal preferences. Go to Settings -> Text -> More
# - Change default colours to your liking.
#
# Here are the colours from Textmate's Monokai theme:
#
# Black: 0, 0, 0
# Red: 229, 34, 34
# Green: 166, 227, 45
# Yellow: 252, 149, 30
# Blue: 196, 141, 255
# Magenta: 250, 37, 115
# Cyan: 103, 217, 240
# White: 242, 242, 242

# Thanks to Steve Losh: http://stevelosh.com/blog/2009/03/candy-colored-terminal/

# The prompt

PROMPT='%{$fg[yellow]%}➜ %n@amount.com:%{$fg_bold[blue]%}%6~
%{$fg[magenta]%}%# %{$reset_color%}'

# The right-hand prompt

RPROMPT='$(drench_git_prompt)'

# Add this at the start of RPROMPT to include rvm info showing ruby-version@gemset-name
# %{$fg[yellow]%}$(~/.rvm/bin/rvm-prompt)%{$reset_color%}

# local time, color coded by last return code

raw_git_statuses() {
  (grt && git status --porcelain --ignore-submodules=dirty) |
  cut -c1-3 |
  sort |
  uniq
}

function drench_git_prompt() {
    current_branch=$(git symbolic-ref --short HEAD 2> /dev/null)

    if [ -z "$current_branch" ]; then
      # Probably detached HEAD; try to get the remote branch name
      desc=$(git describe --all --exact-match 2> /dev/null)
      current_branch=${desc#remotes/}
    fi

    test -z "$current_branch" && return

    IFS=$'\n'
    raw_statuses=($(raw_git_statuses))
    for raw_status in $raw_statuses; do
      case "$raw_status" in
        '?? ')
          statuses=($statuses "%{$fg[magenta]%}u%{$reset_color%}")
          ;;
        'A  ')
          statuses=($statuses "%{$fg[cyan]%}+%{$reset_color%}")
          ;;
        'M  ')
          statuses=($statuses "%{$fg[cyan]%}+%{$reset_color%}")
          ;;
        ' M ')
          statuses=($statuses "%{$fg[yellow]%}/")
          ;;
        'AM ')
          statuses=($statuses "%{$fg[yellow]%}/")
          ;;
        ' T ')
          statuses=($statuses "%{$fg[yellow]%}/")
          ;;
        'R  ')
          statuses=($statuses "%{$fg_bold[blue]%}>")
          ;;
        ' D ')
          statuses=($statuses "%{$fg[red]%}X")
          ;;
        'AD ')
          statuses=($statuses "%{$fg[red]%}X")
          ;;
        'UU ')
          statuses=($statuses "%{$fg[red]%}!")
          ;;
      esac
    done

    if [ $#statuses -eq 0 ]; then
      sts=""
    else
      sts=" ${(j::)statuses}"
    fi

    git_dir=$(git rev-parse --git-dir)
    if [ -d "${git_dir}/svn" ]; then
        git_type="git-svn"
    else
        git_type="git"
    fi
    echo "[%{$fg[red]%}$git_type:%{$fg[green]%}${current_branch}$sts%{$reset_color%}]"
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "($COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}|"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "($COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%}|"
            else
                echo "($COLOR${MINUTES}m%{$reset_color%}|"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "($COLOR~|"
        fi
    fi
}

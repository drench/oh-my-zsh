set -e

# Use colors, but only if connected to a terminal, and that terminal
# supports them.
tput=$(which tput)
if [ -n "$tput" ]; then
    ncolors=$($tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi
CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
  printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
  exit
fi
unset CHECK_ZSH_INSTALLED

if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

if [ -d "$ZSH" ]; then
  printf "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
  printf "You'll need to remove $ZSH if you want to re-install.\n"
  exit
fi

echo "\033[0;34mCloning Oh My Zsh...\033[0m"
hash git >/dev/null 2>&1 || {
  echo "Error: git is not installed"
  exit 1
}
# The Windows (MSYS) Git is not compatible with normal use on cygwin
if [ "$OSTYPE" = cygwin ]; then
  if git --version | grep msysgit > /dev/null; then
    echo "Error: Windows/MSYS Git is not supported on Cygwin"
    echo "Error: Make sure the Cygwin git package is installed and is first on the path"
    exit 1
  fi
fi
env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
  echo "Error: git clone of oh-my-zsh repo failed"
  exit 1
}

printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
  printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
  mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
fi

printf "${BLUE}Using the Oh My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
cp $ZSH/templates/zshrc.zsh-template ~/.zshrc
sed "/^export ZSH=/ c\\
export ZSH=$ZSH
" ~/.zshrc > ~/.zshrc-omztemp
mv -f ~/.zshrc-omztemp ~/.zshrc

printf "${BLUE}Copying your current PATH and adding it to the end of ~/.zshrc for you.${NORMAL}\n"
sed "/export PATH=/ c\\
export PATH=\"$PATH\"
" ~/.zshrc > ~/.zshrc-omztemp
mv -f ~/.zshrc-omztemp ~/.zshrc

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  if hash chsh >/dev/null 2>&1; then
    echo "\033[0;34mTime to change your default shell to zsh!\033[0m"
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
  else
    echo "I can't change your shell automatically because this system does not have chsh."
    echo "Please edit /etc/passwd to set your default shell to zsh."
  fi
fi

printf "${GREEN}"
echo '         __                                     __   '
echo '  ____  / /_     ____ ___  __  __   ____  _____/ /_  '
echo ' / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ '
echo '/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / '
echo '\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  '
echo '                        /____/                       ....is now installed!'
echo ''
echo ''
echo 'Please look over the ~/.zshrc file to select plugins, themes, and options.'
echo ''
echo 'p.s. Follow us at https://twitter.com/ohmyzsh.'
echo ''
echo 'p.p.s. Get stickers and t-shirts at http://shop.planetargon.com.'
echo ''
printf "${NORMAL}"
env zsh

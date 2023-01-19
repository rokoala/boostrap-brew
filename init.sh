#!/bin/bash

if [ ! $(which brew) ]; then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo "Updating brew..."
brew update

echo "Installing dependencies..."
brew bundle

FISH=/opt/homebrew/bin/fish
if grep -q "fish" /etc/shells; then 
	echo "Default fish shell already configured."
else
	echo "Setting fish as main shell, please provide your password:"
	sudo sh -c 'echo $0 >> /etc/shells' $FISH
	chsh -s $FISH
	$FISH -c fish_add_path /opt/homebrew/bin
fi

if ! $FISH -c fisher -v > /dev/null; then
	echo "Installing fisher plugin manager"
	fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
else
	echo "Fisher already installed"
fi

DOTFILES=$HOME/ghq/github.com/rokoala/dotfiles
echo "Configuring dotfiles..."
if [ ! -d $DOTFILES ]; then
	ghq get https://github.com/rokoala/dotfiles.git
fi

if [ ! -e $HOME/.tmux.conf ]; then
	ln -s $DOTFILES/tmux.conf $HOME/.tmux.conf
fi
if [ ! -e $HOME/.tmux.powerline.conf ]; then
	ln -s $DOTFILES/tmux.powerline.conf $HOME/.tmux.powerline.conf
fi

echo "Installing powerline fonts..."
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts

echo "Installing commitizen..."
npm install -g commitizen
npm install -g cz-conventional-changelog
echo '{ "path": "cz-conventional-changelog" }' > ~/.czrc

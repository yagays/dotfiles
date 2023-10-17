
brew_install:
	$(PWD)/brew/setup.sh

brew_cui:
	brew bundle --verbose --no-lock --file=$(PWD)/brew/config.d/Brewfile

brew_gui:
	brew bundle --verbose --no-lock --file=$(PWD)/brew/config.d/Brewfile.gui


brew_install:
	bash $(PWD)/brew/setup.sh

brew_cui:
	brew bundle --verbose --no-lock --file=$(PWD)/brew/Brewfile

brew_gui:
	brew bundle --verbose --no-lock --file=$(PWD)/brew/Brewfile.gui

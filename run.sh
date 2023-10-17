ln -s `pwd`/.zshrc $HOME/.zshrc
ln -s `pwd`/.emacs $HOME/.emacs
ln -s `pwd`/.tmux.conf $HOME/.tmux.conf
ln -s `pwd`/.tigrc $HOME/.tigrc
ln -s `pwd`/git/.gitconfig $HOME/.gitconfig

mkdir -p $HOME/.config/git/
ln -s `pwd`/git/ignore $HOME/.config/git/ignore
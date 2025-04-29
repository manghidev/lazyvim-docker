FROM node:22.15.0-alpine

#* Set metadata for image
MAINTAINER ManghiDev <https://manghi.dev>
LABEL description="Dockerfile for LazyVim and Zsh with Oh My Zsh" \
    version="0.1.0"

#* Install necessary dependencies
RUN apk add --no-cache git lazygit fzf curl neovim ripgrep alpine-sdk zsh

#* Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

#* Clone LazyVim
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim

#* Remove the .git folder, so you can add it to your own repo later
RUN rm -rf ~/.config/nvim/.git

#* Install the zsh-autosuggestions plugin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /root/.zshrc

#* Install the Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /root/.zshrc

#* Set the default working directory
WORKDIR /home/develop

CMD ["/bin/zsh"]
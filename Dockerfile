#* Set the base image to Node.js LTS on Alpine
FROM node:lts-alpine

#* Set metadata for image
LABEL maintainer="ManghiDev <https://manghi.dev>" \
    description="Dockerfile for LazyVim and Zsh with oh-my-zsh" \
    version="1.0.0"

#* Install necessary dependencies
RUN apk add --no-cache git lazygit fzf curl neovim ripgrep alpine-sdk zsh shadow

#* Create a new user 'developer' with home directory and grant sudo privileges
RUN useradd -m -s /bin/zsh developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#* Switch to the 'developer' user for the rest of the setup
USER developer
WORKDIR /home/developer

#* Install Oh My Zsh for the 'developer' user
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

#* Install the zsh-autosuggestions plugin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions /home/developer/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions)/' /home/developer/.zshrc

#* Install the Powerlevel10k theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/developer/.oh-my-zsh/custom/themes/powerlevel10k && \
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' /home/developer/.zshrc

#* Clone LazyVim for the 'developer' user
RUN git clone https://github.com/LazyVim/starter /home/developer/.config/nvim

#* Remove the .git folder, so you can add it to your own repo later
RUN rm -rf /home/developer/.config/nvim/.git

#* Ensure proper permissions for the 'developer' user
RUN chown -R developer:developer /home/developer

#* Set the default working directory
WORKDIR /home/developer

#* Set the default shell to Zsh
CMD ["/bin/zsh"]
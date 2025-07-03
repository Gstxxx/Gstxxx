#!/bin/bash

set -e

echo "🔧 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Zsh e dependências..."
sudo apt install -y zsh curl git ruby-full npm fonts-firacode cmatrix

echo "📌 Definindo Zsh como shell padrão..."
chsh -s $(which zsh)

echo "💡 Instalando Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "🎨 Instalando PowerLevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

echo "🎨 Ativando tema PowerLevel10k..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "🔌 Instalando plugins básicos..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

echo "🔌 Instalando plugins adicionais..."
git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search.git $ZSH_CUSTOM/plugins/zsh-history-substring-search
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $ZSH_CUSTOM/plugins/fast-syntax-highlighting
git clone https://github.com/jeffreytse/zsh-vi-mode.git $ZSH_CUSTOM/plugins/zsh-vi-mode
git clone https://github.com/Aloxaf/fzf-tab.git $ZSH_CUSTOM/plugins/fzf-tab

echo "🔧 Ativando todos os plugins no ~/.zshrc..."
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search you-should-use fast-syntax-highlighting zsh-vi-mode fzf-tab)/' ~/.zshrc

echo "🟪 Instalando colorls..."
sudo gem install colorls || echo "⚠️ colorls pode exigir Ruby dev tools."

echo "📦 Instalando exa..."
sudo apt install -y exa || echo "⚠️ Falha ao instalar exa com apt."

echo "🔐 Instalando Secman..."
npm install -g secman || curl -fsSL https://cli.secman.dev | bash

echo "🔁 Instalando tran..."
curl -sL https://cutt.ly/tran-cli | bash

echo "📁 Adicionando aliases para ls..."
echo '
# Aliases para colorls ou exa
if [ -x "$(command -v colorls)" ]; then
    alias ls="colorls"
    alias la="colorls -al"
elif [ -x "$(command -v exa)" ]; then
    alias ls="exa"
    alias la="exa --long --all --group"
fi
' >> ~/.zshrc

echo "🌌 Adicionando efeito Matrix com cmatrix ao abrir o terminal..."
echo '
# Efeito Matrix ao iniciar terminal
if command -v cmatrix &>/dev/null; then
  cmatrix -u 5 -b &
  sleep 2 && kill $! &>/dev/null
fi
' >> ~/.zshrc

echo "✅ Finalizando..."
source ~/.zshrc

echo -e "\n🎉 Terminal personalizado com sucesso! Digite \033[1mp10k configure\033[0m para finalizar a personalização do PowerLevel10k."

#!/bin/bash

set -e  # Para parar o script em caso de erro

echo "🔧 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando Zsh..."
sudo apt install -y zsh curl git ruby-full npm fonts-firacode

echo "📌 Definindo Zsh como shell padrão..."
chsh -s $(which zsh)

echo "💡 Instalando Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🎨 Instalando PowerLevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

echo "🎨 Ativando tema PowerLevel10k no ~/.zshrc..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "✨ Instalando plugins zsh-syntax-highlighting e zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

echo "🔌 Ativando plugins no ~/.zshrc..."
sed -i 's/^plugins=.*/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

echo "🟪 Instalando colorls (exige Ruby)..."
sudo gem install colorls || echo "⚠️ colorls pode exigir Ruby dev tools."

echo "📦 Instalando exa (ls moderno)..."
sudo apt install -y exa || echo "⚠️ Falha ao instalar exa com apt. Tente usar Homebrew ou build manual."

echo "🔐 Instalando Secman (gerenciador de segredos)..."
npm install -g secman || curl -fsSL https://cli.secman.dev | bash

echo "🔁 Instalando tran (file transfer)..."
curl -sL https://cutt.ly/tran-cli | bash

echo "📁 Criando aliases para colorls ou exa..."
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

echo "✅ Aplicando configurações..."
source ~/.zshrc

echo "🎉 Pronto! Agora abra um novo terminal e execute: p10k configure"

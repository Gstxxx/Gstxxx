#!/bin/bash

set -e

echo "🔧 Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "📦 Instalando dependências básicas..."
sudo apt install -y curl git zsh ruby-full npm fonts-firacode cmatrix

echo "📌 Definindo Zsh como shell padrão (se necessário)..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
fi

# Instalação do Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "💡 Instalando Oh My Zsh..."
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "⚠️ Oh My Zsh já está instalado. Pulando instalação."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# PowerLevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "🎨 Instalando PowerLevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "⚠️ PowerLevel10k já está instalado. Pulando..."
fi

# Atualiza tema no .zshrc
if ! grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc; then
    echo "🎨 Ativando tema PowerLevel10k..."
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Plugins
declare -A plugins_git=(
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
    [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
    [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
    [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
    [zsh-vi-mode]="https://github.com/jeffreytse/zsh-vi-mode.git"
    [fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
)

echo "🔌 Instalando plugins..."
for plugin in "${!plugins_git[@]}"; do
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
        echo "➕ Instalando $plugin..."
        git clone "${plugins_git[$plugin]}" "$ZSH_CUSTOM/plugins/$plugin"
    else
        echo "✅ Plugin $plugin já instalado."
    fi
done

# Ativa plugins no .zshrc
desired_plugins="git zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-history-substring-search you-should-use fast-syntax-highlighting zsh-vi-mode fzf-tab"
if ! grep -q "plugins=($desired_plugins)" ~/.zshrc; then
    echo "⚙️ Atualizando lista de plugins no .zshrc..."
    sed -i "s/^plugins=.*/plugins=($desired_plugins)/" ~/.zshrc
fi

# colorls
if ! command -v colorls &>/dev/null; then
    echo "🌈 Instalando colorls..."
    sudo gem install colorls
else
    echo "✅ colorls já está instalado."
fi

# exa
if ! command -v exa &>/dev/null; then
    echo "📦 Instalando exa..."
    sudo apt install -y exa
else
    echo "✅ exa já está instalado."
fi

# secman
if ! command -v secman &>/dev/null; then
    echo "🔐 Instalando Secman..."
    npm install -g secman || curl -fsSL https://cli.secman.dev | bash
else
    echo "✅ Secman já está instalado."
fi

# tran
if ! command -v tran &>/dev/null; then
    echo "🔁 Instalando tran..."
    curl -sL https://cutt.ly/tran-cli | bash
else
    echo "✅ tran já está instalado."
fi

# Adiciona aliases de ls
if ! grep -q 'alias ls=' ~/.zshrc; then
    echo "📁 Adicionando aliases para colorls ou exa..."
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
fi

# Adiciona cmatrix
if ! grep -q 'cmatrix -u 5 -b' ~/.zshrc; then
    echo "🌌 Adicionando efeito Matrix com cmatrix ao iniciar terminal..."
    echo '
# Efeito Matrix ao iniciar terminal
if command -v cmatrix &>/dev/null; then
  cmatrix -u 5 -b &
  sleep 2 && kill $! &>/dev/null
fi
' >> ~/.zshrc
fi

echo "✅ Finalizando..."
source ~/.zshrc

echo -e "\n🎉 Terminal personalizado com sucesso! Digite \033[1mp10k configure\033[0m para finalizar a personalização do PowerLevel10k."

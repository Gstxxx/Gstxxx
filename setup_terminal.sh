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

# eza (substituto do exa)
if ! command -v eza &>/dev/null; then
    echo "📦 Instalando eza (substituto do exa)..."
    sudo apt install -y eza || echo "⚠️ Falha ao instalar eza"
else
    echo "✅ eza já está instalado."
fi

# secman
if ! command -v secman &>/dev/null; then
    echo "🔐 Instalando Secman..."
    if ! npm install -g secman; then
        echo "⚠️ Falha no npm (permissão ou versão Node). Tentando via script..."
        if curl -fsSL https://cli.secman.dev | bash; then
            echo "✅ Secman instalado via script."
        else
            echo "❌ Falha na instalação do Secman via script. Verifique sua conexão DNS ou permissões."
        fi
    fi
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
    echo "📁 Adicionando aliases para colorls ou eza..."
    echo '
# Aliases para colorls ou eza
if [ -x "$(command -v colorls)" ]; then
    alias ls="colorls"
    alias la="colorls -al"
elif [ -x "$(command -v eza)" ]; then
    alias ls="eza"
    alias la="eza --long --all --group"
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

# Só roda source ~/.zshrc se estiver no zsh
if [ "$SHELL" = "$(which zsh)" ]; then
    echo "♻️ Recarregando ~/.zshrc"
    source ~/.zshrc
else
    echo "⚠️ Para aplicar as mudanças, abra um novo terminal com Zsh (execute 'zsh' ou reinicie seu terminal)."
fi

echo -e "\n🎉 Terminal personalizado com sucesso! Digite \033[1mp10k configure\033[0m para finalizar a configuração do PowerLevel10k."

#!/bin/bash

set -e

echo "Baixando e instalando o PSEARCH..."
mkdir -p $HOME/.psearch
curl -sSL https://raw.githubusercontent.com/GlitchBruxo/Psearch/main/psearch.sh -o $HOME/.psearch/psearch.sh
chmod +x $HOME/.psearch/psearch.sh

# Detectar shell
if [ -n "$ZSH_VERSION" ]; then
    SHELLRC="$HOME/.zshrc"
else
    SHELLRC="$HOME/.bashrc"
fi

# Adicionar alias se não existir
if ! grep -q "alias psearch=" "$SHELLRC"; then
    echo 'alias psearch="$HOME/.psearch/psearch.sh"' >> "$SHELLRC"
    echo "[OK] Alias 'psearch' adicionado ao $SHELLRC"
fi

echo "Reinicie o Termux ou rode: source $SHELLRC"
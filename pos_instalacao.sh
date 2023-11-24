#!/bin/bash

# Função para obter o ID da chave GPG
get_gpg_key_id() {
    local gpg_key_id
    gpg_key_id=$(gpg --list-secret-keys --keyid-format=long | awk '/^sec/{print $2}' | cut -d'/' -f2)
    echo "$gpg_key_id"
}

# Atualiza o sistema
sudo apt update
sudo apt upgrade -y

# Instala programas essenciais
sudo apt install -y \
    openssh-server \
    vim \
    htop \
    curl \
    wget \
    git \
    zsh \

# Instala latex e dependências
sudo apt install -y
    latexmk \
    chktex \
    texlive-latex-extra \
    texlive-publishers \
    texlive-science \
    texlive-lang-portuguese \
    texlive-fonts-recommended \
    texlive-extra-utils

# Instala o Hyper
wget https://releases.hyper.is/download/deb -O hyper.deb
sudo dpkg -i hyper.deb
sudo apt install -f -y
rm hyper.deb

# Instala o Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
sudo dpkg -i chrome.deb
sudo apt install -f -y
rm chrome.deb

# Instala o Visual Studio Code
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -O vscode.deb
sudo dpkg -i vscode.deb
sudo apt install -f -y
rm vscode.deb

# Configura o firewall (UFW) para permitir SSH
sudo ufw allow OpenSSH
sudo ufw enable

# Adiciona seu usuário ao grupo sudo
sudo usermod -aG sudo seu_usuario

# Cria a chave SSH Ed25519 sem interação
echo "Criando chave SSH..."
ssh-keygen -t ed25519 -C "mauriciosm95@gmail.com" -N ""

# Adiciona a chave SSH ao agente SSH
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copia a chave pública do SSH para um arquivo
mkdir -p ~/.ssh
cat ~/.ssh/id_ed25519.pub > ssh_public_key.pub

# Passos para criar a chave GPG
echo "Criando genkey file para a chave GPG..."
cat <<EOF > genkey
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Name-Real: <$NAME>
Name-Email: <$EMAIL>
Expire-Date: 0
Passphrase: <$PASSPHRASE>
EOF

echo "Gerando a chave GPG..."
gpg --gen-key --batch genkey

echo "Obtendo o ID da chave GPG..."
gpg_key_id=$(get_gpg_key_id)

echo "Exportando a chave pública GPG..."
gpg --armor --export "$gpg_key_id" > gpg_public_key

echo "Destruindo o genkey..."
shred -u genkey

echo "Copiando as chaves para a pasta 'minhasChaves'" 
# Cria a pasta minhasChaves e move os arquivos SSH e GPG
mkdir -p minhasChaves
cp ~/.ssh/id_ed25519 minhasChaves/
cp ssh_public_key.pub minhasChaves/
mv gpg_public_key minhasChaves/

# Baixa a fonte JetBrains Mono
wget https://download-cdn.jetbrains.com/fonts/JetBrainsMono-2.304.zip -O JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.fonts
fc-cache -f -v
rm JetBrainsMono.zip

# Limpa pacotes não utilizados
sudo apt autoremove -y
sudo apt clean

# Reinicia o sistema
sudo reboot

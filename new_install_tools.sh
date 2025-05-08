#!/bin/bash

set -e  # Interrompe em caso de erro
set -o pipefail

echo "[*] Atualizando sistema e instalando pré-requisitos..."
apt update && apt upgrade -y
apt install -y git wget curl unzip jq python3-pip libpcap-dev tmux make gcc

echo "[*] Instalando Golang..."
cd /tmp
GO_VERSION="1.24.3"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

mkdir -p ~/tools && cd ~/tools

echo "[*] Instalando MassDNS..."
git clone https://github.com/blechschmidt/massdns.git
cd massdns && make && make install && cd ..

echo "[*] Instalando ferramentas Go..."
tools=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/projectdiscovery/notify/cmd/notify@latest"
    "github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/katana/cmd/katana@latest"
    "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    "github.com/projectdiscovery/alterx/cmd/alterx@latest"
    "github.com/d3mondev/puredns/v2@latest"
    "github.com/tomnomnom/gf@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/hakluke/hakrawler@latest"
    "github.com/hakluke/hakrevdns@latest"
    "github.com/ffuf/ffuf/v2@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/deletescape/goop@latest"
    "github.com/owasp-amass/amass/v4/...@master"
    "github.com/j3ssie/sdlookup@latest"
    "github.com/OJ/gobuster/v3@latest"
    "github.com/Sybil-Scan/revwhoix@latest"
    "github.com/imusabkhan/prips@latest"
    "github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest"
)

for tool in "${tools[@]}"; do
    echo "[*] Instalando: $tool"
    go install "$tool"
done

echo "[*] Configurando GF (tomnomnom)..."
mkdir -p ~/.gf
cp -r ~/go/src/github.com/tomnomnom/gf/examples/* ~/.gf 2>/dev/null || true
git clone https://github.com/1ndianl33t/Gf-Patterns.git
mv Gf-Patterns/*.json ~/.gf

echo "[*] Clonando outras ferramentas (sqlmap, dirsearch)..."
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git ~/tools/sqlmap-dev
git clone --depth 1 https://github.com/maurosoria/dirsearch.git ~/tools/dirsearch

# Corrigir PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
source ~/.bashrc

echo " Instalação concluída!"
echo " Configure as APIs do Subfinder, Notify"
echo " crt.sh no meu git"

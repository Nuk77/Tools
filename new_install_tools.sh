#!/bin/bash

ask_continue() {
  read -p "Deseja continuar? [S/n] " answer
  answer=${answer,,}
  if [[ "$answer" == "n" || "$answer" == "nao" ]]; then
    echo "Abortado pelo usuário."
    exit 1
  fi
}

cd ~
echo "Baixando e instalando pré-requisitos..."
sudo apt-get update && sudo apt-get upgrade -y
apt install golang-go -y
mkdir -p ~/tools
cd ~/tools
sudo apt install -y git libpcap-dev jq python3-pip
ask_continue

echo "Instalando MassDNS..."
git clone https://github.com/blechschmidt/massdns.git
cd massdns && make && sudo make install
cd ~/tools
ask_continue

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
  "github.com/Sybil-Scan/revwhoix"
  "github.com/imusabkhan/prips@latest"
  "github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest"
)

echo "Instalando ferramentas com Go..."
for tool in "${tools[@]}"; do
  echo "🔹 Instalando $tool"
  go install "$tool"

  if [[ "$tool" == *"tomnomnom/gf"* ]]; then
    echo "Configurando GF..."
    mkdir -p ~/.gf
    cp -r "$(go env GOPATH)/src/github.com/tomnomnom/gf/examples" ~/.gf 2>/dev/null
    git clone https://github.com/1ndianl33t/Gf-Patterns
    cp Gf-Patterns/*.json ~/.gf
    rm -rf Gf-Patterns
  fi

  if [[ "$tool" == *"ffuf/ffuf"* ]]; then
    echo "Recompilando ffuf..."
    cd "$(go env GOPATH)/src/github.com/ffuf/ffuf" || continue
    go get && go build
    cd -
  fi

  if [[ "$tool" == *"Sybil-Scan/revwhoix"* ]]; then
    echo "Instalando revwhoix..."
    cd "$(go env GOPATH)/src/github.com/Sybil-Scan/revwhoix" || continue
    pip install .
    cd -
  fi
done
ask_continue

cd ~/tools
echo "Clonando SQLMap e Dirsearch..."
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
git clone https://github.com/maurosoria/dirsearch.git --depth 1
ask_continue

echo "Movendo binários para /usr/bin..."
sudo mv /root/go/bin/* /usr/bin
sudo mv ~/massdns ~/tools
ask_continue

echo "Instalando tmux..."
sudo apt install -y tmux
ask_continue

echo " Instalação concluída com sucesso!"
echo " Configure Notify, APIs do Subfinder"

#!/bin/bash

echo "Golang ja instalado??" && sleep 6
# Instalar Pre-requisitos
echo "Baixando e instalando pre-requisitos..." && sleep 2
apt-get update
apt-get upgrade -y
source /root/.bashrc
apt install git -y
apt install -y libpcap-dev
git clone https://github.com/blechschmidt/massdns.git
cd massdns
make
make install
apt-get -y install python3-pip



# Lista de ferramentas com links
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
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/tomnomnom/httprobe@latest"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/tomnomnom/qsreplace@latest"
    "github.com/tomnomnom/meg@latest"
    "github.com/tomnomnom/gf@latest"
    "github.com/ffuf/ffuf@latest"
    "github.com/tomnomnom/anew@latest"
    "github.com/hakluke/hakrawler@latest"
    "github.com/hakluke/hakrevdns@latest"
    "github.com/hahwul/dalfox/v2@latest"
    "github.com/projectdiscovery/katana/cmd/katana@latest"
    "github.com/ferreiraklet/airixss@latest"
    "github.com/ffuf/ffuf/v2@latest"
    "github.com/takshal/freq@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/deletescape/goop@latest"
    "github.com/003random/getJS@latest"
    "github.com/Emoe/kxss@latest"
    "github.com/j3ssie/metabigor@latest"
    "github.com/owasp-amass/amass/v4/...@master"
    "github.com/j3ssie/sdlookup@latest"
    "github.com/OJ/gobuster/v3@latest"
)

# Loop para instalar as ferramentas
for tool in "${tools[@]}"; do
    echo "A instalar $tool"
    go install "$tool"

    # Comandos adicionais para as ferramentas após a instalação
    if [[ "$tool" == *"github.com/tomnomnom/gf@latest"* ]]; then
        echo "A executar comandos adicionais para GF..." && sleep 2
        echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
        source ~/.bashrc
        mkdir .gf
        cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf
        git clone https://github.com/1ndianl33t/Gf-Patterns
        mv ~/Gf-Patterns/*.json ~/.gf
    fi
done

# Instalação de outras ferramentas com comandos específicos
echo "Instalando outras ferramentas..." && sleep 2
# Comandos para clonar repositórios
cd
mkdir tools
cd tools
git clone https://github.com/maurosoria/dirsearch.git --depth 1
go install github.com/jaeles-project/gospider@latest
go install github.com/lc/subjs@latest
git clone https://github.com/findomain/findomain.git | cd findomain | apt install cargo -y | cargo build --release | sudo cp target/release/findomain /usr/bin/
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
git clone https://github.com/devanshbatham/ParamSpider
cd ParamSpider
pip install .
cd ..
git clone --recursive https://github.com/screetsec/Sudomy.git
cd Sudomy
pip3 install -r requirements.txt
export PATH=$PATH:/usr/local/go/bin
source /root/.bashrc
cd /root/go/bin
mv /root/go/bin/* /usr/bin
cd /root/
mv /root/massdns /root/tools
cd
apt install tmux
echo "Instalação concluída! Não esquecer de configurar Notify, Subfinder(API), Sudomy(API)"







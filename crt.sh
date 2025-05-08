#!/bin/bash

# Função para buscar subdomínios
fetch_subdomains() {
    local DOMAIN=$1
    curl -s "https://crt.sh/?q=%25.${DOMAIN}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g'
}

# Verificar os argumentos passados
if [[ $1 == "-d" && -n $2 ]]; then
    # Consulta um único domínio
    fetch_subdomains "$2"

elif [[ $1 == "-f" && -n $2 ]]; then
    # Verifica se o arquivo existe
    if [[ ! -f "$2" ]]; then
        echo "Erro: O arquivo '$2' não existe!"
        exit 1
    fi
    
    # Lê cada linha do arquivo e executa a função
    while IFS= read -r domain; do
        fetch_subdomains "$domain"
    done < "$2"

else
    echo "Uso:"
    echo "  Para um único domínio: crt.sh -d <domínio>"
    echo "  Para uma lista de domínios: crt.sh -f <arquivo>"
    echo "Exemplo:"
    echo "  crt.sh -d example.com"
    echo "  crt.sh -f lista_de_dominios.txt"
    exit 1
fi
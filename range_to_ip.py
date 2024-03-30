import ipaddress
import sys

def list_ips_in_range(ip_range):
    try:
        network = ipaddress.ip_network(ip_range)
        for ip in network:
            print(ip)
    except ValueError:
        print(f"Erro: {ip_range} não é um range de IP válido.")

def main():
    # Verifica se há argumentos de linha de comando
    if len(sys.argv) == 1:
        print("Uso: python ip_range_tool.py [arquivo]")
        print("Exemplo: python ip_range_tool.py lista_ranges.txt")
        sys.exit(1)

    # Lê o nome do arquivo da linha de comando
    filename = sys.argv[1]

    # Tenta abrir o arquivo
    try:
        with open(filename, 'r') as file:
            # Processa cada linha do arquivo
            for line in file:
                ip_range = line.strip()
                list_ips_in_range(ip_range)
    except FileNotFoundError:
        print(f"Erro: Arquivo '{filename}' não encontrado.")
        sys.exit(1)

if __name__ == "__main__":
    main()

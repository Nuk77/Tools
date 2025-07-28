#!/bin/bash

# Script profissional para análise de arquivos JavaScript sensíveis
# Autor: Pentester
# Versão: 1.1

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Funções de output
print_banner() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${BLUE}    Análise Profissional de JS Sensíveis     ${NC}"
    echo -e "${BLUE}==============================================${NC}"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_section() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Verificar dependências
check_dependencies() {
    print_info "Verificando dependências..."
    
    if ! command -v curl &> /dev/null; then
        print_critical "curl não encontrado. Por favor instale curl."
        exit 1
    fi
    
    # Usar arquivo passado como argumento ou js_validos.txt por padrão
    LOCAL_INPUT_FILE="${1:-js_validos.txt}"
    
    if [ ! -f "$LOCAL_INPUT_FILE" ]; then
        print_critical "Arquivo $LOCAL_INPUT_FILE não encontrado."
        print_info "Uso: $0 [arquivo_js.txt]"
        print_info "Se nenhum arquivo for especificado, usa 'js_validos.txt' por padrão."
        exit 1
    fi
    
    print_success "Todas as dependências OK"
}

# Expressões regulares para diferentes tipos de secrets
setup_patterns() {
    # Credenciais e autenticação genéricas
    CRED_PATTERN="(aws_access|aws.secret|api[key_]|secret[key_]|access[key_]|token|password|passwd|pwd|auth|authorization|bearer|jwt|oauth|credential|login|username|admin|root|superuser|private.key|public.key|x-api-key|x.auth.token)"
    
    # Chaves e IDs específicos
    AWS_KEY_PATTERN="AKIA[0-9A-Z]{16}"
    GOOGLE_API_PATTERN="AIza[0-9A-Za-z_-]{33}"
    GOOGLE_OAUTH_PATTERN="ya29\.[0-9A-Za-z_-]+"
    FACEBOOK_TOKEN_PATTERN="EAACEdEose0cBA[0-9A-Za-z]+"
    GITHUB_TOKEN_PATTERN="ghp_[0-9a-zA-Z]{36}|github_pat_[0-9a-zA-Z_]{82}|gho_[0-9a-zA-Z]{36}|ghu_[0-9a-zA-Z]{36}|ghs_[0-9a-zA-Z]{36}"
    HEROKU_API_PATTERN="[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
    SLACK_TOKEN_PATTERN="xox[baprs]-[0-9a-zA-Z]{10,48}"
    TWILIO_SID_PATTERN="AC[0-9a-f]{32}"
    TWILIO_TOKEN_PATTERN="[0-9a-f]{32}"
    STRIPE_PUBLISHABLE_PATTERN="pk_(live|test)_[0-9a-zA-Z]{24}"
    STRIPE_SECRET_PATTERN="sk_(live|test)_[0-9a-zA-Z]{24}"
    
    # Serviços em nuvem
    CLOUD_SERVICES_PATTERN="(aws|amazon|azure|google.*api|gcp|firebase|heroku|digitalocean|cloudflare|cloudfront|s3[bucket]|ec2|lambda|gcloud|gcm|fcm|gke|ecs|eks|route53|cloudwatch|cloudtrail|config|guardduty|macie|inspector|securityhub|artifact|marketplace|workspaces|appstream|lightsail|batch|stepfunctions|glue|datapipeline|kms|cloudhsm|acm|waf|shield|vpn|directconnect|dx|openshift|kubernetes|docker|container|openshift|openshift-origin|openshift-container-platform)"
    
    # Bancos de dados e conexões
    DB_PATTERN="(database|db[_.]|mysql|postgres|postgresql|mongodb|redis|memcache|connection|conn|string|jdbc|odbc|dsn|server|host|port|username|user|pass|password|uri|url|sqlite|oracle|sqlserver|mssql)"
    
    # Ambientes e debugging
    DEBUG_PATTERN="(debug|development|staging|test|local|dev|stage|sandbox|internal|private|secret|hidden|backup|old|temp|tmp|console.log|console.debug|console.info|console.warn|console.error|__dirname|__filename|process.env.NODE_ENV)"
    
    # URLs e endpoints sensíveis
    SENSITIVE_URLS_PATTERN="(admin|dashboard|portal|api|internal|private|secret|config|settings|setup|install|debug|test|dev|staging|backup|old|tmp|temp|upload|download|manager|control|panel)"
    
    # Criptografia e segurança
    CRYPTO_PATTERN="(rsa|dsa|ecdsa|ed25519|aes|des|3des|blowfish|twofish|serpent|camellia|chacha20|poly1305|sha256|sha512|hmac|pbkdf2|scrypt|bcrypt|argon2|jwt|jwk|pem|crt|key|cert|certificate|private|public|secret|BEGIN.*PRIVATE|BEGIN.*CERTIFICATE)"
}

# Função para extrair contexto ao redor de um match
extract_context() {
    local content="$1"
    local pattern="$2"
    local lines_before=2
    local lines_after=2
    
    echo "$content" | grep -n -i -A $lines_after -B $lines_before -E "$pattern" | head -10
}

# Função principal de análise
analyze_js_file() {
    local js_url="$1"
    local content="$2"
    local findings=0
    
    # 1. Credenciais genéricas
    if echo "$content" | grep -iqE "$CRED_PATTERN"; then
        print_section "$js_url"
        print_critical "🔐 CREDENCIAL GENÉRICA ENCONTRADA"
        extract_context "$content" "$CRED_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 2. Chaves específicas da AWS
    if echo "$content" | grep -qE "$AWS_KEY_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_critical "🔑 CHAVE AWS ENCONTRADA"
        extract_context "$content" "$AWS_KEY_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 3. Google API Keys
    if echo "$content" | grep -qE "$GOOGLE_API_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_critical "🔑 GOOGLE API KEY ENCONTRADA"
        extract_context "$content" "$GOOGLE_API_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 4. GitHub Tokens
    if echo "$content" | grep -qE "$GITHUB_TOKEN_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_critical "🔑 GITHUB TOKEN ENCONTRADO"
        extract_context "$content" "$GITHUB_TOKEN_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 5. Stripe Keys
    if echo "$content" | grep -qE "$STRIPE_SECRET_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_critical "💳 STRIPE SECRET KEY ENCONTRADA"
        extract_context "$content" "$STRIPE_SECRET_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 6. Serviços em nuvem
    if echo "$content" | grep -iqE "$CLOUD_SERVICES_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "☁️  REFERÊNCIA A SERVIÇOS EM NUVEM"
        extract_context "$content" "$CLOUD_SERVICES_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 7. Debug/Development info
    if echo "$content" | grep -iqE "$DEBUG_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "🐛 DEBUG/INFO ENCONTRADO"
        extract_context "$content" "$DEBUG_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 8. URLs/endpoints sensíveis
    if echo "$content" | grep -iqE "$SENSITIVE_URLS_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "🔒 URL/ENDPOINT SENSÍVEL ENCONTRADO"
        extract_context "$content" "$SENSITIVE_URLS_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 9. Informações de banco de dados
    if echo "$content" | grep -iqE "$DB_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "🗄️  REFERÊNCIA A BANCO DE DADOS"
        extract_context "$content" "$DB_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 10. Informações criptográficas
    if echo "$content" | grep -iqE "$CRYPTO_PATTERN"; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "🔒 INFORMAÇÃO CRIPTOGRÁFICA ENCONTRADA"
        extract_context "$content" "$CRYPTO_PATTERN"
        findings=$((findings + 1))
        echo ""
    fi
    
    # 11. Verificação de conteúdo suspeito (base64 encoded secrets)
    if echo "$content" | grep -oE "[A-Za-z0-9+/]{40,}" | head -5 | grep -q .; then
        if [ $findings -eq 0 ]; then
            print_section "$js_url"
        fi
        print_warning "🕵️  POSSÍVEL CONTEÚDO ENCODED (base64) ENCONTRADO"
        echo "$content" | grep -oE "[A-Za-z0-9+/]{40,}" | head -3
        findings=$((findings + 1))
        echo ""
    fi
    
    if [ $findings -gt 0 ]; then
        print_success "TOTAL DE FINDINGS: $findings"
        echo -e "${BLUE}----------------------------------------------${NC}"
        echo ""
        return 0  # Indica que houve findings
    else
        return 1  # Indica que não houve findings
    fi
}

# Função para análise resumida (para relatório)
analyze_js_summary() {
    local js_url="$1"
    local content="$2"
    
    # Só adiciona ao resumo se houver findings críticos
    if echo "$content" | grep -iqE "($CRED_PATTERN|$AWS_KEY_PATTERN|$GOOGLE_API_PATTERN|$GITHUB_TOKEN_PATTERN|$STRIPE_SECRET_PATTERN)"; then
        echo "=== $js_url ===" >> findings_resumo.txt
        
        # Contar diferentes tipos de findings
        local creds=$(echo "$content" | grep -iE "$CRED_PATTERN" | wc -l)
        local aws_keys=$(echo "$content" | grep -E "$AWS_KEY_PATTERN" | wc -l)
        local google_keys=$(echo "$content" | grep -E "$GOOGLE_API_PATTERN" | wc -l)
        local github_tokens=$(echo "$content" | grep -E "$GITHUB_TOKEN_PATTERN" | wc -l)
        local stripe_keys=$(echo "$content" | grep -E "$STRIPE_SECRET_PATTERN" | wc -l)
        local debug_info=$(echo "$content" | grep -iE "$DEBUG_PATTERN" | wc -l)
        local cloud_refs=$(echo "$content" | grep -iE "$CLOUD_SERVICES_PATTERN" | wc -l)
        
        if [ $creds -gt 0 ] || [ $aws_keys -gt 0 ] || [ $google_keys -gt 0 ] || [ $github_tokens -gt 0 ] || [ $stripe_keys -gt 0 ]; then
            echo "CRITICAL: Credenciais encontradas" >> findings_resumo.txt
        fi
        
        if [ $debug_info -gt 0 ]; then
            echo "WARNING: Debug info encontrada" >> findings_resumo.txt
        fi
        
        if [ $cloud_refs -gt 0 ]; then
            echo "INFO: Referências a cloud encontradas" >> findings_resumo.txt
        fi
        
        echo "" >> findings_resumo.txt
    fi
}

# Função principal
main() {
    print_banner
    INPUT_FILE=$(check_dependencies "$1")
    setup_patterns
    
    # Limpar arquivos de output anteriores
    > findings_detalhados.txt
    > findings_resumo.txt
    > js_sensiveis_encontrados.txt
    
    print_info "Iniciando análise de $(wc -l < "$INPUT_FILE") arquivos JS..."
    echo ""
    
    local total_findings=0
    local files_with_findings=0
    
    # Processar cada arquivo JS
    while read js_url; do
        if [ -n "$js_url" ]; then
            print_info "Analisando: $js_url"
            
            # Tentar baixar o conteúdo
            content=$(curl -s --max-time 30 "$js_url" 2>/dev/null)
            
            if [ -n "$content" ]; then
                # Redirecionar output para arquivo também
                temp_output=$(analyze_js_file "$js_url" "$content" 2>&1)
                
                # Se houve findings, adiciona aos outputs
                if [ $? -eq 0 ]; then
                    # Adicionar ao arquivo detalhado
                    echo "$temp_output" >> findings_detalhados.txt
                    echo "$temp_output"
                    
                    # Adicionar à lista de JS sensíveis
                    echo "$js_url" >> js_sensiveis_encontrados.txt
                    files_with_findings=$((files_with_findings + 1))
                    
                    # Análise resumida
                    analyze_js_summary "$js_url" "$content"
                fi
                
            else
                print_warning "Não foi possível baixar conteúdo de: $js_url"
            fi
        fi
    done < "$INPUT_FILE"
    
    # Relatório final
    echo ""
    print_banner
    print_success "ANÁLISE CONCLUÍDA"
    print_info "Arquivos analisados: $(wc -l < "$INPUT_FILE")"
    print_info "Arquivos com findings críticos: $files_with_findings"
    print_info ""
    print_info "Arquivos de output gerados:"
    print_info "- findings_detalhados.txt (análise completa)"
    print_info "- findings_resumo.txt (resumo)"
    print_info "- js_sensiveis_encontrados.txt (URLs com findings)"
    
    if [ $files_with_findings -gt 0 ]; then
        print_critical "⚠️  ATENÇÃO: Foram encontrados arquivos JS sensíveis!"
        print_info "Verifique os arquivos de output para detalhes."
    else
        print_success "✅ Nenhum finding crítico encontrado."
    fi
}

# Executar script
main "$@"

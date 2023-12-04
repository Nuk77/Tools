#!/bin/bash

# set target
read -p "Digite o domínio-alvo: " target
#
mkdir -p "$target"
#
echo echo "Criar diretorios extras"
echo "1. Continuar"
read menu1

if [[ $menu1 == *"1" ]]; then
   mkdir JS
   mkdir JSON
   mkdir TXT
   mkdir XML
   mkdir PDF
fi
echo "movendo para pasta do alvo"
mv JS JSON TXT XML PDF "$target"
#
echo "directory created" | lolcat
# Enumerating subdomains 
echo "running first enumeration"
subfinder -d "$target" -all -silent | anew "$target/subdomains.txt" | lolcat 
amass enum -d "$target" -silent | anew "$target/subdomains.txt" | lolcat
assetfinder "$target" | anew "$target/subdomains.txt" | lolcat
echo "first enumeration finished"
# premut
echo "premut running"
cat "$target/subdomains.txt" | alterx -enrinch | anew "$target/premut.txt" | lolcat
# validating domains and passing to http
echo "domain validation running"
cat "$target/subdomains.txt" "$target/premut.txt" | httpx | anew "$target/httpx_domains.txt" | lolcat
echo "domain validation finished"
# collecting urls
echo "running url collection"
cat "$target/httpx_domains.txt" | waybackurls | anew "$target/wayback_urls.txt" | lolcat
cat "$target/httpx_domains.txt" | gau | anew  "$target/gau_urls.txt" | lolcat
cat "$target/httpx_domains.txt" | katana | anew "$target/katana.urls.txt" | lolcat
cat "$target/wayback_urls.txt" "$target/gau_urls.txt" "$target/katana.urls.txt" | httpx -silent | anew "$target/final_crawler.txt" | lolcat
echo "finished url collection"
# + urls
echo "JS urls"
cat "$target/final_crawler.txt" | grep .js | anew "$target/JS/js.txt"
cat "$target/final_crawler.txt" | grep .json | anew "$target/JSON/json.txt"
cat "$target/final_crawler.txt" | grep .txt | anew "$target/TXT/text.txt"
cat "$target/final_crawler.txt" | grep .xml | anew "$target/XML/Xml.txt"
cat "$target/final_crawler.txt" | grep .pdf | anew "$target/PDF/pdf.txt"
# Filter only URLs parameters and save to file "parameters.txt"
echo "leaving only parameters"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | anew "$target/param.txt"
cat "$target/param.txt | "
#
echo "Please choose from the following options for nuclei templates:"
echo "1. Cves"
echo "2. Vulnerabilities"
echo "3. Exposed-panels"
echo "4. Exposures"
echo "5. File"
echo "6. Miscellaneous"
echo "7. Misconfiguration"
echo "8. Technologies"
echo "9. Fuzzer"
echo "10. All Templates"
echo "Enter the numbers separated by commas:"
read templates

if [[ $templates == *"1"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/cves/"
fi

if [[ $templates == *"2"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/vulnerabilities/"
fi

if [[ $templates == *"3"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/exposed-panels/"
fi

if [[ $templates == *"4"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/exposures/"
fi

if [[ $templates == *"5"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/file/"
fi

if [[ $templates == *"6"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/miscellaneous/"
fi

if [[ $templates == *"7"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/misconfiguration/"
fi

if [[ $templates == *"8"* ]]; then
  t_args="$t_args -t /root/nuclei-templates/http/technologies/"
fi

if [[ $templates == *"9"* ]]; then
  t_args="$t_args -t /root/fuzzing-templates"
fi

if [[ $templates == *"10"* ]]; then
  t_args="$t_args -t /root/nuclei-templates"
fi

echo "Starting Nuclei scan with the selected templates..."
cat "$target/param.txt" | nuclei -stats -si 100 $t_args -s low,medium,high,critical,unknown -o "$target/nuclei_results_for_$target.txt" | notify

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
echo "directory created"
# Enumerating subdomains 
echo "running first enumeration"
subfinder -d "$target" -all -silent | anew "$target/subdomains.txt"
amass enum -d "$target" -silent | anew "$target/subdomains.txt"
assetfinder "$target" | anew "$target/subdomains.txt"
cat "$target/subdomains.txt" | subfinder -all -silent | anew "$target/reco_reco.txt"
echo "Recon finished"
# premut
echo "premut running"
cat "$target/reco_reco.txt" | alterx -enrinch | anew "$target/premut.txt"
# validating domains and passing to http
echo "domain validation running"
cat "$target/reco_reco.txt" "$target/premut.txt" | httpx -silent | anew "$target/httpx_domains.txt"
echo "domain validation finished"
# collecting urls
echo "running url collection"
cat "$target/httpx_domains.txt" | waybackurls | anew "$target/wayback_urls.txt"
cat "$target/httpx_domains.txt" | gau | anew  "$target/gau_urls.txt"
cat "$target/httpx_domains.txt" | katana -d 2 | anew "$target/katana.urls.txt"
cat "$target/wayback_urls.txt" "$target/gau_urls.txt" "$target/katana.urls.txt" | httpx -silent | anew "$target/final_crawler.txt"
echo "finished url collection"
# + urls
echo "JS TXT PDF urls"
cat "$target/final_crawler.txt" | grep .js | anew "$target/JS/js.txt"
cat "$target/final_crawler.txt" | grep .json | anew "$target/JSON/json.txt"
cat "$target/final_crawler.txt" | grep .txt | anew "$target/TXT/text.txt"
cat "$target/final_crawler.txt" | grep .xml | anew "$target/XML/Xml.txt"
cat "$target/final_crawler.txt" | grep .pdf | anew "$target/PDF/pdf.txt"
# Filter only URLs parameters and save to file "parameters.txt"
echo "leaving only parameters"
# leaving only parameters
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf xss | anew "$target/param_xss.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf idor | anew "$target/param_idor.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf redirect | anew "$target/param_redirect.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf rce | anew "$target/param_rce.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf sqli | anew "$target/param_sqli.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf ssrf | anew "$target/param_ssrf.txt"
cat "$target/final_crawler.txt" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|icon|pdf|svg|txt|js)" | gf lfi | anew "$target/param_lfi.txt"
# Concatenate all parameters into a single file for further processing
cat "$target/param_xss.txt" "$target/param_idor.txt" "$target/param_redirect.txt" "$target/param_lfi.txt" "$target/param_ssrf.txt" "$target/param_sqli.txt" "$target/param_rce.txt" > "$target/all_param.txt"

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
cat "$target/all_param.txt" | nuclei -stats -si 100 $t_args -s low,medium,high,critical,unknown -silent -o "$target/nuclei_results_for_$target.txt" | notify

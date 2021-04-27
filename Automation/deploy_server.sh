#!/bin/sh
function parse_yaml {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

if ! command -v go $> /dev/null
then
  echo "Go not found, install go before continuing"
  exit
elif ! command -v upspin $> /dev/null
then
  echo "Upspin not found, install upspin before continuing"
  exit
elif ! command -v oc $> /dev/null
then
  echo "Openshift command line tool not found, install before continuing"
  exit
elif ! command -v docker $> /dev/null
then
  echo "Docker not found, install or start docker daemon before continuing"
  exit
fi

# store all the yaml params as variables
eval $(parse_yaml params.yaml)

$openshift_login
oc create -f $yaml_file
oc new-app $template_name

sleep 5

curl -X POST "https://api.cloudflare.com/client/v4/zones/6c6c793898e1697f199bc5676c3ddeda/dns_records" -H "Authorization: $bearer_token" -H "Content-Type: application/json" --data '{"type":"'"CNAME"'","name":"'"$cname"'","content":"'"$openshift_host_name"'","ttl":120,"proxied":false}'

# upspin configuration

upsinTXT=$(upspin setupdomain -domain=$cname.$domain | grep -o 'upspin:[a-z0-9-]*')

curl -X POST "https://api.cloudflare.com/client/v4/zones/6c6c793898e1697f199bc5676c3ddeda/dns_records" -H "Authorization: $bearer_token" -H "Content-Type: application/json" --data '{"type":"'"TXT"'","name":"'"$cname"'","content":"'"$upsinTXT"'","ttl":120,"proxied":false}'

echo "authorization takes 130s"

sleep 130


upspin setupserver -domain=$cname.$domain  -$cname.$domain 

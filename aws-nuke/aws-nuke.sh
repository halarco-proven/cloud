
if [[ $# -ne 1 ]]; then
	echo "Invalid number of arguments. Expected only account id as first argument"	
	exit 1
fi

if [[ ! -x ./bin/aws-nuke ]]; then
	# Install aws-nuke here
	echo "[INFO] aws-nuke executable not found."
	echo "[INFO] Downloading aws-nuke"
	mkdir -p bin/
	wget --quiet https://github.com/ekristen/aws-nuke/releases/download/v3.60.0/aws-nuke-v3.60.0-linux-amd64.tar.gz -O aws-nuke.tar.gz
	echo "[INFO] Installing aws-nuke"
	tar xf aws-nuke.tar.gz -C bin/
	rm aws-nuke.tar.gz
	echo "[INFO] Successfully installed aws-nuke"
fi

if [[ ! -e ./nuke-config.yml ]]; then
    echo "[INFO] Downloading basic aws-nuke configuration file."
    wget --quiet https://gist.githubusercontent.com/halarco-proven/34c34f52e1db177b9ebc796064a4bbcc/raw/95a5a4442068842943271103cc23df8f92c84334/nuke-config.yml -O nuke-config.yml
fi

account_sanitized=$(echo "$1" | tr -dc '0-9')

replace_account_line="# REPLACEME_TARGET"
replace_alias_line="# REPLACEME_ALIAS"

replaced_account="  \"$account_sanitized\": {} $replace_account_line"
replaced_alias="- \"$account_sanitized\" $replace_alias_line"

sed_account="s/.*$replace_account_line/$replaced_account/"
sed_alias="s/.*$replace_alias_line/$replaced_alias/"

echo "[INFO] Updating configuration file to use account id $account_sanitized."
sed -i -r "$sed_account" nuke-config.yml
sed -i -r "$sed_alias"   nuke-config.yml

echo "[INFO] Executing aws-nuke"
./bin/aws-nuke run -c nuke-config.yml --no-alias-check --profile default --no-dry-run --force --prompt-delay 5

echo "[INFO] AWS NUUUKEEEED!"

exit 0

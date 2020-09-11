#!/bin/bash

# arg1: <hostname> or <hostname:port>

fatal() {
	echo -e "\n$1\n" >&2
	exit $2
}

debugme() {
	echo
}

[[ -z "$1" ]] && fatal "$0 <hostname> or $0 <hostname:port>" 255

hostn=${1%:*}
if [[ $1 =~ : ]]; then
	port=${1#*:}
fi
port="${port:-443}"

if [[ -z "$2" ]]; then
	days=(1 3 5 10 15 30)
else
	days=($2)
fi
secs=()

for (( i=0 ; i<${#days[@]} ; i++ )) ; do
    secs[$i]=$(( ${days[$i]} * 24 * 60 * 60 ))
    # echo "${secs[$i]}";
done
# echo ${secs[@]}

cert="$(echo | openssl s_client -connect $hostn:$port -servername $hostn 2>/dev/null  | awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ { print $0 }')"
expire="$(openssl x509 -checkend 1 <<< $cert)"
enddate="$(openssl x509 -noout -enddate <<< $cert | awk -F'='  '{ print $2 }')"
[[ -z "$enddate" ]] && fatal "couldn't retrieve enddate" 254

if [[ ! $expire =~ not ]]; then
	echo "expired"
	exit 1
else
	for (( i=0 ; i<${#days[@]} ; i++ )) ; do
		sec=$(( ${days[$i]} * 24 * 60 * 60 ))
		expire="$(openssl x509 -checkend $sec <<< $cert)"
		if [[ ! $expire =~ not ]]; then
# echo $((259200 / 24 /60/60))
			echo "Certificate from \"$hostn:$port\" expires in < ${days[$i]} days"
			echo " --> at $enddate"
			exit ${days[$i]}
		fi
	done
fi


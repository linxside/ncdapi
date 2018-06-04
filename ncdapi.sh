#!/bin/bash
#developed by linux-insideDE @GPN18

#Credentials
apikey=YOUR_API_KEY
apipw=YOUR_API_PASSWORD
cid=YOUR_CUSTOMERNUMBER

end="https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON"
client=""
debug=false

#functions
login() {
	tmp=$(curl -s -X POST -d "{\"action\": \"login\", \"param\": {\"apikey\": \"$apikey\", \"apipassword\": \"$apipw\", \"customernumber\": \"$cid\"}}" "$end")
	sid=$(echo "${tmp}" | jq -r .responsedata.apisessionid)
	if [ $debug = true ]; then
		msg=$(echo "${tmp}" | jq -r .shortmessage)
		echo "$msg"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
}
logout() {
	tmp=$(curl -s -X POST -d "{\"action\": \"logout\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\"}}" "$end")
	if [ $debug = true ]; then
		msg=$(echo "${tmp}" | jq -r .shortmessage)
		echo "$msg"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		return 1
	fi
}
addRecord() {
	login
	if [ "$3" == "CAA" ] || [ "$3" == "caa" ]; then
		if [ "$(echo "$4" | cut -d' ' -f2)" == "issue" ] || [ "$(echo "$4" | cut -d' ' -f2)" == "iodef" ] || [ "$(echo "$4" | cut -d' ' -f2)" == "issuewild" ];then
			prepstate=$(echo "$4" | cut -d' ' -f3)			
			dest=${4//$prepstate/\\"\"$prepstate\\"\"}	
		else
			echo "Error: Please Check your CAA Record"
			logout
			exit 1
		fi
	else
		dest=$4
	fi
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$2\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"\", \"hostname\": \"$1\", \"type\": \"$3\", \"priority\": \"${5:-"0"}\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"} ]}}}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	logout
}
delRecord() {
	login
	if [ "$4" == "CAA" ] || [ "$4" == "caa" ]; then
		if [ "$(echo "$5" | cut -d' ' -f2)" == "issue" ] || [ "$(echo "$5" | cut -d' ' -f2)" == "iodef" ] || [ "$(echo "$5" | cut -d' ' -f2)" == "issuewild" ];then
			prepstate=$(echo "$5" | cut -d' ' -f3)			
			dest=${5//$prepstate/\\"\"$prepstate\\"\"}	
		else
			echo "Error: Please Check your CAA Record"
			logout
			exit 1
		fi
	else
		dest=$5
	fi
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$3\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"$1\", \"hostname\": \"$2\", \"type\": \"$4\", \"priority\": \"${6:-"0"}\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"} ]}}}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	logout
}
modRecord() {
	login
	if [ "$4" == "CAA" ] || [ "$4" == "caa" ]; then
		if [ "$(echo "$5" | cut -d' ' -f2)" == "issue" ] || [ "$(echo "$5" | cut -d' ' -f2)" == "iodef" ] || [ "$(echo "$5" | cut -d' ' -f2)" == "issuewild" ];then
			prepstate=$(echo "$5" | cut -d' ' -f3)			
			dest=${5//$prepstate/\\"\"$prepstate\\"\"}	
		else
			echo "Error: Please Check your CAA Record"
			logout
			exit 1
		fi
	else
		dest=$5
	fi
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$3\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"$1\", \"hostname\": \"$2\", \"type\": \"$4\", \"priority\": \"${6:-"0"}\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"} ]}}}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	logout
}
getRecords() {
	login	
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	xxd=$(echo "${tmp}" | jq -r '.responsedata.dnsrecords | .[]')
	echo "$xxd"
	logout
}
getRecordsONESESSION() {		
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	xxd=$(echo "${tmp}" | jq -r '.responsedata.dnsrecords | .[]')
	echo "$xxd"	
}
backup() {
	debug=false
	(getRecords "$1" | sed 's/} {/},{/g') > backup-"$1"-"$(date +%Y%m%d)"-"$(date +%H%M%S)".txt
}
restore() {
	login
	bfile=$(cat "$2")
	bfile2="[ $bfile ]"
	currec=$(getRecordsONESESSION "$1" | tr '\n' ' ' | sed "s/} {/},{/g")
	currec2="[ $currec ]"
	inc=0
	#del all
	len=$(echo "$currec2" | jq '. | length')
	statement=""
	while  [ "$inc" != "$len" ]  ; do
		id=$(echo "$currec2" | jq -r .[$inc].id)
		host=$(echo "$currec2" | jq -r .[$inc].hostname)
		type=$(echo "$currec2" | jq -r .[$inc].type)
		prio=$(echo "$currec2" | jq -r .[$inc].priority)
		dest=$(echo "$currec2" | jq -r .[$inc].destination)
		if [ "$inc" = "$((len-1))" ]; then
			statement+="{\"id\": \"$id\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"}"
	    else
			statement+="{\"id\": \"$id\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"},"

	    fi
		inc=$((inc+1))
	done
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$1\", \"dnsrecordset\": { \"dnsrecords\": [ $statement ]}}}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
		
	inc=0	
	#add all
	statement=""
	len=$(echo "$bfile2" | jq '. | length')
	while [ "$inc" != "$len" ] ; do		
		host=$(echo "$bfile2" | jq -r .[$inc].hostname)
		type=$(echo "$bfile2" | jq -r .[$inc].type)
		prio=$(echo "$bfile2" | jq -r .[$inc].priority)
		dest=$(echo "$bfile2" | jq -r .[$inc].destination)		
		if [ "$inc" = "$((len-1))" ]; then
			statement+="{\"id\": \"\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"}"
	    else
			statement+="{\"id\": \"\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"},"
	    fi	   
		inc=$((inc+1))
	done
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$1\", \"dnsrecordset\": { \"dnsrecords\": [ $statement ]}}}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	logout
}
help() {
	echo "IMPORTANT: Only ONE Argument like -N or -dN"
	echo "If you have a string which is including spaces use \"around your string\""
	echo ""
	echo "-d   Debug Mode   ncdapi.sh -d..."
	echo "-N   NEW Record	  ncdapi.sh -N HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-M   MOD Record	  ncdapi.sh -N ID HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-D   DEL Record	  ncdapi.sh -D ID HOST DOMAIN HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-g   get all Records	ncdapi.sh -g DOAMIN"
	echo "-b   backup from Zone	ncdapi.sh -b DOMAIN"
	echo "-R   Restore Zone	ncdapi.sh -R DOMAIN DATEI"
	echo "-I   Install Script"
	echo "-h   this help"
	echo ""
	echo "Examples:"
	echo "New CAA Record: ncdapi.sh -N @ example.com CAA \"0 issue letsencrypt.org\""
	echo "New   A Record: ncdapi.sh -N @ example.com A 127.0.0.1"
	echo "New  MX Record: ncdapi.sh -N @ example.com MX mail.example.com 20"
	echo ""
	echo "Get all records: ncdapi.sh -g example.com"
	echo ""
	echo "Delete Record:  ncdapi.sh -D 1234567 @ example.com A 127.0.0.1"
}

#begin script

if [ $# -eq 0 ]; then
	echo "No Argument"
	help
fi

while getopts 'NdDgMbRIh' opt ; do
	case "$opt" in
		d) debug=true;;
		N) addRecord "$2" "$3" "$4" "$5" "$6";;
		D) delRecord "$2" "$3" "$4" "$5" "$6" "$7" "$8";;
		g) getRecords "$2";;
		M) modRecord "$2" "$3" "$4" "$5" "$6" "$7";;
		b) backup "$2";;
		R) restore "$2" "$3";;
		I) install;;
		h) help;;
		*) echo "Invalid Argument";;
	esac
done

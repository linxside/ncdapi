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
		echo "Error: Session isn't made invalid !!!"
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
getSOA() {
	login
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsZone\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	if [ $debug = true ]; then
		echo "$tmp"
	fi	
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	xxd=$(echo "${tmp}" | jq -r '.responsedata')
	echo "$xxd"
	logout
}
getSOAONESESSION() {
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsZone\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	xxd=$(echo "${tmp}" | jq -r '.responsedata')
	echo "$xxd"
}
setSOA() {
	login
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsZone\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$1\", \"dnszone\": { \"name\": \"$1\", \"ttl\": \"$2\", \"serial\": \"\", \"refresh\": \"$3\", \"retry\": \"$4\", \"expire\": \"$5\", \"dnssecstatus\": \"$6\"} }}" "$end")
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
listDomains() {
	login	
	tmp=$(curl -s -X POST -d "{\"action\": \"listallDomains\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	if [ $debug = true ]; then
		echo "$tmp"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	xxd=$(echo "${tmp}" | jq -r '.responsedata[].domainname')
	echo "$xxd"
	logout
}
getRecords() {
	login
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	if [ $debug = true ]; then
		echo "$tmp"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	xxd=$(echo "${tmp}" | jq -r '.responsedata.dnsrecords')
	echo "$xxd"
	logout
}
getRecordsONESESSION() {		
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" "$end")
	xxd=$(echo "$tmp" | jq -r '.responsedata')
	echo "$xxd"	
}
backup() {
	login
	debug=false
	soa=$(getSOAONESESSION "$1")
	records=$(getRecordsONESESSION "$1")
	statement="{\"soa\":$soa,\"records\":$records}"
	echo "$statement" > backup-"$1"-"$(date +%Y%m%d)"-"$(date +%H%M%S)".txt
	logout
}
restore() {
	login
	bfile=$(cat "$1")
	name=$(echo "$bfile" | jq -r '.soa.name')
	ttl=$(echo "$bfile" | jq -r '.soa.ttl')
	refresh=$(echo "$bfile" | jq -r '.soa.refresh')
	retry=$(echo "$bfile" | jq -r '.soa.retry')
	expire=$(echo "$bfile" | jq -r '.soa.expire')
	dnssecstatus=$(echo "$bfile" | jq -r '.soa.dnssecstatus')
	currec=$(getRecordsONESESSION "$name" | jq .dnsrecords)
	inc=0
	
	#update soa	
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsZone\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$name\", \"dnszone\": { \"name\": \"$name\", \"ttl\": \"$ttl\", \"serial\": \"\", \"refresh\": \"$refresh\", \"retry\": \"$retry\", \"expire\": \"$expire\", \"dnssecstatus\": \"$dnssecstatus\"} }}" "$end")
	if [ $debug = true ]; then
		echo "${tmp}"
	fi
	if [ "$(echo "$tmp" | jq -r .status)" != "success" ]; then
		echo "Error: $tmp"
		logout
		return 1
	fi
	
	#del all
	len=$(echo "$currec" | jq '. | length')
	statement=""
	while  [ "$inc" != "$len" ]  ; do
		id=$(echo "$currec" | jq -r .[$inc].id)
		host=$(echo "$currec" | jq -r .[$inc].hostname)
		type=$(echo "$currec" | jq -r .[$inc].type)
		prio=$(echo "$currec" | jq -r .[$inc].priority)
		dest=$(echo "$currec" | jq -r .[$inc].destination)
		if [ "$inc" = "$((len-1))" ]; then
			statement+="{\"id\": \"$id\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"}"
	    else
			statement+="{\"id\": \"$id\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"},"

	    fi
		inc=$((inc+1))
	done
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$name\", \"dnsrecordset\": { \"dnsrecords\": [ $statement ]}}}" "$end")
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
	len=$(echo "$bfile" | jq '.records | length')
	while [ "$inc" != "$len" ] ; do		
		host=$(echo "$bfile" | jq -r .records[$inc].hostname)
		type=$(echo "$bfile" | jq -r .records[$inc].type)
		prio=$(echo "$bfile" | jq -r .records[$inc].priority)
		dest=$(echo "$bfile" | jq -r .records[$inc].destination)		
		if [ "$inc" = "$((len-1))" ]; then
			statement+="{\"id\": \"\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"}"
	    else
			statement+="{\"id\": \"\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"},"
	    fi	   
		inc=$((inc+1))
	done
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$name\", \"dnsrecordset\": { \"dnsrecords\": [ $statement ]}}}" "$end")
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
	echo "-R   Restore Zone	ncdapi.sh -R FILE"
	echo "-s   get SOA    	ncdapi.sh -s DOAMIN"
	echo "-S   change SOA    	ncdapi.sh -S DOAMIN TTL REFRESH RETRY EXPIRE DNSSECSTATUS"
	echo "-l   list all Domains	ncdapi.sh -l"
	echo "-h   this help"
	echo ""
	echo "Examples:"
	echo "New CAA Record:  ncdapi.sh -N @ example.com CAA \"0 issue letsencrypt.org\""
	echo "New   A Record:  ncdapi.sh -N @ example.com A 127.0.0.1"
	echo "New  MX Record:  ncdapi.sh -N @ example.com MX mail.example.com 20"
	echo "Get all records: ncdapi.sh -g example.com"
	echo "Delete Record:   ncdapi.sh -D 1234567 @ example.com A 127.0.0.1"
	echo "Change SOA:	 ncdapi.sh -S example.com 3600 28800 7200 1209600 true"
}

#begin script

if [ $# -eq 0 ]; then
	echo "No Argument"
	help
fi

while getopts 'NdDgMbRhslS' opt ; do
	case "$opt" in
		d) debug=true;;
		N) addRecord "$2" "$3" "$4" "$5" "$6";;
		D) delRecord "$2" "$3" "$4" "$5" "$6" "$7" "$8";;
		g) getRecords "$2";;
		M) modRecord "$2" "$3" "$4" "$5" "$6" "$7";;
		b) backup "$2";;
		R) restore "$2";;
		s) getSOA "$2";;
		S) setSOA "$2" "$3" "$4" "$5" "$6" "$7";;
		l) listDomains "$2" ;;
		h) help;;
		*) echo "Invalid Argument";;
	esac
done

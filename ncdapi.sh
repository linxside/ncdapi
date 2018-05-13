#/bin/bash

#Credentials
apikey=YOUR_API_KEY
apipw=YOUR_API_PASSWORD
cid=YOUR_CUSTOMERNUMBER

end=https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON
client=""
debug=false

#Functions
login() {
	tmp=$(curl -s -X POST -d '{"action": "login", "param": {"apikey": "'$apikey'", "apipassword": "'$apipw'", "customernumber": "'$cid'"}}' $end)
	sid=$(echo ${tmp} | jq -r .responsedata.apisessionid)
	if [ $debug = true ]; then
		msg=$(echo ${tmp} | jq -r .shortmessage)
		echo $msg
	fi
}
logout() {
	tmp=$(curl -s -X POST -d '{"action": "logout", "param": {"apikey": "'$apikey'", "apisessionid": "'$sid'", "customernumber": "'$cid'"}}' $end)
	if [ $debug = true ]; then
		msg=$(echo ${tmp} | jq -r .shortmessage)
		echo $msg
	fi
}
addRecord() {
	login	
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$2\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"\", \"hostname\": \"$1\", \"type\": \"$3\", \"priority\": \"${5:-"0"}\", \"destination\": \"$4\", \"deleterecord\": \"false\", \"state\": \"yes\"} ]}}}" $end)
	if [ $debug = true ]; then
		echo ${tmp}
	fi
	logout
}
delRecord() {
	login
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$3\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"$1\", \"hostname\": \"$2\", \"type\": \"$4\", \"priority\": \"${6:-"0"}\", \"destination\": \"$5\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"} ]}}}" $end)
	if [ $debug = true ]; then
		echo ${tmp}
	fi
	logout
}
modRecord() {
	login	
	tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$3\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"$1\", \"hostname\": \"$2\", \"type\": \"$4\", \"priority\": \"${6:-"0"}\", \"destination\": \"$5\", \"deleterecord\": \"false\", \"state\": \"yes\"} ]}}}" $end)
	if [ $debug = true ]; then
		echo ${tmp}
	fi
	logout
}
getRecords() {
	login	
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" $end)
	xxd=$(echo ${tmp} | jq -r '.responsedata.dnsrecords | .[]')
	echo $xxd
	logout
}
getRecordsONESESSION() {		
	tmp=$(curl -s -X POST -d "{\"action\": \"infoDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\", \"domainname\": \"$1\"}}" $end)
	xxd=$(echo ${tmp} | jq -r '.responsedata.dnsrecords | .[]')
	echo $xxd	
}
backup() {
	debug=false
	(getRecords $1 | sed 's/} {/},{/g') > backup-$1-$(date +%Y%m%d)-$(date +%H%M%S).txt
}
restore() {
	login	
	bfile=$(cat $2)
	bfile2=$(echo "[ $bfile ]")
	currec=$(getRecordsONESESSION $1 | sed 's/} {/},{/g')
	currec2=$(echo "[ $currec ]")	
	
	inc=0
	#del all
	len=$(echo $currec2 | jq '. | length')
	while  [ "$inc" != "$len" ]  ; do
		id=$(echo $currec2 | jq -r .[$inc].id)
		host=$(echo $currec2 | jq -r .[$inc].hostname)
		type=$(echo $currec2 | jq -r .[$inc].type)
		prio=$(echo $currec2 | jq -r .[$inc].priority)
		dest=$(echo $currec2 | jq -r .[$inc].destination)
	    tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$1\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"$id\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"TRUE\", \"state\": \"yes\"} ]}}}" $end)
		if [ $debug = true ]; then
			echo ${tmp}
		fi
		inc=$((inc+1))
	done
		
	inc=0	
	#add all
	len=$(echo $bfile2 | jq '. | length')
	while [ "$inc" != "$len" ] ; do		
		host=$(echo $bfile2 | jq -r .[$inc].hostname)
		type=$(echo $bfile2 | jq -r .[$inc].type)
		prio=$(echo $bfile2 | jq -r .[$inc].priority)
		dest=$(echo $bfile2 | jq -r .[$inc].destination)
	    tmp=$(curl -s -X POST -d "{\"action\": \"updateDnsRecords\", \"param\": {\"apikey\": \"$apikey\", \"apisessionid\": \"$sid\", \"customernumber\": \"$cid\",\"clientrequestid\": \"$client\" , \"domainname\": \"$1\", \"dnsrecordset\": { \"dnsrecords\": [ {\"id\": \"\", \"hostname\": \"$host\", \"type\": \"$type\", \"priority\": \"$prio\", \"destination\": \"$dest\", \"deleterecord\": \"false\", \"state\": \"yes\"} ]}}}" $end)
		if [ $debug = true ]; then
			echo ${tmp}
		fi
		inc=$((inc+1))
	done	
	logout
}
install() {
	nm=$(echo $0 | sed 's/\.\///g')
	mkdir $(pwd)/api/
	cp $0 $(pwd)/api/
	chmod +x $(pwd)/api/$nm
	st="alias ncdapi='$(pwd)/api/$nm'"
	echo $st >> ~/.bashrc
}
remove() {	
	tmp=$(cat ~/.bashrc)
	echo $tmp | sed "s/alias[:space:]ncdapi\=\'\$\(pwd\)\/api\/$nm\'//g" > ~/.bashrc
	
}
help() {
	echo "IMPORTANT: Only ONE Argument like -N or -dN"
	echo "If you have a string which is including spaces use \"around your string\""
	echo ""
	echo "-d   Debug Mode   ncapi.sh -d..."
	echo "-N   NEW Record	  ncapi.sh -N HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-M   MOD Record	  ncapi.sh -N ID HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-D   DEL Record	  ncapi.sh -D ID HOST DOMAIN HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]"
	echo "-g   get all Records	ncapi.sh -g DOAMIN"
	echo "-b   backup from Zone	ncapi.sh -b DOMAIN"
	echo "-R   Restore Zone	ncapi.sh -R DOMAIN DATEI"
	echo "-I   Install Script"
	echo "-h   this help"
}

#Begin Script

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

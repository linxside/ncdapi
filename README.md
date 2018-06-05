# ncdapi (inofficial netcup DNS API Client)

## BUG
At the moment there might be a bug in the api which delete records if you want to modify them. Please don't use modify function at the moment.

## WARNING
This client is well tested, but it is possible that some actions provoke a bug, so the use of this client is on your own risk and may result in lost of your zone data.

### Requirements
- jq (a json parser)
- curl

### Credentials
To use this script you must replace the values at beginning of the script with your:
```
#Credentials
apikey=YOUR_API_KEY
apipw=YOUR_API_PASSWORD
cid=YOUR_CUSTOMERNUMBER
```
### How to use
```
IMPORTANT: Only ONE Argument like -N or -dN
If you have a string which is including spaces use "around your string"
  
-d   Debug Mode         ncdapi.sh -d...
-N   NEW Record         ncdapi.sh -N HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-M   MOD Record         ncdapi.sh -N ID HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-D   DEL Record         ncdapi.sh -D ID HOST DOMAIN HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-g   get all Records	ncdapi.sh -g DOAMIN
-b   backup from Zone	ncdapi.sh -b DOMAIN
-R   Restore Zone	ncdapi.sh -R FILE
-s   get SOA    	ncdapi.sh -s DOAMIN
-S   change SOA    	ncdapi.sh -S DOAMIN TTL REFRESH RETRY EXPIRE DNSSECSTATUS
-l   list all Domains	ncdapi.sh -l
-h   this help

Examples:
New CAA Record:  ncdapi.sh -N @ example.com CAA "0 issue letsencrypt.org"
New   A Record:  ncdapi.sh -N @ example.com A 127.0.0.1
New  MX Record:  ncdapi.sh -N @ example.com MX mail.example.com 20
Get all records: ncdapi.sh -g example.com
Delete Record:   ncdapi.sh -D 1234567 @ example.com A 127.0.0.1
Change SOA:	 ncdapi.sh -S example.com 3600 28800 7200 1209600 true
```

### Functions
* add new record
* modify record/SOA
* delete record
* get all records/domains
* backup/restore of zone + SOA
* If the api returns a failure the session will automatically make invalid and the plain JSON from the api will be written to stdout

### TODO
- DynDNS capability if the api get the possibility for per record TTL in near future
- ...

developed by linux-insideDE @GPN18

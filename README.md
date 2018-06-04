# ncdapi (inofficial netcup DNS API Client)
## WARNING
This client is well tested, but it is possible that some actions provoke a bug, so the use of this client is on your own risk and may result in lost of your zone data.

### Requirments
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
  
-d   Debug Mode   ncdapi.sh -d...
-N   NEW Record	  ncdapi.sh -N HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-M   MOD Record	  ncdapi.sh -N ID HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-D   DEL Record	  ncdapi.sh -D ID HOST DOMAIN HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-g   get all Records	ncdapi.sh -g DOAMIN
-b   backup from Zone	ncdapi.sh -b DOMAIN
-R   Restore Zone	ncdapi.sh -R DOMAIN FILE
-h   this help
```

### Functions
* add new record
* modify record
* delete record
* get all records
* backup/restore of zone
* If the api returns a failure the session will automatically made invalid and the  plain JSON from te api will be written to stdout

### TODO
- Add Support for SOA
- Rewrite Backup and Restore for SOA
- DynDNS capability if the api get the possibility for per record TTL in near future
- ...

developed by linux-insideDE @GPN18

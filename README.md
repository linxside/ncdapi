# ncdapi (inofficial netcup DNS API Client)
## WARNING
The nc API is still under developement and this client also. This client is well tested, but it is possible that some actions provoke a bug, so the use of this client is on your own risk and may result in lost of your zone data (not your domain).

## Functions
* add new record
* modify record
* delete record
* get all records
* backup/restore of zone
* install

## Help
```
IMPORTANT: Only ONE Argument like -N or -dN
If you have a string which is including spaces use "around your string"
  
-d   Debug Mode   ncapi.sh -d...
-N   NEW Record	  ncapi.sh -N HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-M   MOD Record	  ncapi.sh -N ID HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-D   DEL Record	  ncapi.sh -D ID HOST DOMAIN HOST DOMAIN RECORDTYPE DESTINATION [PRIORITY]
-g   get all Records	ncapi.sh -g DOAMIN
-b   backup from Zone	ncapi.sh -b DOMAIN
-R   Restore Zone	ncapi.sh -R DOMAIN FILE
-I   Install Script
-h   this help
```

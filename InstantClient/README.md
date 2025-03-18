# Oracle Instant Client

## Download Oracle Instant Client. 
https://www.oracle.com/database/technologies/instant-client/downloads.html


## Install on Mac OSX Intel
* Download this files
- instantclient-basic-macos.x64-19.16.0.0.0dbru.dmg
- instantclient-sdk-macos.x64-19.16.0.0.0dbru.dmg
- instantclient-sqlplus-macos.x64-19.16.0.0.0dbru.dmg

* Unzip and copy in ./InstantClient/macosx64

* Add to .zshrc: 
```
#Oracle Instant Client
export ORACLE_HOME=/your/folder
export DYLD_LIBRARY_PATH=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME
export NLS_LANG=AMERICAN_AMERICA.UTF8
export PATH=$PATH:$ORACLE_HOME
```
* Run: 
```
source .zshrc 
```
* Add in /etc/hosts: 
```
127.0.0.1       localhost       maclibro        maclibro.local
```

* Test conection: 
```
sqlplus dismemayor/d@//localhost:1521/orcl
```

## Install on Windows
* Download this files
- instantclient-basic-windows.x64-19.26.0.0.0dbru.zip
- instantclient-sqlplus-windows.x64-19.26.0.0.0dbru.zip
- instantclient-sdk-windows.x64-19.26.0.0.0dbru.zip
        
* Unzip and copy .\InstantClient\windows

* Add path folder in PATH system: 
1. Run sysdm.cpl.
2. Advance options.
3. Environment variables.
4. System variables.
5. Choose variable Path.
6. Edit.
7. Set "C:\your\path\InstantClient\windows;" 

* Test conection: 
```
sqlplus dismemayor/d@//localhost:1521/orcl
```

### Instal on Ubuntu.

* Download this files

- instantclient-basic-linux.x64-19.26.0.0.0dbru.zip
- instantclient-sdk-linux.x64-19.26.0.0.0dbru.zip
- instantclient-sqlplus-linux.x64-19.26.0.0.0dbru.zip
        
* Unzip and copy ./InstantClient/linux

* Create symbolic links:
```
ln -s libclntsh.so.11.1 libclntsh.so
ln -s libocci.so.11.1 libocci.so
```        
* Create oracle.conf file and set path:
```
sudo vim /etc/ld.so.conf.d/oracle.conf
```
```     
/your/path/InstantClient/linux
```        
* Run and install dependencies
```
sudo ldconfig
```
```
sudo apt install libaio-dev libaio1
```     
* Add to .bashrc file: 
```
#Oracle Instant Client
export ORACLE_HOME=/your/folder
export LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME:$PATH
```
* Run: 
```
source .bashrc 
```     
* Test conection: 
```
sqlplus dismemayor/d@//localhost:1521/orcl
```     
        
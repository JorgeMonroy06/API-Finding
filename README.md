# Self-hosted private Dart Pub server for Enterprise


### Folder Structure
|Folder|Deploy|Action|
|--|--|--|
|flutter_pub_web|[Web Deploy](https://github.com/jiang111/pub_server/tree/master/flutter_pub_web)|web code|
|pub_publisher|Client|Send source code to private server|
|pub_server_go|[Server Deploy](https://github.com/jiang111/pub_server/blob/master/pub_server_go/README.md)|Private server backend source code, based on go , faster and more stable|



### Client 

> 0. in pubspec.yaml add: publish_to: http://ip:port

> 1. windows download [file](https://github.com/jiang111/pub_server/raw/master/pub_publisher/bin/publite.exe),Mac download [file](https://github.com/jiang111/pub_server/raw/master/pub_publisher/bin/publite), add  publite to path,in your terminal ,run:

```
publite E:\coding\my_app
```

> 2. Check whether the warehouse is released successfully, ,call http://ip:port/api/getAllPackages 

> 3. how to depend:

```
  package_name:
    hosted:
      name: plugin_name
      url: http://ip:port
    version: ^lastedVersion
```
> 5. common API:

```
http://ip:port/api/getAllPackages  //Get the names of all available libraries, and their latest versions

http://ip:port/api/packages/<package-name> //Get package_name history versions

http://ip:port/api/packages/<package-name>/versions/<version-name> //Get package_name -> version-name info

http://ip:port/packages/<package-name>/versions/<version-name>.tar.gz //download special version with package-name
```

> 6. GUI deploy https://github.com/jiang111/pub_server/tree/master/flutter_pub_web



[![Stargazers over time](https://starchart.cc/jiang111/pub_server.svg)](https://starchart.cc/jiang111/pub_server)








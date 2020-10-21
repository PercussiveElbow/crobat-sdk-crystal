# Crobat SDK - Crystal

Crystal SDK and command line client for [SonarSearch/Crobat](https://github.com/Cgboal/SonarSearch).

## Download
Prebuilt binary releases available [here](https://github.com/PercussiveElbow/crobat-sdk-crystal/releases).
Prebuilt Docker container available [here](https://github.com/users/PercussiveElbow/packages/container/package/crobat).

To grab the latest release:

```wget https://github.com/PercussiveElbow/crobat-sdk-crystal/releases/latest/download/crobat_client && chmod +x ./crobat_client```

To run the latest Docker container (~20MB)
```sudo docker run -it ghcr.io/percussiveelbow/crobat:latest```


## Usage - Client

### Client

```
Usage: ./crobat_client [arguments]
    -q QUERY, --query                Target domain, IP or IP range to query.
    -s TYPE, --type                  Search type. (SUBDOMAIN, ALL, REVERSE TLD)
    -f FORMAT, --format              File output format. (JSON, TXT, CSV)
    -o FILE, --output                File output location.
    -h, --help                       Show help.

E.g ./crobat_client -q twitter.com -s subdomain
```

### Client - Docker
To build and use the Docker container:
```
 sudo docker build . -t crobat && sudo docker run -it crobat -q twitter.com -s subdomain
```

## Usage - SDK
Add the SDK as a dependency within your _shards.yml_:
```
dependencies:
  crobat:
      github: percussiveelbow/crobat-sdk-crystal
```
Then simply  `require "crobat/crobat_sdk"` at the top of your file.

The client object can then be instantiated and used like below. 
```
require "crobat/crobat_sdk"

client = Crobat::CrobatSDK.new("https://sonar.omnisint.io")

# Retrieving subdomains via SDK
puts(client.retrieve_subdomains("twitter.com"))

# Retrieving all results via SDK
puts(client.retrieve_all("twitter.com"))

# Retrieving tlds via SDK
puts(client.retrieve_tlds("twitter.com"))

# Retrieving reverse info for an IP via SDK
puts(client.retrieve_reverse("8.8.8.8"))

# Retrieving reverse info for an IP range via SDK
puts(client.retrieve_reverse_range("95.138.157.0/16"))
```

## Building manually
### Building the client
```
crystal build --static --release src/crobat_client.cr
```

### Building the SDK
```
crystal build --static --release src/crobat_sdk.cr
```


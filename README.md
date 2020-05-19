# Crobat SDK - Crystal

Crystal SDK and command line client for [SonarSearch/Crobat](https://github.com/Cgboal/SonarSearch).

## Download
Binary releases available [here](https://github.com/PercussiveElbow/crobat-sdk-crystal/releases).

To grab the latest release:

```wget https://github.com/PercussiveElbow/crobat-sdk-crystal/releases/latest/download/crobat_client && chmod +x ./crobat_client```

## Usage (Client)

```
Usage: ./crobat.cr [arguments]
    -d DOMAIN, --domain              Target domain.
    -s TYPE, --type                  Search type. (SUBDOMAIN, ALL, TLD)
    -f FORMAT, --output format       Output format. (JSON, TXT, CSV)
    -o FILE, --file path             Output file.
    -h, --help                       Show help.


E.g ./crobat_client -d twitter.com -s subdomain
```


## Usage (SDK)
Add the SDK as a dependency within your _shards.yml_:
```
dependencies:
  crobat-sdk:
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
```
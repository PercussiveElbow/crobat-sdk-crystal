# Crobat Client - Crystal

Crystal client for [SonarSearch/Crobat](https://github.com/Cgboal/SonarSearch)

## Download
Binary releases available [here](https://github.com/PercussiveElbow/crobat-sdk-crystal/releases).

To grab the latest release:

```wget https://github.com/PercussiveElbow/crobat-sdk-crystal/releases/latest/download/crobat_client && chmod +x ./crobat_client```

## Usage (Client)

```
Usage: ./crobat.cr [arguments]
    -d DOMAIN, --domain              Target domain.
    -s TYPE, --type                  Search type. (SUBDOMAIN, ALL, TLD
    -o FORMAT, --output format       Output format. (JSON, TXT, CSV)
    -f FILE, --file path             Output file.
    -h, --help                       Show help.


E.g ./crobat_client -d twitter.com -s subdomain
```

## Usage (SDK)
In your shards.yml:
```
dependencies:
  crobat-sdk:
      github: percussiveelbow/crobat-sdk-crystal
```
Then simply add `require "crobat/crobat_sdk"` at the top of your file.
The client object can then by accessed via  `Crobat::CrobatSDK.new(URL)`. 
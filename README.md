# Crobat Client - Crystal

Crystal client for [SonarSearch/Crobat](https://github.com/Cgboal/SonarSearch)

Binary releases available [here](https://github.com/PercussiveElbow/crobat-client-crystal/releases)

## Usage

```
Usage: ./crobat.cr [arguments]
    -d DOMAIN, --domain              Target domain.
    -s TYPE, --type                  Search type. (SUBDOMAIN, ALL, TLD
    -o FORMAT, --output format       Output format. (JSON, TXT, CSV)
    -f FILE, --file path             Output file.
    -h, --help                       Show help.


E.g ./crobat_client -d twitter.com -s subdomain
```

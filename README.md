# dyndns-update

`dyndns-update` is a tool to update the IP address of a dynamic DNS domain. It currently supports updates via an update URL.

## Configuration

The configuration of this tool is stored in a YAML file. The following configurations are available:

| Configuration                            | Type   | Mandatory | Default Value             | Description                                                        |
| ---------------------------------------- | ------ | --------- | ------------------------- | ------------------------------------------------------------------ |
| `ipResolver.ipv4`                        | String | n         | `https://api.ipify.org`   | Service that returns the public IPv4 address.                      |
| `ipResolver.ipv6`                        | String | n         | `https://api64.ipify.org` | Service that returns the public IPv6 address.                      |
| `exponentialBackoff.maxRetries`          | Int    | n         | `5`                       | Maximum retries of the exponential backoff in case of an error.    |
| `exponentialBackoff.baseDely`            | Double | n         | `1.5`                     | The base delay inbetween the retries.                              |
| `checkAddressChangeInterval`             | Double | n         | `300.0`                   | Interval at which the IP addresses are checked and set in seconds. |
| `forceUpdateInterval`                    | Double | n         | `86400.0`                 | Intervakl at which the IP addresses are forced to be updated.      |
| `services`                               | Array  | y         |                           | The dynamic DNS services that shall be updated.                    |
| `services[n].name`                       | String | y         |                           | The name of the service.                                           |
| `services[n].url`                        | String | y         |                           | The update URL.                                                    |
| `services[n].username`                   | String | y         |                           | The username.                                                      |
| `services[n].passwd`                     | String | y         |                           | The password.                                                      |
| `services[n].domain`                     | String | y         |                           | The dynamic DNS domain.                                            |

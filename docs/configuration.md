# Configuration

All server Configuration are defined using environment variables

This file contains the environment variables for Authority.

|                       |                                                                                                     |                                                                 |
| --------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| Environment Variable  | Default Value                                                                                       | Description                                                     |
| CRYSTAL\_ENV          | developement                                                                                        |                                                                 |
| CRYSTAL\_LOG\_SOURCES | "\*"                                                                                                |                                                                 |
| CRYSTAL\_WORKERS      | 4                                                                                                   | the number of cpu cores to us                                   |
| PORT                  | 4000                                                                                                |                                                                 |
| PORT\_REUSE           | true                                                                                                |                                                                 |
| HOST                  | 0.0;0.0                                                                                             | Binds the server to a particular ip address on the host machine |
| DATABASE\_URL         | postgres://auth\_user:auth\_pass@db:5432/authority\_db?initial\_pool\_size=10\&checkout\_timeout=3P | Potgres database connection url                                 |
| SECRET\_KEY           | secret\_key                                                                                         | The encryption key to use sining jwts                           |
| CODE\_TTL             | 5                                                                                                   | Duration in minuts                                              |
| ACCESS\_TOKEN\_TTL    |                                                                                                     |                                                                 |
| TEMPLATES\_PATH       |                                                                                                     |                                                                 |
| ERROR\_TEMPLATE       |                                                                                                     |                                                                 |
| SESSION\_KEY          |                                                                                                     |                                                                 |
| BASE\_URL             |                                                                                                     |                                                                 |
| ACTIVATE\_URL         |                                                                                                     |                                                                 |
| DEVICE\_CODE\_TTL     |                                                                                                     |                                                                 |
| SSL\_CERT             |                                                                                                     |                                                                 |
| SSL\_KEY              |                                                                                                     |                                                                 |
| SSL\_CA               |                                                                                                     |                                                                 |
| SSL\_MODE             |                                                                                                     |                                                                 |
| CRYSTAL\_LOG\_LEVEL   |                                                                                                     |                                                                 |


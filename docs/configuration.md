# Configuration

All server Configuration are defined using environment variables

This file contains the environment variables for Authority.

|                           |                                                                                                     |                                                                 |
| ------------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| **Environment Variable**  | **Default Value**                                                                                   | **Description**                                                 |
| **CRYSTAL\_ENV**          | Development                                                                                         |                                                                 |
| **CRYSTAL\_LOG\_SOURCES** | "\*"                                                                                                |                                                                 |
| **CRYSTAL\_LOG\_LEVEL**   | debug                                                                                               |                                                                 |
| **CRYSTAL\_WORKERS**      | 4                                                                                                   | the number of CPU cores to use                                  |
| **PORT**                  | 4000                                                                                                |                                                                 |
| **PORT\_REUSE**           | true                                                                                                |                                                                 |
| **HOST**                  | 0.0;0.0                                                                                             | Binds the server to a particular ip address on the host machine |
| **DATABASE\_URL**         | postgres://auth\_user:auth\_pass@db:5432/authority\_db?initial\_pool\_size=10\&checkout\_timeout=3P | PostgreSQL database connection URL                              |
| **SECRET\_KEY**           | secret\_key                                                                                         | The encryption key to use signed JWTs                           |
| **CODE\_TTL**             | 5                                                                                                   | Duration in seconds                                             |
| **ACCESS\_TOKEN\_TTL**    | 60                                                                                                  | Duration in seconds                                             |
| **TEMPLATES\_PATH**       | ./public/templates                                                                                  |                                                                 |
| **SESSION\_KEY**          | session\_id                                                                                         |                                                                 |
| **BASE\_URL**             | [http://localhost:4000](http://localhost:4000)                                                      |                                                                 |
| **DEVICE\_CODE\_TTL**     | 300                                                                                                 | Duration in seconds                                             |
| **SSL\_CERT**             | ""                                                                                                  |                                                                 |
| **SSL\_KEY**              | ""                                                                                                  |                                                                 |
| **SSL\_CA**               | ""                                                                                                  |                                                                 |
| **SSL\_MODE**             | ""                                                                                                  |                                                                 |


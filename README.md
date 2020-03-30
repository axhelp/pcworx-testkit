# PC WORX TestKit

## Inlne funtion modules simulation blocks

### IL_UNI07
| Input            | DataType             | Meaning                                                      |
| ---------------- | -------------------- | ------------------------------------------------------------ |
| xConsoleLog      | BOOL                 | Enable loggingg to global console vaiable `udtConsole`       |
| strConsoleId     | STRING               | Logger identificator (for example, `RS DEVICE`)              |
| udtRS485Line     | udtRS485Frame        | Internal structure to transmit data between simulated modules |
| arrInputAddress  | MB2_RSUNI_ARR_B_1_14 | Simulated module prrocess data Input                         |
| arrOutputAddress | MB2_RSUNI_ARR_B_1_14 | Simulated module prrocess data Output                        |

## Common

### Console
| Input      | DataType | Meaning |
| ---------- | -------- | ------- |
| strSource  | STRTING  | Prefix  |
| strMessage | STRING   | Message |

## Examples
* [Modbus RTU with IB IL RS UNI sumulaton](./bin/examples/examples-pcworx-testkit.zwt)

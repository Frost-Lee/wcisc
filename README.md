# Wirelessly Controlled Implantable System for Chronotherapy

This repository is for the mobile application part for the project Wirelessly Controlled Implantable System for Chronotherapy (WCISC).



## App - Hardware Communication

The application and the external device adops the following messages for communication. Due to the buffer size of the characteristic of the external device, the length of the string used for communication should be less than 20.

| Description                                        | Format                                                       |
| -------------------------------------------------- | ------------------------------------------------------------ |
| app -> configuration -> external device            | `"c:%.2f;%.2f", configuration.timeInterval, configuration.dosage` |
| app -> start signal (automatic) -> external device | `"a:%.2f", configuration.dosage`                             |
| app -> start signal (manual) -> external device    | `"i:%.2f", dosage`                                           |
| app -> stop signal -> external device              | `"s:"`                                                       |
| external device -> infusion log -> app             | `"l:%d;%d", (int)dosage, status`                             |

The `status` given by external device have the following meaning:

- `0`: injection done
- `1`: external device not aligned
- `2`: external device cannot trigger injection
- `3`: pump needs refill

## To Do List

- [ ] Move the clock trigger from application to external device, so that the application runs in background, the external device runs automatically and send log data to app every time.
- [ ] Enable the application to fetch configuration and status data from external device, so that it enables multiple application instances to control the same external device.
- [x] Logic on application that checks the configuration safety.
- [ ] Prevent malicious connection to the external device.
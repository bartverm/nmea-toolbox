# nmea-toolbox
Matlab toolbox to process NMEA data

## Getting started
1. Load the available nmea messages:
```
msgs=nmea.Message.get_all_messages();
```

2. Parse string or character array data:
```
dat=msgs.parse(str);
```

## Overview
You can find more detailed explanation below:

NMEA classes:
  nmea.Message - Defines messages and parses NMEA data
  nmea.Field - Defines data fields in NMEA messages
  nmea.GPSMode - Enumeration specifying the kind of GPS fix

## Add support for new messages
If you want to add support for new messages, you have to subclass the
nmea.Message class. The easiest way to start is using one of the existing
NMEA messages (e.g. nmea.GGAMessage) copy it and modify it for the NMEA
message you want to read. Also, once the class works, add it to the
Message.get_all_messages function
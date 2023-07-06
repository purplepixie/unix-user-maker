# Unix User Maker

A bash script to create Unix users (Linux, *BSD, ...) from a CSV file using ```useradd``` and ```chpasswd``` with a variety of options.

## Licence and Author
GNU GPL v3 or later - see LICENCE file in repository.

(C) Copyright 2023 David Cutting, all rights reserved.

## Requirements

The ```bash``` shell, ```useradd``` and ```chpasswd``` available on command line.

## CSV Format

The CSV file (must be comma seperated and fields must themselves not contain commas i.e. the system cannot process commas in data even if quoted or escaped) must contain at least two fields one of the username to be created and the other of the password to set.

Which fields contain the username and password as well as other options such as stripping quotes from fields or ignoring a header line can be configured at runtime with the options below.

## Using Unix User Maker and Runtime Options

Make the script executable and then execute as normal. Only the ```filename``` option is required.

```-f``` or ```--filename``` specifies the (relative or absolute) path to the CSV file i.e. ```-f=file.csv```, this option is required.

```-e``` or ```--execute``` executes the updates to the system (create users and set passwords), otherwise the file is processed and the _intended operation and commands_ are listed, but not actually executed.

```-q``` or ```--stripquotes``` removes the first and last character of the username and passwords fields read in from CSV (intended for when the data is "quoted" or similar).

```-h``` or ```--header``` ignores the first line of input (the header row) if set, otherwise processing begins on line 1.

```-sep``` or ```--setexistingpassword``` with this flag when a user is encountered that exists on the system the password will be reset to the password in the CSV file (useful for keeping passwords aligned with source). By default (without this flag) only users created will have their passwords set, existing users will not be modified.

```-uf``` or ```--userfield``` sets the field number (starting at 1) of the username in the CSV data (defaults to 2), for example ```--uf=5``` would mean the username is in the 5th CSV field.

```-pf``` or ```--passfield``` sets the field number (starting at 1) of the password in the CSV data (defaults to 3), for example ```--pf=6``` would mean the password is in the 6th CSV field.

```-v``` or ```--version``` output version information and exit.

```-?``` or ```--help``` display the help information (usage information) and exit.

## Examples

### Simple CSV File

For example a simple CSV file called ```simple.csv``` containing no header row, without quoted fields and with the username in field 3 and password in field 4.

```csv
Some User,someuser@example.com,someuser,somePassword
Another User,another@example.com,auser,hello there
```

The CSV execution could be *tested* (run without actual changes being made) by providing the ```filename```, ```userfield``` and ```passfield``` options:
```
./user-maker.sh --filename=simple.csv --userfield=3 --passfield=4
```

Once the output had been checked and changes are desired repeating the command with the ```--execute``` flag will action user creation and update:
```
./user-maker.sh --filename=simple.csv --userfield=3 --passfield=4 --execute
```

Any existing users will be un-touched because we have not passed the ```--setexistingpassword``` flag.

### More Complex CSV File

For example a CSV file called ```example.csv``` containing a header row and quoted fields with the username in field 3 and the password in field 4.

```csv
"Full Name","Email","Username","Password"
"Some User","someuser@example.com","someuser","somePassword"
"Another User","another@example.com","auser","hello there"
```

We could process this using the same options as above (```filename```, ```userfield``` and ```passfield```) with the addition of ```--header``` to ignore the first line/row and ```--stripquotes``` to remove the quotes from the data fields:
```
./user-maker.sh --filename=simple.csv --userfield=3 --passfield=4 --header --stripquotes
```

Again this will only show the proposed changes, adding ```--execute``` will cause these to be performed:
```
./user-maker.sh --filename=simple.csv --userfield=3 --passfield=4 --header --stripquotes --execute
```

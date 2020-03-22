# Diceware
A very simple diceware implemented in Nim as an exercise to better understand some of the language features and stardard library modules.


# Building 
In order to build the program perform the following steps:

- Clone the repo `git clone https://github.com/HENRDS/diceware.git`
- Install [Nim](https://nim-lang.org) 
- At the root of the repo execute:

```shell
nimble build diceware
```
# Usage
Execute the program passing a list of numbers which is the amount of words generated for each line on the output, i. e.:
```shell
$ ./diceware 3 4 5
showroom excretion reorder
obtuse schilling fraternal harmonica
crumpet countless idealness possibly yearbook
```
The diceware uses `/dev/random` on linux by default and the pseudo random number generator from the standard library on Windows. To force the use of a pseudo RNG, pass `-p` or `--pseudo` on the command line.

The word separator on the output can be configured passing the `-s` or `--sep` options, i. e.:
```shell
$ ./diceware -s, 3 4 5
ice,stipend,serotonin
blaming,hardcopy,vest,satiable
diagnoses,deputy,gong,sleek,flaxseed
```


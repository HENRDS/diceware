import strmisc, random, strutils, critbits, parseopt, terminal, parseutils

type
  DiceValue = 1..6
  RngKind* = enum gtPseudo, gtReal
  Rng = object
    case kind: RngKind
      of gtReal:
        frng: File
      of gtPseudo:
        discard

  Diceware* = object
    rng: Rng
    wordList: CritBitTree[string]
  Args = tuple
    rngKind: RngKind
    sizes: seq[int]
    sep: string


proc rollDice(gen: Rng): DiceValue =
  ## Rolls the dice returning a random value in 1..6
  case gen.kind
  of gtPseudo:
    rand(DiceValue)
  of gtReal:
    DiceValue((gen.frng.readChar().int mod DiceValue.high) + 1)

proc close(gen: var Rng) =
  ## For real rng's we need to close the file
  case gen.kind
  of gtPseudo:
    discard
  of gtReal:
    gen.frng.close()

proc newRng(kind: RngKind): Rng =
  ## If kind is gtPseudo, uses rand from std lib
  ## if kind is gtReal, reads from /dev/random
  case kind
  of gtPseudo:
    Rng(kind: gtPseudo)
  of gtReal:
    Rng(kind: gtReal, frng: open("/dev/random"))


proc loadWordlist(path: string): CritBitTree[string] =
  let file = path.open()
  defer: file.close()
  result = CritBitTree[string]()
  for line in file.lines():
    let (index, _, word) = line.partition("\t")
    result.incl(index.strip(), word.strip())

proc initDiceware*(rngKind: RngKind): Diceware =
  Diceware(rng: newRng(rngKind), wordList: loadWordlist("wordlist.txt"))

proc getNWords*(d: var Diceware, n: int): seq[string] =
  result = newSeq[string](n)
  for i in 0..<n:
    var buf = ""
    for _ in 0..4:
      buf &= $rollDice(d.rng).int
    result[i] = d.wordList[buf]

proc usage() =
  stdout.styledWriteLine(styleBright, "usage: ", resetStyle,
                         "diceware [-p|--pseudo] [-s:SEP|--sep:SEP]",
                         " [WORD_SIZE ...]")
  stdout.styledWriteLine("optional parameters:")
  stdout.styledWriteLine(styleBright, "    -p --pseudo", resetStyle,
                         "  use pseudo random number generator instead ",
                         "of /dev/random")
  stdout.styledWriteLine(styleBright, "    -s:SEP --sep:SEP", resetStyle,
                         "  use SEP as separator when printing the words.",
                         "Defaults to ' '.")                        

proc parseCliArgs(): Args =
  var
    p = initOptParser(shortNoVal = {'p', 'h'},
                      longNoVal = @["pseudo", "help"])
    wordSizes = newSeq[int]()
    i = 0
    rngTyp = gtReal
    sep = " "

  for kind, key, val in p.getopt():
    case kind
    of cmdEnd: doAssert(false)
    of cmdArgument:
      if key.parseInt(i, 0) > 0:
        wordSizes.add(i)
      else:
        stdout.styledWriteLine(fgRed, "Invalid argument ", key, resetStyle)
        usage()
        quit(1)
    of cmdShortOption, cmdLongOption:
      case key
      of "p", "pseudo":
        rngTyp = gtPseudo
      of "h", "help":
        usage()
        quit(0)
      of "s", "sep":
        sep = val
      else:
        stdout.styledWriteLine(fgRed, "Invalid argument ", key, " ", val,
                               resetStyle)
        usage()
        quit(1)
  when defined(windows):
    if rngTyp == gtReal:
      # Windows doesn't have /dev/random
      rngTyp = gtPseudo

  if rngTyp == gtPseudo:
    randomize()

  if len(wordSizes) == 0:
    wordSizes = @[3]

  (rngKind: rngTyp, sizes: wordSizes, sep: sep)

proc main() =
  let args = parseCliArgs()
  var d = initDiceware(args.rngKind)
  defer: d.rng.close()
  for size in args.sizes:
    echo d.getNWords(size).join(args.sep)

when isMainModule:
  main()


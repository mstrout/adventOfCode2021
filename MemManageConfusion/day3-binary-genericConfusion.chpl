/*
    day3-binary.chpl

    Given an input file with 5-digit binary numbers, compute a gamma
    rate, which is a 5-digit binary number with the most common digit
    for all the numbers and an epsilon rate, which is the opposite.

    usage
      chpl day3-binary.chpl
      ./day3-binary --inputFile="input3.txt"

    Notes
      - The easiest way to do this is keeping track of the running sum
        for each bit and then use that to compute gamma and epsilon.
      - Instead I am going to create a singly linked list that all the
        number class instances are read into.  Then iterate over that
        to compute what is needed.
 */

use IO;

config const inputFile = "testin3.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// A 5-digit binary class
class FiveDigitBinary {
  var digit : [1..5] int;
  var next : FiveDigitBinary?;
}

proc FiveDigitBinary.decodeNumber(str) {
  var count = 1;
  for char in str {
    if char=="0" then digit[count] = 0; else digit[count] = 1;
  }
  writeln(this);
}

// loop through the 5-digit binary numbers that are strings in input
var str : string;
while reader.read(str) {
  var node = new FiveDigitBinary([0,0,0,0,0],nil:FiveDigitBinary?);
  node.decodeNumber(str);
}

// output the result
//writeln("position = ", curr);
//writeln("position.horizontal * position.depth = ", curr.depth*curr.horizontal);


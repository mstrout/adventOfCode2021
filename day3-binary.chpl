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
  var digit : [1..5] int = [0,0,0,0,0];
  var next : owned FiveDigitBinary? = nil;
}

proc FiveDigitBinary.decodeNumber(str:string) {
  var count = 1;
  for char in str {
    if char=="1" { digit[count] = 1; } else { digit[count] = 0; }
    count +=1;
  }
}

// loop through the 5-digit binary numbers that are strings in input
var str : string;
var head : owned FiveDigitBinary? = nil;
var tail : borrowed FiveDigitBinary? = nil;
var node : owned FiveDigitBinary?;
while reader.read(str) {
  // create a new node for the list of 5-digit numbers
  node = new FiveDigitBinary?();
  node!.decodeNumber(str);

  // connect it to the end of the list
  if tail!=nil {
    tail!.next = node;
    tail = tail!.next;
  } else {
    head = node;
    tail = head;
  }
}

var listIter : borrowed FiveDigitBinary? = head;
while listIter!=nil {
  listIter = listIter!.next;
}

writeln("head = ", head);
// output the result
//writeln("position = ", curr);
//writeln("position.horizontal * position.depth = ", curr.depth*curr.horizontal);

// FIXME: how can I check that the whole list is being deinitialized?

/*
    day3-binary.chpl

    Given an input file with binary numbers on each line in the file.
    Where the binary numbers are all have numDigits binary digits.
    Compute a gamma rate, which is a binary number with the most common digit
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
config const numDigits = 5;

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// A num-digit binary class
class BinaryDigits {
  var digit : [1..numDigits] int = 0;
  var next : owned BinaryDigits? = nil;
}

// turn a string into an array of zeros or ones
proc BinaryDigits.decodeNumber(str:string) {
  var count = 1;
  for char in str {
    if char=="1" { digit[count] = 1; } else { digit[count] = 0; }
    count +=1;
  }
}

// Treating the array of zeros and ones as a binary number,
// return the equivalent decimal number.
// Assuming a positive number and that digit[1] is MSB.
proc BinaryDigits.convertToDecimal() {
  var powerOfTwo = 1;   // current power of 2
  var sum = 0;
  // from least significant bit in digit[numDigits] to MSB compute decimal
  for i in 1..numDigits by -1 {
    sum += powerOfTwo * digit[i];
    powerOfTwo *= 2;
  }
  return sum;
}

// read in the numDigits-digit binary numbers that are strings in input
var str : string;
var head : owned BinaryDigits? = nil;
var tail : borrowed BinaryDigits? = nil;
var node : owned BinaryDigits?;
while reader.read(str) {
  // create a new node for the list of numDigits digit numbers
  node = new BinaryDigits?();
  node!.decodeNumber(str);

  // connect it to the end of the list
  if tail!=nil { tail!.next = node; tail = tail!.next; }
  else { head = node; tail = head; }
}

// keep a count of the number of 1's in each of the locations
// also keep a count of the number of variables
var listIter : borrowed BinaryDigits? = head;
var countNumbers = 0;
var countOnes : [1.. numDigits] int = 0;
while listIter!=nil {
  for i in 1..numDigits do if listIter!.digit[i] == 1 then countOnes[i] += 1;
  countNumbers += 1;
  listIter = listIter!.next;
}

// compute gamma, the most common bits in all of the numbers
// compute epsilon, the most uncommon bits in all of the numbers
var gamma = new BinaryDigits?();
var epsilon = new BinaryDigits?();
for i in 1..numDigits {
  if countOnes[i] > (countNumbers / 2) {
    gamma!.digit[i] = 1;
  } else {
    epsilon!.digit[i] = 1;
  }
}

// output the result
writeln("gamma = ", gamma, ", epsilon = ", epsilon);
writeln("gamma * epsilon = ", 
        gamma!.convertToDecimal() * epsilon!.convertToDecimal());

// FIXME: how can I check that the whole list is being deinitialized?


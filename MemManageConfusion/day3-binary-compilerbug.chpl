use IO;

config const inputFile = "testin3.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// A 5-digit binary class
class FiveDigitBinary {
  var digit : [1..5] int;
  // causes compiler bug error
  var next : FiveDigitBinary? = nil; // ? indicates the field can be nil
  // below works
//  var next : shared FiveDigitBinary? = nil; // ? indicates the field can be nil
}

// loop through the 5-digit binary numbers that are strings in input
var str : string;
while reader.read(str) {
  var node = new FiveDigitBinary();
}


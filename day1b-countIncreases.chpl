/*
    day1b-countIncreases.chpl

    Given an input file name, reads in an integer on each line an counts how
    many times a the sum of a window of three integers increases over the 
    sum of the previous three integers.

    usage
      chpl day1b-countIncreases.chpl
      ./day1b-countIncreases --inputFile="input1a.txt"

    Notes
      - The easiest way to do this is keeping track of four integers and
        comparing the sum of the first three with the last three.
      - To build intuition of how a user might use classes and in particular
        the memory management system, I am going to use classes instead.
      - Google found
          https://chapel-lang.org/docs/language/spec/classes.html
          https://chapel-lang.org/docs/primers/classes.html
          http://faculty.knox.edu/dbunde/teaching/chapel/
        for the query "how do I create a class in Chapel".
 */

use IO;

config const inputFile = "testin1b.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// Create a window class
class Window {
  var depth1, depth2, depth3;

  proc shiftValuesLeft(newVal : int) {
    depth1 = depth2;
    depth2 = depth3;
    depth3 = newVal;
  }
  proc sum () : int {
    return depth1 + depth2 + depth3;
  }
  proc copyFrom (other:Window) {
    depth1 = other.depth1;
    depth2 = other.depth2;
    depth3 = other.depth3;
  }
}

// the current and previous windows of three depth values
var prev = new Window(0, 0, 0);
var curr = new Window(0, 0, 0);

// read in the first depths to initialize things
var val : int;
reader.read(val); prev.depth1 = val;
reader.read(val); prev.depth2 = val;
reader.read(val); prev.depth3 = val;

curr.copyFrom(prev);
writeln(prev);
writeln(curr);

// start counting if we have increases
var count = 0;

// loop through the rest
while reader.read(val) {
  curr.shiftValuesLeft(val);
  //writeln("prev = ", prev);
  //writeln("curr = ", curr);
  if (curr.sum() > prev.sum()) then count +=1;
  //writeln("count = ", count);
  prev.copyFrom(curr);
}

// output the result
writeln("number of increases = ", count);


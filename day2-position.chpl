/*
    day2-position.chpl

    Given an input file name with commands that move a submarine, keeps
    track of where the submarine is and then multiplies the horizonal
    and vertical position together.

    usage
      chpl day2-position.chpl
      ./day2-position --inputFile="input2.txt"

    Notes
      - The easiest way to do this is keeping track of the horizontal and
        vertical positions and using functions to update them.
      - Instead I am going to create a Position class.
 */

use IO;

config const inputFile = "testin2.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// Create a position class
class Position {
  var depth, horizontal;

  proc forward(X) {
    horizontal += X;
  }
  proc down(X) {
    depth += X;
  }
  proc up(X) {
    depth -= X;
  }
}

// initialize the current position
var curr = new Position(0, 0);

// start reading commands
var command : string;
var amount : int;

// loop through the rest
while reader.read(command) {
  reader.read(amount);
  //writeln("command = ", command);
  //writeln("amount = ", amount);

  if command=="forward" then curr.forward(amount);
  else if command=="down" then curr.down(amount);
  else if command=="up" then curr.up(amount);
  else writeln("ERROR: unknown command ", command);
}

// output the result
writeln("position = ", curr);
writeln("position.horizontal * position.depth = ", curr.depth*curr.horizontal);


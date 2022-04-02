/*
   day1-countIncreases.chpl

   Given an input file name, reads in an integer on each line an counts how
   many times the integer increases wrt the integer on the previous line.

   usage
    chpl day1-countIncreases.chpl
    ./day1-countIncreases --inputFile="input1a.txt"

   Things I needed to look up
   - used final-word-count.chpl in DataAnalysisExample to remember how to 
     open files and read from them
   - how to read in an integer,
     https://chapel-lang.org/docs/main/modules/standard/IO.html
 */

use IO;

config const inputFile = "testin1a.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// read in the first two integers
var prev, curr : int;
reader.read(prev);  writeln(prev);

// start counting if we have increases
var count = 0;

// loop through the rest
while reader.read(curr) {
  writeln(curr);
  if (curr > prev) then count +=1;
  prev = curr;
}

// output the result
writeln("number of increases = ", count);


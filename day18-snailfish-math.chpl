/*
    day18-snailfish-math.chpl

    An example of using a tree with all shared class variables and fields.

    Given an input file with snailfish numbers, add them all up and then 
    compute the magnitude of the final snailfish number.

    snailfish number is nested pairs of numbers.  For example,
    [1,2]
    [3,[1,2]]
    [[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]

    Adding two snailfish numbers means putting them in a pair and then
    reducing the resulting snailfish number.
    "For example, [1,2] + [[3,4],5] becomes [[1,2],[[3,4],5]]."

    Reducing a snailfish number means applying one of the following two
    actions until convergence has been reached.  If any explosions are
    possible they must be applied first.  IOW if a split produces a number
    that has an explosion in it, then the explosion must happen before
    anymore splits.
      - If any pair is nested in four pairs, the leftmost entry in the pair
        explodes.  Exploding means adding the pairs left value the the first
        regular number to the left of the exploding pair if any, and the right
        to the right.  The exploding pair will be replaced with 0.

      - If a number is 10 or greater, the leftmost such regular number splits.
        Splitting is when the number is replaced with the pair
        [floor(number/2),ceiling(number/2)].

    usage
      chpl day18-snailfish-math.chpl
      ./day18-snailfish-math --inputFile="input18.txt"

    Notes
    - I started out trying to use an interface idea with an abstract
      base class and two subclasses, but then realized I don't know how
      to do that in Chapel or if it is possible yet.
    - readWriteThis, file:///Users/mstrout/chapel/doc/html/modules/standard/ChapelIO.html?highlight=readthis
 */

use IO;

config const inputFile = "testin18.1.txt";

// open a file and create a reader
var f = open(inputFile, iomode.r);
var reader = f.reader();

// Tree node for storing a snailfish number
class SnailFishNode {
  var left      : shared SnailFishNode? = nil;
  var right     : shared SnailFishNode? = nil;
  var number    : int = -1; // always non-negative in a leaf node

  proc isLeaf() {
    if left==nil && right==nil && number>=0 then return true;
    else return false;
  }

  proc toString() : string {
    if isLeaf() then return number:string;
    else return "[" + left!.toString() + "," + right!.toString() + "]";
  }
}

// Recursive function that given a string and a start index in that
// string parses and returns the snail fish number in the string at
// that place in the string.
proc decodeFromString(str,startIdx) : (shared SnailFishNode?,int) {
  var snailFishNum = new shared SnailFishNode?();
  var idxPastMe = 0;
  var idxPastRight = 0;
  var idxPastLeft = 0;
  if str[startIdx]=="[" {
    (snailFishNum!.left,idxPastLeft)  = decodeFromString(str,startIdx+1);
    (snailFishNum!.right,idxPastRight) = decodeFromString(str,idxPastLeft+1);
    idxPastMe = idxPastRight+1;  // for right bracket
  } else {
    // assuming individual numbers are only 1 digit
    snailFishNum!.number = str[startIdx] : int;
    idxPastMe = startIdx+1;
  }
  return (snailFishNum, idxPastMe);
}

// add two SnailFishNodes and produce another one
proc addSnailFish(left : shared SnailFishNode?, right : shared SnailFishNode?) {
  return new shared SnailFishNode?(nil, left, right, -1);  
}


// Checks a snailfish number for a possible explosion and does the explosion.
// An explosion will replace the first pair node at a depth of 4 with
// a regular number node with value 0.  The pair that was exploded will
// become a leftval and rightval that are added to the nearest left number
// node and right number nodes respectively, if such nodes exist.
// The function might modify the passed in snail fish number.
//
// Recursive approach that passes around the last regular number node, 
// whether an explosion has occurred, and the left and right regular numbers
// from the exploded node.
// Call on the root should be
//      checkAndDoExplosion(root,0,alreadyExploded,valnode,
//                          rightval,alreadyAddedRight);
proc checkAndDoExplosion(inout node : shared SnailFishNode?, depth : int,
                         inout alreadyExploded : bool,
                         inout mostRecentValueNode : shared SnailFishNode?,
                         inout rightVal : int, inout alreadyAddedRight : bool) {

  writeln("checkAndDoExplosion: node = ",node!.toString());

  // at a leaf, which is a regular number
  if node!.isLeaf() {
    if !alreadyExploded { mostRecentValueNode = node; }
    if alreadyExploded && !alreadyAddedRight {
      node!.number += rightVal;
      alreadyAddedRight = true;
    }

  // pair node not at depth 4, do a typical traversal
  } else if (depth<4 || alreadyExploded) && ! node!.isLeaf() {
    checkAndDoExplosion(node!.left, depth+1, alreadyExploded,
                        mostRecentValueNode, rightVal, alreadyAddedRight);
    checkAndDoExplosion(node!.right, depth+1, alreadyExploded,
                        mostRecentValueNode, rightVal, alreadyAddedRight);

  // pair node that should be exploded
  } else if depth==4 && !alreadyExploded {
    // grab the values from the pair that is going to explode
    var leftVal = node!.left!.number;
    rightVal = node!.right!.number;

    // replace the pair with the number 0 
    node = new shared SnailFishNode?(nil,nil,0);
    alreadyExploded = true;

    // go add the left value to the last number
    if mostRecentValueNode != nil then 
      mostRecentValueNode!.number += leftVal;

  // Error: shouldn't get here
  } else {
    writeln("ERROR: didn't expect to get to this else");
  }
}

// Finds the first pair in the snail fish number that has a regular number
// of 10 or greater.  Replaces that regular number with a pair of the regular
// number divided by two and rounded down and the number divided by two and
// rounded down.
proc checkAndDoSplit(inout node : shared SnailFishNode?,
                     inout alreadySplit : bool) {

  writeln("checkAndDoSplit: node = ",node!.toString());

  // at a leaf, which is a regular number that should be split
  if node!.isLeaf() && node!.number>=10  && !alreadySplit {
    alreadySplit = true;
    node = new shared SnailFishNode?(
              new shared SnailFishNode?(nil,nil, node!.number/2),
              new shared SnailFishNode?(nil,nil, node!.number/2+node!.number%2),
              -1);

  // pair node not at depth 4, do a typical traversal
  } else if !alreadySplit {
    checkAndDoSplit(node!.left, alreadySplit);
    checkAndDoSplit(node!.right, alreadySplit);

  // Error: shouldn't get here
  } else {
    writeln("ERROR: didn't expect to get to this else");
  }
}


// read in the snailfish numbers
var str : string;
while reader.readline(str) {
  var (snailFishNum,ignore) = decodeFromString(str,0);
  writeln("\nsnailFishNum = ",snailFishNum!.toString());

  // explosion helper?
  var depth = 0;
  var alreadyExploded = false;
  var valnode : shared SnailFishNode? = nil;
  var rightval = 0;
  var alreadyAddedRight = false;
  checkAndDoExplosion(snailFishNum,depth,alreadyExploded,valnode,
                      rightval,alreadyAddedRight);
  writeln("\nafter explode = ", snailFishNum!.toString());

  // split helper?
  var alreadySplit = false;
  checkAndDoSplit(snailFishNum,alreadySplit);
  writeln("\nafter split = ", snailFishNum!.toString());

}

// output the result

// FIXME: how can I check that the whole tree is being deinitialized?


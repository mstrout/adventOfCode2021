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

// Interface(?) tree node for storing a snailfish number
class SnailFishNode {
  var parent    : shared SnailFishNode? = nil;
  var left      : shared SnailFishNode? = nil;
  var right     : shared SnailFishNode? = nil;

  var number    : int = -1; // always non-negative in a leaf node

  /* Not sure how I would do this because have to tell difference
     between inner and outer node.
  proc readWriteThis(infile) throws {
    //infile <~> new ioLiteral("[") <~> 
  }
  */
  /* Don't know how to do this one either.
  proc readThis(infile) {
    var line = infile.readline();
    writeln(line);
  }
  */
}

proc 
shared SnailFishNode.decodeFromString(parentNode : shared SnailFishNode?, str) {
  parent = parentNode;
  if str[0]=="[" {
    var leftNode = new shared SnailFishNode?();
    var rightNode = new shared SnailFishNode?();
    var commaIdx : int = str.find(",");
    var rightBracketIdx : int = str.find("]");
    // YUCK: to fix this error had to cast "this"
    // error: unresolved call 'SnailFishNode.decodeFromString(borrowed SnailFishNode, string)'
    // FIXME: just can't do the below?
    //error: illegal cast from borrowed SnailFishNode to shared SnailFishNode?
    leftNode!.decodeFromString(this:shared SnailFishNode?,
                               str(1..commaIdx-1));
    rightNode!.decodeFromString(this:shared SnailFishNode?,
                                str(commaIdx+1..rightBracketIdx-1));
  } else {
    number = str[0] : int;
  }
}

// add two SnailFishNodes and produce another one
proc addSnailFish(left : shared SnailFishNode?, right : shared SnailFishNode?) {
  return new shared SnailFishNode?(nil, left, right, -1);  
}

// read in the snailfish numbers
var snailfishnum = new shared SnailFishNode?();
var str : string;
while reader.readline(str) {
  snailfishnum!.decodeFromString(nil:shared SnailFishNode?,str);
  writeln(snailfishnum);
}

// output the result

// FIXME: how can I check that the whole tree is being deinitialized?


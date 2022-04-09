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
}

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


// checks a snailfish number for a possible explosion and does the explosion
// is expecting the root node of the tree representing the number
proc checkAndDoExplosion(rootNode : shared SnailFishNode?) {
  enum whichChild {left, right, root};

  var depth = 0;
  var leftVal = 0;
  var rightVal = 0;
  var alreadyExploded = false;
  var mostRecentValueNode : shared SnailFishNode? = nil; 

  // left-to-right post-order traversal of the tree
  var treeIter : shared SnailFishNode? = rootNode; // current node is root
  var directionStack : list(enum whichChild);
  directionStack.append(whichChild.root);          // mark node as root
  var parentStack : list(shared SnailFishNode?);   // root doesn't have parent

  // do traversal
  while (treeIter != nil) {
    // at a leaf, which is a regular number
    if node!.left==nil and node!.right==nil {
      select directStack.pop() {
        when whichChild.root { // done with the traversal
          treeIter = nil;
      if parentStack.size == 0 
    }
    // should we explode the node treeIter is on?
    else if depth==4 && node!.left!=nil && (leftChild || rightChild) {
      alreadyExploded = true;
      // grab the values from the pair that is going to explode
      leftVal = node!.left!.number;
      rightVal = node!.right!.number;
      // replace the pair with the number 0 in it's parent based on
      // whether it is a left child or a right child
      var zeroNode = new shared SnailFishNode?(nil,nil,0);
      var parentNode = nodeStack.pop();
      if leftChild then parentNode!.left = zeroNode; 
      else parentNode!.right = zeroNode;
      
      // go add the left value to the last number
      if mostRecentValueNode != nil then 
        mostRecentValueNode!.number += leftVal;

      // FIXME: how do we continue the traversal at this point?

  // continue the recursion if haven't found an explosion yet
  } else if ! alreadyExploded {

  // finish recursion if already did find the explosion
  } else {
  }

  proc nextNodeInTree(node, isLeftChild, isRightChild, parent) {
  }
}

// read in the snailfish numbers
var str : string;
while reader.readline(str) {
  var snailFishNum = decodeFromString(str,0);
  writeln(snailFishNum);
}

// output the result

// FIXME: how can I check that the whole tree is being deinitialized?


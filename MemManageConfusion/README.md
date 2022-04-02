ownership-transfer-day1b.chpl
  -errors were initially
```
day1b-countIncreases.chpl:59: error: Cannot transfer ownership from a non-nilable outer variable
day1b-countIncreases.chpl:60: error: Illegal use of dead value
day1b-countIncreases.chpl:59: note: 'prev' is dead due to ownership transfer here
day1b-countIncreases.chpl:70: error: Cannot transfer ownership from a non-nilable outer variable
day1b-countIncreases.chpl:60: error: mention of non-nilable variable after ownership is transferred out of it
day1b-countIncreases.chpl:59: note: ownership transfer occurred here
```
  - Then I replaced `curr=prev` with `curr.copyFrom(prev)` and got
```
day1b-countIncreases.chpl:75: error: Cannot transfer ownership from a non-nilable outer variable
```
  - Replaced that with copyFrom as well.

Compiler bug one
----------------

MemManageConfusion/day3-binary-compilerbug.chpl
C02YP42DLVCG:adventOfCode2021 mstrout$ chpl day3-binary.chpl
day3-binary.chpl:31: internal error: UTI-MIS-0935 chpl version 1.26.0
Note: This source location is a guess.

Internal errors indicate a bug in the Chapel compiler ("It's us, not you"),
and we're sorry for the hassle.  We would appreciate your reporting this bug --
please see https://chapel-lang.org/bugs.html for instructions.  In the meantime,
the filename + line number above may be useful in working around the issue.

generic type confusion
----------------------
```
class FiveDigitBinary {
  var digit : [1..5] int;
  var next : FiveDigitBinary?;
}
...
  var node = new FiveDigitBinary([0,0,0,0,0],nil:FiveDigitBinary?);
...
adventOfCode2021 mstrout$ chpl day3-binary.chpl 
day3-binary.chpl:45: error: cannot default-initialize a variable with generic type
day3-binary.chpl:45: note: '<temporary>' has generic type 'FiveDigitBinary?'
day3-binary.chpl:45: note: cannot find initialization point to split-init this variable
```

Then I edited it to put in the following and I am still getting some kind
of generic type issue.
```
  var node = new FiveDigitBinary([0,0,0,0,0],nil:owned FiveDigitBinary?);
...
mstrout$ chpl day3-binary.chpl
$CHPL_HOME/modules/internal/OwnedObject.chpl:558: In function ':':
$CHPL_HOME/modules/internal/OwnedObject.chpl:562: error: Cannot default-initialize a variable with generic type
$CHPL_HOME/modules/internal/OwnedObject.chpl:562: note: 'tmp' has generic type 'owned FiveDigitBinary?'
  day3-binary.chpl:45: called as :(x: nil, type t = owned FiveDigitBinary?)
note: generic instantiations are underlined in the above callstack
```

Fix for compiler bug and memory management confusion
----------------------------------------------------
Apparently if you have default initialization values, then you need
to have them for all fields?
```
class FiveDigitBinary {
  var digit : [1..5] int = [0,0,0,0,0];
  var next : owned FiveDigitBinary? = nil;
}
```

Possible bug?
-------------
This might be a possible bug in how the formal type for the receiver is set up?

```
  var node : owned FiveDigitBinary? = new FiveDigitBinary?();
  node.decodeNumber(str);
```
Here are the compilation errors:
```
mstrout$ chpl day3-binary.chpl
day3-binary.chpl:48: error: unresolved call 'owned FiveDigitBinary?.decodeNumber(string)'
day3-binary.chpl:34: note: this candidate did not match: FiveDigitBinary.decodeNumber(str: string)
day3-binary.chpl:48: note: because method call receiver with type 'owned FiveDigitBinary?'
day3-binary.chpl:34: note: is passed to formal 'this: borrowed FiveDigitBinary'
day3-binary.chpl:48: note: try to apply the postfix ! operator to method call receiver
day3-binary.chpl:49: error: unresolved call 'borrowed FiveDigitBinary?.next'
day3-binary.chpl:31: note: this candidate did not match: FiveDigitBinary.next
day3-binary.chpl:49: note: because method call receiver with type 'borrowed FiveDigitBinary?'
day3-binary.chpl:31: note: is passed to formal 'this: borrowed FiveDigitBinary'
day3-binary.chpl:49: note: try to apply the postfix ! operator to method call receiver
day3-binary.chpl:49: note: other candidates are:
$CHPL_HOME/modules/internal/ChapelDistribution.chpl:746: note:   BaseArr.next
day3-binary.chpl:57: error: unresolved call 'borrowed FiveDigitBinary?.next'
day3-binary.chpl:31: note: this candidate did not match: FiveDigitBinary.next
day3-binary.chpl:57: note: because method call receiver with type 'borrowed FiveDigitBinary?'
day3-binary.chpl:31: note: is passed to formal 'this: borrowed FiveDigitBinary'
day3-binary.chpl:57: note: try to apply the postfix ! operator to method call receiver
day3-binary.chpl:57: note: other candidates are:
$CHPL_HOME/modules/internal/ChapelDistribution.chpl:746: note:   BaseArr.next
```


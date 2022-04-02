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

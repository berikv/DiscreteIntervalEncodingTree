# DiscreteIntervalEncodingTree

A swift implementation of the DiscreteIntervalEncodingTree (DIET) datastructure, based on the [academic paper by Martin Erwig](http://web.engr.oregonstate.edu/~erwig/papers/Diet_JFP98.pdf).

## Discrete Interval Encoding Tree Datastructure

A DIET is a data structure that encodes non-overlapping sequences.

Adding an element to a DIET can result in one of these operations:

- Add the added element to the DIET, increasing the DIET element count by one
- Consume the added element in one of the existing elements already present, essentially performing a non-operation
- Merge the added element to one or any number of the existing elements in the DIET, possibly reducing the DIET element count

Deleting elements from a DIET can result in one of these operations:

- Remove an already absent element, essentially a non-operation
- Remove an existing element from the DIET and / or chop off the begin / end of an existing element
- Split an existing element in two elements

DIETs manage to keep their content ordered, which results in more efficient lookup times:
 - Checking if an element is contained in an unordered collection results in a `O(n)` complexity
 - Because the DIET is ordered, the same lookup is done in `O(Log n)` complexity

The Swift implementation uses ClosedRange<T> for its element type. ClosedRange is guaranteed to contain at least one value, which is essential for the DIET datastructure.

The DiscreteIntervalEncodingTree is generic over Stridable types.

## Example code

```swift
var diet = DiscreteIntervalEncodingTree<Int>()
// Array(diet) -> []

diet.add(5)
// Array(diet) -> [5...5]

diet.add(7...10)
// Array(diet) -> [5...5, 7...10]

diet.add(6)
// Array(diet) -> [5...10]

diet.remove(7...8)
// Array(diet) -> [5...6, 9...10]

// Example methods that have O(log n) complexity:

diet.overlaps(-10...5) // true
diet.first(overlapping: 10...15) // 9...10
diet.firstIndex(overlapping: 10...15) // 1

```



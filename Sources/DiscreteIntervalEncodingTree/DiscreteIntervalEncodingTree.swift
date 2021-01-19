
import Foundation

extension DiscreteIntervalEncodingTree: Equatable {}

extension DiscreteIntervalEncodingTree: BidirectionalCollection {
    public var startIndex: Index { storage.startIndex }
    public var endIndex: Index { storage.endIndex }
    public func index(after i: Index) -> Index { storage.index(after: i) }
    public func index(before i: Index) -> Index { storage.index(before: i) }
    public func makeIterator() -> IndexingIterator<[RangeType]> { storage.makeIterator() }
    public subscript(position: Index) -> RangeType { storage[position] }
}

extension DiscreteIntervalEncodingTree: Codable where Bound: Codable {}

/**
 * http://web.engr.oregonstate.edu/~erwig/papers/Diet_JFP98.pdf
 */
public struct DiscreteIntervalEncodingTree<Bound> where Bound: Strideable {

    public typealias Index = Array<RangeType>.Index
    public typealias RangeType = ClosedRange<Bound>

    private var storage: [RangeType]

    public init() { storage = [] }
    public init(_ range: RangeType) { storage = [range] }
    public init(uncheckedOrder storage: [ClosedRange<Bound>]) { self.storage = storage }
    public init(_ rangeList: RangeType...) {
        storage = []
        rangeList.forEach { range in add(range) }
    }


    public func contains(_ value: Bound) -> Bool {
        guard let index = firstIndexWithUpperBoundAboveOrEqualTo(value) else { return false }
        return storage[index].contains(value)
    }

    public func range(containing value: Bound) -> RangeType? {
        guard let index = firstIndexWithUpperBoundAboveOrEqualTo(value) else { return nil }
        guard storage[index].contains(value) else { return nil }
        return storage[index]
    }

    public func overlaps(_ other: RangeType) -> Bool { firstIndex(overlapping: other) != nil }


    public func firstIndex(overlapping other: RangeType) -> Index? {
        guard let index = firstIndexWithUpperBoundAboveOrEqualTo(other.lowerBound),
              storage[index].overlaps(other) else { return nil }
        return index
    }

    public func first(overlapping other: RangeType) -> RangeType? {
        firstIndex(overlapping: other).map { storage[$0] }
    }

    public func lastIndex(before: Bound) -> Index? {
        lastIndexWithLowerBoundBelowOrEqualTo(before.advanced(by: -1))
    }

    public func lastIndex(overlapping other: RangeType) -> Index? {
        guard let index = lastIndexWithLowerBoundBelowOrEqualTo(other.upperBound),
              storage[index].overlaps(other) else { return nil }
        return index
    }

    public func last(overlapping other: RangeType) -> RangeType? {
        lastIndex(overlapping: other).map { storage[$0] }
    }

    public func firstIndexWithLowerBoundAboveOrEqualTo(_ value: Bound) -> Index? {
        firstSortedIndex { range in range.lowerBound >= value }
    }

    public func firstIndexWithUpperBoundAboveOrEqualTo(_ value: Bound) -> Index? {
        firstSortedIndex { range in range.upperBound >= value }
    }

    public func lastIndexWithUpperBoundBelowOrEqualTo(_ value: Bound) -> Index? {
        lastSortedIndex { range in range.upperBound <= value }
    }

    public func lastIndexWithLowerBoundBelowOrEqualTo(_ value: Bound) -> Index? {
        lastSortedIndex { range in range.lowerBound <= value }
    }

    // Binary search algorithm

    private func firstSortedIndex(where predicate: (ClosedRange<Bound>) -> (Bool)) -> Index? {
        var range = storage.indices
        var result: Index?

        while !range.isEmpty {
            let pivot = (range.lowerBound + range.upperBound) / 2
            if predicate(storage[pivot]) {
                result = pivot
                range = range.lowerBound ..< pivot
            } else {
                range = pivot.advanced(by: 1) ..< range.upperBound
            }
        }

        return result
    }

    private func lastSortedIndex(where predicate: (ClosedRange<Bound>) -> (Bool)) -> Index? {
        var range = storage.indices
        var result: Index?

        while !range.isEmpty {
            let pivot = (range.lowerBound + range.upperBound) / 2
            if predicate(storage[pivot]) {
                result = pivot
                range = pivot.advanced(by: 1) ..< range.upperBound
            } else {
                range = range.lowerBound ..< pivot
            }
        }

        return result
    }

    // MARK: - Add

    public mutating func add(_ value: Bound) {
        add(value...value)
    }

    public mutating func add(_ other: RangeType) {
        let first = firstIndexWithUpperBoundAboveOrEqualTo(other.lowerBound.advanced(by: -1))
        let last = lastIndexWithLowerBoundBelowOrEqualTo(other.upperBound.advanced(by: 1))
        let pastLast = last?.advanced(by: 1)

        let indexRangeToReplace: Range<Int> = Range(uncheckedBounds: (
            lower: first ?? pastLast ?? 0,
            upper: pastLast ?? first ?? 0
        ))

        let rangeToAdd = ClosedRange(uncheckedBounds: (
            lower: first.map { index in Swift.min(storage[index].lowerBound, other.lowerBound) } ?? other.lowerBound,
            upper: last.map { index in Swift.max(storage[index].upperBound, other.upperBound) } ?? other.upperBound
        ))

        storage.replaceSubrange(indexRangeToReplace, with: [rangeToAdd])
    }

    // MARK: - Remove

    public mutating func remove(_ value: Bound) {
        remove(value...value)
    }

    public mutating func remove(_ other: RangeType) {
        guard !self.isEmpty else { return }

        let first = firstIndexWithUpperBoundAboveOrEqualTo(other.lowerBound)
        let last = lastIndexWithLowerBoundBelowOrEqualTo(other.upperBound)
        let pastLast = last?.advanced(by: 1)

        let indexRangeToReplace: Range<Int> = Range(uncheckedBounds: (
            lower: first ?? pastLast ?? 0,
            upper: pastLast ?? first ?? 0
        ))

        var rangesToAddBack = [ClosedRange<Bound>]()

        if let first = first, storage[first].upperBound >= other.lowerBound && storage[first].lowerBound < other.lowerBound {
            let range = storage[first].lowerBound ... other.lowerBound.advanced(by: -1)
            rangesToAddBack.append(range)
        }

        if let last = last, storage[last].lowerBound <= other.upperBound && storage[last].upperBound > other.upperBound {
            let range = other.upperBound.advanced(by: 1) ... storage[last].upperBound
            rangesToAddBack.append(range)
        }

        storage.replaceSubrange(indexRangeToReplace, with: rangesToAddBack)
    }
}

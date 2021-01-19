import XCTest
@testable import DiscreteIntervalEncodingTree

final class DiscreteIntervalEncodingTreeTests: XCTestCase {

    // MARK: - Examples

    func test_examples() {
        var diet = DiscreteIntervalEncodingTree<Int>()
        XCTAssertEqual(Array(diet), []) // Array(diet) -> []

        diet.add(5)
        XCTAssertEqual(Array(diet), [5...5]) // Array(diet) -> [5...5]

        diet.add(7...10)
        XCTAssertEqual(Array(diet), [5...5, 7...10]) // Array(diet) -> [5...5, 7...10]

        diet.add(6)
        XCTAssertEqual(Array(diet), [5...10]) // Array(diet) -> [5...10]

        diet.remove(7...8)
        XCTAssertEqual(Array(diet), [5...6, 9...10]) // Array(diet) -> [5...6, 9...10]

        // O(log n) complexity for lookup on these methods

        XCTAssertTrue(diet.overlaps(-10...5))
        XCTAssertEqual(diet.first(overlapping: 10...15), 9...10)
        XCTAssertEqual(diet.firstIndex(overlapping: 10...15), 1)
    }

    // MARK: - Init

    func test_init_noArg() {
        let diet = DiscreteIntervalEncodingTree<Int>()
        XCTAssertTrue(diet.isEmpty)
    }

    func test_init_range() {
        let diet = DiscreteIntervalEncodingTree(0...10)
        XCTAssertEqual(diet.first, 0...10)
    }

    func test_init_multipleRanges() {
        let diet = DiscreteIntervalEncodingTree(0...10, 1...4, 5...20)
        XCTAssertEqual(Array(diet), [0...20])
    }

    func test_init_multipleRanges_outOfOrder() {
        let diet = DiscreteIntervalEncodingTree(1...4, 5...20, 0...10)
        XCTAssertEqual(Array(diet), [0...20])
    }

    func test_collection() {
        let diet = DiscreteIntervalEncodingTree(0...2, 4...6, 8...10)
        XCTAssertEqual(diet[1], 4...6)
        XCTAssertEqual(diet.count, 3)
        XCTAssertEqual(diet.reversed().map { $0.count }.reduce(0, +), 9)
    }

    // MARK: - Mutation

    // MARK: Add

    func test_add_outOfOrder() {
        var diet = DiscreteIntervalEncodingTree(5...10)
        diet.add(0...2)
        diet.add(-5 ... -2)
        diet.add(20...25)
        XCTAssertEqual(Array(diet), [-5 ... -2, 0...2, 5...10, 20...25])
    }

    func test_add_separateRange() {
        var diet = DiscreteIntervalEncodingTree<Int>()
        diet.add(0...1)
        diet.add(4...5)
        XCTAssertEqual(diet.map { $0 }, [0...1, 4...5])
    }

    func test_add_mergeOne() {
        var diet = DiscreteIntervalEncodingTree(0...1)
        diet.add(2)
        XCTAssertEqual(diet.first, 0...2)
    }

    func test_add_mergeNeigboringRange() {
        var diet = DiscreteIntervalEncodingTree(0...1)
        diet.add(2...10)
        XCTAssertEqual(diet.first, 0...10)
    }

    func test_add_mergeOverlappingRange() {
        var diet = DiscreteIntervalEncodingTree(0...5)
        diet.add(2...10)
        XCTAssertEqual(diet.first, 0...10)
    }

    func test_add_mergeTwoExistingNeigboringRanges() {
        var diet = DiscreteIntervalEncodingTree(0...4, 6...10)
        diet.add(5)
        XCTAssertEqual(diet.first, 0...10)
    }

    func test_add_mergeTwoExistingDistantRanges() {
        var diet = DiscreteIntervalEncodingTree(0...2, 9...10)
        diet.add(3...8)
        XCTAssertEqual(diet.first, 0...10)
    }

    func test_add_mergeMultipleExistingDistantRanges_neighborLeft() {
        var diet = DiscreteIntervalEncodingTree(0...2, 4...5, 9...10)
        diet.add(3...10)
        XCTAssertEqual(Array(diet), [0...10])
    }

    func test_add_mergeMultipleExistingDistantRanges_neighborRight() {
        var diet = DiscreteIntervalEncodingTree(0...2, 4...5, 9...10)
        diet.add(1...8)
        XCTAssertEqual(Array(diet), [0...10])
    }

    func test_add_mergeMultipleExistingDistantRanges_withUnmergedValues() {
        var diet = DiscreteIntervalEncodingTree(4...5, -10 ... -5, 0...2, 9...10, 20...50)
        diet.add(3...10)
        XCTAssertEqual(Array(diet), [-10 ... -5, 0...10, 20...50])
    }

    // MARK: - Remove

    func test_remove_rangeFromMiddle() {
        var diet = DiscreteIntervalEncodingTree(0...2, 4...5, 9...10)
        diet.remove(4...5)
        XCTAssertEqual(Array(diet), [0...2, 9...10])
    }

    func test_remove_partsFromTwoRanges() {
        var diet = DiscreteIntervalEncodingTree(0...2, 4...5, 9...10)
        diet.remove(2...4)
        XCTAssertEqual(Array(diet), [0...1, 5...5, 9...10])
    }

    func test_remove_multipleRanges() {
        var diet = DiscreteIntervalEncodingTree(0...2, 4...5, 9...10)
        diet.remove(0...9)
        XCTAssertEqual(Array(diet), [10...10])
    }

    // MARK: - Query

    func test() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertTrue(diet.contains(7))
        XCTAssertTrue(diet.contains(10))

    }
    func test_contains() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertFalse(diet.contains(3))
        XCTAssertTrue(diet.contains(4))
        XCTAssertTrue(diet.contains(7))
        XCTAssertTrue(diet.contains(10))
        XCTAssertFalse(diet.contains(11))
        XCTAssertTrue(diet.contains(12))
        XCTAssertFalse(diet.contains(13))
    }

    func test_rangeContaining() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertEqual(diet.range(containing: 4), 4...10)
        XCTAssertEqual(diet.range(containing: 2), nil)
        XCTAssertEqual(diet.range(containing: 12), 12...12)
    }

    func test_overlaps() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertFalse(diet.overlaps(0...2))
        XCTAssertTrue(diet.overlaps(10...15))
        XCTAssertTrue(diet.overlaps(12...15))
    }

    func test_firstOverlapping() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertEqual(diet.first(overlapping: 0...15), 4...10)
    }

    func test_lastOverlapping() {
        let diet = DiscreteIntervalEncodingTree(4...10, 12...12)
        XCTAssertEqual(diet.last(overlapping: 0...15), 12...12)
    }

}

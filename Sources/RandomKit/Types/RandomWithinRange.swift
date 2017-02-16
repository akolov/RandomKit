//
//  RandomWithinRange.swift
//  RandomKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2017 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

/// A type that can generate an optional random value from within a range.
public protocol RandomWithinRange: Comparable {

    /// Returns an optional random value of `Self` inside of the range using `randomGenerator`.
    static func random<R: RandomGenerator>(within range: Range<Self>, using randomGenerator: inout R) -> Self?

}

extension RandomWithinRange where Self: Strideable & Comparable, Self.Stride : SignedInteger {

    /// Returns an optional random value of `Self` inside of the range.
    public static func random<R: RandomGenerator>(within range: CountableRange<Self>,
                                                  using randomGenerator: inout R) -> Self? {
        return random(within: Range(range), using: &randomGenerator)
    }

}

extension RandomWithinRange {

    /// Returns a sequence of random values within `range` using `randomGenerator`.
    public static func randoms<R: RandomGenerator>(within range: Range<Self>, using randomGenerator: inout R) -> RandomsWithinRange<Self, R> {
        return RandomsWithinRange(range: range, randomGenerator: &randomGenerator)
    }

    /// Returns a sequence of random values limited by `limit` within `range` using `randomGenerator`.
    public static func randoms<R: RandomGenerator>(limitedBy limit: Int, within range: Range<Self>, using randomGenerator: inout R) -> LimitedRandomsWithinRange<Self, R> {
        return LimitedRandomsWithinRange(limit: limit, range: range, randomGenerator: &randomGenerator)
    }

}

/// A sequence of random values generated by a `RandomGenerator`.
///
/// - warning: An instance *should not* outlive its `RandomGenerator`.
///
/// - seealso: `LimitedRandomsWithinRange`
public struct RandomsWithinRange<Element: RandomWithinRange, RG: RandomGenerator>: IteratorProtocol, Sequence {

    /// A pointer to the `RandomGenerator`
    private let _randomGenerator: UnsafeMutablePointer<RG>

    /// The range to generate within.
    public var range: Range<Element>

    /// Creates an instance with `range` and `randomGenerator`.
    public init(range: Range<Element>, randomGenerator: inout RG) {
        _randomGenerator = UnsafeMutablePointer(&randomGenerator)
        self.range = range
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists. Once `nil` has been returned, all subsequent calls return `nil`.
    public mutating func next() -> Element? {
        return Element.random(within: range, using: &_randomGenerator.pointee)
    }

}

/// A limited sequence of random values generated by a `RandomGenerator`.
///
/// - warning: An instance *should not* outlive its `RandomGenerator`.
///
/// - seealso: `RandomsWithinRange`
public struct LimitedRandomsWithinRange<Element: RandomWithinRange, RG: RandomGenerator>: IteratorProtocol, Sequence {

    /// A pointer to the `RandomGenerator`
    private let _randomGenerator: UnsafeMutablePointer<RG>

    /// The iteration for the random value generation.
    private var _iteration: Int = 0

    /// The limit value.
    public var limit: Int

    /// The range to generate within.
    public var range: Range<Element>

    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - Complexity: O(1)
    public var underestimatedCount: Int {
        return limit
    }

    /// Creates an instance with `limit`, `range`, and `randomGenerator`.
    public init(limit: Int, range: Range<Element>, randomGenerator: inout RG) {
        _randomGenerator = UnsafeMutablePointer(&randomGenerator)
        self.limit = limit
        self.range = range
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists. Once `nil` has been returned, all subsequent calls return `nil`.
    public mutating func next() -> Element? {
        guard _iteration < limit else { return nil }
        _iteration = _iteration &+ 1
        return Element.random(within: range, using: &_randomGenerator.pointee)
    }

}

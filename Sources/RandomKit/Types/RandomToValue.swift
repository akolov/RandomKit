//
//  RandomToValue.swift
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

/// A type that can generate a random value from a base to a value.
public protocol RandomToValue {

    /// The random base from which to generate.
    static var randomBase: Self { get }

    /// Generates a random value of `Self` from `Self.randomBase` to `value` using `randomGenerator`.
    static func random<R: RandomGenerator>(to value: Self, using randomGenerator: inout R) -> Self

}

extension RandomToValue where Self: RandomWithMax {

    /// Generates a random value of `Self` from `Self.randomBase` to `Self.max` using `randomGenerator`.
    public static func randomToMax<R: RandomGenerator>(using randomGenerator: inout R) -> Self {
        return random(to: max, using: &randomGenerator)
    }

}

extension RandomToValue where Self: RandomWithMin {

    /// Generates a random value of `Self` from `Self.randomBase` to `Self.min` using `randomGenerator`.
    public static func randomToMin<R: RandomGenerator>(using randomGenerator: inout R) -> Self {
        return random(to: min, using: &randomGenerator)
    }

}

extension RandomToValue {

    /// Returns a sequence of random values to `value` using `randomGenerator`.
    public static func randoms<R: RandomGenerator>(to value: Self, using randomGenerator: inout R) -> RandomsToValue<Self, R> {
        return RandomsToValue(value: value, randomGenerator: &randomGenerator)
    }

    /// Returns a sequence of random values limited by `limit` to `value` using `randomGenerator`.
    public static func randoms<R: RandomGenerator>(limitedBy limit: Int, to value: Self, using randomGenerator: inout R) -> LimitedRandomsToValue<Self, R> {
        return LimitedRandomsToValue(limit: limit, value: value, randomGenerator: &randomGenerator)
    }

}

/// A sequence of random values generated by a `RandomGenerator`.
///
/// - warning: An instance *should not* outlive its `RandomGenerator`.
///
/// - seealso: `LimitedRandomsToValue`
public struct RandomsToValue<Element: RandomToValue, RG: RandomGenerator>: IteratorProtocol, Sequence {

    /// A pointer to the `RandomGenerator`
    private let _randomGenerator: UnsafeMutablePointer<RG>

    /// The value to generate to.
    public var value: Element

    /// Creates an instance with `value` and `randomGenerator`.
    public init(value: Element, randomGenerator: inout RG) {
        _randomGenerator = UnsafeMutablePointer(&randomGenerator)
        self.value = value
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists. Once `nil` has been returned, all subsequent calls return `nil`.
    public mutating func next() -> Element? {
        return Element.random(to: value, using: &_randomGenerator.pointee)
    }

}

/// A limited sequence of random values generated by a `RandomGenerator`.
///
/// - warning: An instance *should not* outlive its `RandomGenerator`.
///
/// - seealso: `RandomsToValue`
public struct LimitedRandomsToValue<Element: RandomToValue, RG: RandomGenerator>: IteratorProtocol, Sequence {

    /// A pointer to the `RandomGenerator`
    private let _randomGenerator: UnsafeMutablePointer<RG>

    /// The iteration for the random value generation.
    private var _iteration: Int = 0

    /// The limit value.
    public var limit: Int

    /// The value to generate to.
    public var value: Element

    /// A value less than or equal to the number of elements in
    /// the sequence, calculated nondestructively.
    ///
    /// - Complexity: O(1)
    public var underestimatedCount: Int {
        return limit
    }

    /// Creates an instance with `input`, `randomGenerator`, and `generate`.
    public init(limit: Int, value: Element, randomGenerator: inout RG) {
        _randomGenerator = UnsafeMutablePointer(&randomGenerator)
        self.limit = limit
        self.value = value
    }

    /// Advances to the next element and returns it, or `nil` if no next element
    /// exists. Once `nil` has been returned, all subsequent calls return `nil`.
    public mutating func next() -> Element? {
        guard _iteration < limit else { return nil }
        _iteration = _iteration &+ 1
        return Element.random(to: value, using: &_randomGenerator.pointee)
    }

}

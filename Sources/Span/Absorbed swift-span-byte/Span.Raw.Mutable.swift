#if Byte
public import Byte
public import Cardinal
public import Index
public import Ordinal
public import Tagged

extension Span.Raw {

    @unsafe

    public struct Mutable: Hashable, @unchecked Sendable {

        @usableFromInline
        internal let _start: UnsafeMutableRawPointer

        @usableFromInline
        internal let _count: Index<Byte>.Count

        @inlinable
        public init(start: UnsafeMutableRawPointer, count: Index<Byte>.Count) {
            unsafe self._start = start
            unsafe self._count = count
        }

        @inlinable
        @safe
        public init() {
            unsafe self._start = _emptyMutableRawSpanSentinel
            unsafe self._count = .zero
        }

        @inlinable
        public init(_ buffer: UnsafeMutableRawBufferPointer) {
            if let baseAddress = buffer.baseAddress {
                unsafe self._start = baseAddress
            } else {
                unsafe self._start = _emptyMutableRawSpanSentinel
            }
            unsafe self._count = Index<Byte>.Count(Cardinal(UInt(buffer.count)))
        }
    }
}

@usableFromInline

nonisolated(unsafe) let _emptyMutableRawSpanSentinel: UnsafeMutableRawPointer =
    UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 4096)

extension Span.Raw.Mutable {

    @inlinable
    @safe
    public var count: Index<Byte>.Count { unsafe _count }

    @inlinable
    @safe
    public var isEmpty: Bool { unsafe _count == .zero }
}

extension Span.Raw.Mutable: @unsafe Span.Mutable.`Protocol` {

    public typealias Element = Byte

    @inlinable
    @unsafe
    public var span: Swift.Span<Byte> {
        @_lifetime(borrow self)
        borrowing get {
            let typed = unsafe _start.assumingMemoryBound(to: Byte.self)
            return unsafe Swift.Span(_unsafeStart: typed, count: _count)
        }
    }

    @inlinable
    @unsafe
    public var mutableSpan: Swift.MutableSpan<Byte> {
        @_lifetime(&self)
        mutating get {
            let typed = unsafe _start.assumingMemoryBound(to: Byte.self)
            return unsafe Swift.MutableSpan(_unsafeStart: typed, count: _count)
        }
    }

    @inlinable
    @_lifetime(&self)
    @unsafe
    public mutating func mutableSpan(count: Index<Byte>.Count) -> Swift.MutableSpan<Byte> {
        unsafe precondition(
            count <= _count,
            unsafe "Span.Raw.Mutable.mutableSpan(count:): count (\(Int(bitPattern: count))) exceeds span capacity (\(Int(bitPattern: _count)))"
        )
        let typed = unsafe _start.assumingMemoryBound(to: Byte.self)
        return unsafe Swift.MutableSpan(_unsafeStart: typed, count: count)
    }
}

extension Span.Raw.Mutable {

    @inlinable
    @unsafe
    public mutating func copy(from source: Span.Raw) {
        unsafe precondition(
            source.count <= _count,
            unsafe "Span.Raw.Mutable.copy(from:): source count (\(Int(bitPattern: source.count))) exceeds destination capacity (\(Int(bitPattern: _count)))"
        )
        unsafe base.nullable.copyMemory(from: source.base.nullable)
    }

    @inlinable
    @unsafe
    public mutating func copy(from source: UnsafeRawBufferPointer) {
        unsafe precondition(
            source.count <= Int(bitPattern: _count),
            unsafe "Span.Raw.Mutable.copy(from:): source count (\(source.count)) exceeds destination capacity (\(Int(bitPattern: _count)))"
        )
        unsafe base.nullable.copyMemory(from: source)
    }
}

extension Span.Raw.Mutable {

    @inlinable
    @unsafe
    public func withRebound<T, Result, E: Swift.Error>(
        to type: T.Type,
        _ body: (UnsafeMutableBufferPointer<T>) throws(E) -> Result
    ) throws(E) -> Result {
        try unsafe base.nullable.withMemoryRebound(to: type) { typedBuffer throws(E) in
            try unsafe body(typedBuffer)
        }
    }
}

extension Span.Raw.Mutable {

    @inlinable
    @unsafe
    public var immutable: Span.Raw {
        unsafe Span<Byte>.Raw(start: UnsafeRawPointer(_start), count: _count)
    }
}

extension Span.Raw.Mutable: CustomStringConvertible {

    public var description: String {
        let address = unsafe UInt(bitPattern: _start)
        return
            unsafe "Span.Raw.Mutable(start: 0x\(String(address, radix: 16)), count: \(Int(bitPattern: _count)))"
    }
}

extension Span.Raw.Mutable: CustomDebugStringConvertible {

    public var debugDescription: String {
        let address = unsafe UInt(bitPattern: _start)
        return
            unsafe "Span.Raw.Mutable(start: 0x\(String(address, radix: 16)), count: \(Int(bitPattern: _count)))"
    }
}

extension Span.Raw.Mutable {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        unsafe lhs._start == rhs._start && lhs._count == rhs._count
    }
}

extension Span.Raw.Mutable {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        unsafe hasher.combine(_start)
        unsafe hasher.combine(_count)
    }
}
#endif

#if Byte
public import Byte
public import Cardinal
internal import Cardinal
public import Index
public import Ordinal
public import Tagged

@usableFromInline

nonisolated(unsafe) let _emptyRawSpanSentinel: UnsafeRawPointer =
    UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 4096))

extension __Span {

    @unsafe

    public struct Raw: Hashable, @unchecked Sendable {

        @usableFromInline
        internal let _start: UnsafeRawPointer

        @usableFromInline
        internal let _count: Index<Byte>.Count

        @inlinable
        public init(start: UnsafeRawPointer, count: Index<Byte>.Count) {
            unsafe self._start = start
            unsafe self._count = count
        }

        @inlinable
        @safe
        public init() {
            unsafe self._start = _emptyRawSpanSentinel
            unsafe self._count = .zero
        }

        @inlinable
        public init(_ buffer: UnsafeRawBufferPointer) {
            if let baseAddress = buffer.baseAddress {
                unsafe self._start = baseAddress
            } else {
                unsafe self._start = _emptyRawSpanSentinel
            }
            unsafe self._count = Index<Byte>.Count(Cardinal(UInt(buffer.count)))
        }
    }
}

extension Span.Raw {

    @inlinable
    @safe
    public var count: Index<Byte>.Count { unsafe _count }

    @inlinable
    @safe
    public var isEmpty: Bool { unsafe _count == .zero }
}

extension Span.Raw: @unsafe Span.`Protocol` {

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
}

extension Span.Raw {

    @inlinable
    @unsafe
    public func withRebound<T, Result, E: Swift.Error>(
        to type: T.Type,
        _ body: (UnsafeBufferPointer<T>) throws(E) -> Result
    ) throws(E) -> Result {
        try unsafe base.nullable.withMemoryRebound(to: type) { typedBuffer throws(E) in
            try unsafe body(typedBuffer)
        }
    }
}

extension Span.Raw: CustomStringConvertible {

    public var description: String {
        let address = unsafe UInt(bitPattern: _start)
        return unsafe "Span.Raw(start: 0x\(String(address, radix: 16)), count: \(Int(bitPattern: _count)))"
    }
}

extension Span.Raw: CustomDebugStringConvertible {

    public var debugDescription: String {
        let address = unsafe UInt(bitPattern: _start)
        return unsafe "Span.Raw(start: 0x\(String(address, radix: 16)), count: \(Int(bitPattern: _count)))"
    }
}

extension Span.Raw {

    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        unsafe lhs._start == rhs._start && lhs._count == rhs._count
    }
}

extension Span.Raw {

    @inlinable
    public func hash(into hasher: inout Hasher) {
        unsafe hasher.combine(_start)
        unsafe hasher.combine(_count)
    }
}
#endif

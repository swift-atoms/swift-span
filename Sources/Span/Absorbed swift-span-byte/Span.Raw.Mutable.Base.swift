#if Byte
public import Cardinal

extension Span.Raw.Mutable {

    @unsafe
    public struct Base {
        @usableFromInline
        internal let _parent: Span.Raw.Mutable

        @inlinable
        package init(_ parent: Span.Raw.Mutable) {
            unsafe self._parent = unsafe parent
        }
    }

    @inlinable
    @unsafe
    public var base: Base { unsafe Base(self) }
}

extension Span.Raw.Mutable.Base {

    @inlinable
    public var nullable: UnsafeMutableRawBufferPointer {
        if unsafe _parent.isEmpty {
            return unsafe UnsafeMutableRawBufferPointer(start: nil, count: 0)
        }
        return unsafe UnsafeMutableRawBufferPointer(
            start: _parent._start,
            count: Int(bitPattern: _parent._count)
        )
    }

    @inlinable
    public var nonNull: UnsafeMutableRawBufferPointer {
        unsafe UnsafeMutableRawBufferPointer(
            start: _parent._start,
            count: Int(bitPattern: _parent._count)
        )
    }
}
#endif

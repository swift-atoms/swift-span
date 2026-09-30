#if Byte
public import Cardinal

extension Span.Raw {

    @unsafe
    public struct Base {
        @usableFromInline
        internal let _parent: Span.Raw

        @inlinable
        package init(_ parent: Span.Raw) {
            unsafe self._parent = unsafe parent
        }
    }

    @inlinable
    @unsafe
    public var base: Base { unsafe Base(self) }
}

extension Span.Raw.Base {

    @inlinable
    public var nullable: UnsafeRawBufferPointer {
        if unsafe _parent.isEmpty {
            return unsafe UnsafeRawBufferPointer(start: nil, count: 0)
        }
        return unsafe UnsafeRawBufferPointer(
            start: _parent._start,
            count: Int(bitPattern: _parent._count)
        )
    }

    @inlinable
    public var nonNull: UnsafeRawBufferPointer {
        unsafe UnsafeRawBufferPointer(
            start: _parent._start,
            count: Int(bitPattern: _parent._count)
        )
    }
}
#endif

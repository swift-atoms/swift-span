# swift-span

Use this package when your type lends its contiguous storage as a `Swift.Span` and you want generic code to accept it alongside a plain span or an array. Conform to `Span.Protocol`, or to `Span.Mutable.Protocol` when the storage can also be written. For an untyped region of bytes given by an address and a length, such as memory handed to or from a system call, use `Span.Raw` or `Span.Raw.Mutable`, which come with the `Byte` trait.

## Laws

- `Swift.Span` conforms to `Span.Protocol` by vending itself, and `Swift.Array` conforms by vending its own span.
- `Span.Raw` and `Span.Raw.Mutable` describe memory without owning it: a start address and a byte count. Copying one copies those two values. Nothing is allocated, retained, initialized, bound or freed, and nothing records how long the memory stays valid.
- An empty descriptor, made with no arguments or from a buffer with no base address, points at one shared sentinel address. Its `Span.Raw.Base.nullable` buffer has a nil base address. Its `Span.Raw.Base.nonNull` buffer has the sentinel, which must never be read or written.
- Two descriptors are equal, and hash alike, when their start address and byte count are equal. The bytes are not compared.
- The spans a descriptor vends view the memory as bytes and assume it is already bound to `Byte`. `Span.Raw.withRebound(to:_:)` and `Span.Raw.Mutable.withRebound(to:_:)` rebind it to another type only for the duration of the closure.
- `Span.Raw.Mutable.mutableSpan(count:)` traps when the count is larger than the descriptor's. `Span.Raw.Mutable.copy(from:)` traps when the source is larger than the destination. Otherwise it writes the source's bytes at the start of the destination and leaves the rest unchanged.
- A descriptor is `Sendable` because its two fields never change. That says nothing about whether the bytes it describes may be used from two places at once.
- With the `Iterator` trait, a conformer that is also `Iterable` iterates its span in chunks. Each iterator borrows the storage on its own, so two iterators over one value advance independently.

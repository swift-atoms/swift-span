# swift-span

## Raw descriptors: `Span.Raw` and `Span.Raw.Mutable` (trait `Byte`)

`Span.Raw` and `Span.Raw.Mutable` are non-owning descriptors: a start address and a byte count (`Index<Byte>.Count`). Copying a descriptor copies those two values only. A descriptor does not allocate, retain, initialise, bind or free the memory it describes, and nothing in the type records how long that memory stays valid. Both types are `@unsafe`; every member that reaches the described bytes is `@unsafe` as well.

### What is safe

- `init()` creates an empty descriptor: count zero, start set to a module-private sentinel address. `init(_:)` with a buffer whose `baseAddress` is `nil` produces the same empty descriptor.
- `count` and `isEmpty` read the descriptor's own fields and are `@safe`.
- An empty descriptor never reads or writes memory through its views; its start address is a sentinel and must never be dereferenced through `base.nonNull`.
- `Sendable`: a descriptor may be copied into another isolation domain because its two stored fields are immutable. That says nothing about the bytes it points at: sending a descriptor does not make the described memory safe to access concurrently.

### Preconditions for a non-empty descriptor

The caller is responsible for all of the following. None of them is checked unless stated.

- Allocation and lifetime: `[start, start + count)` is one allocated region and stays allocated for as long as any use described below is in progress.
- Initialisation: bytes read through `span`, `mutableSpan`, `withRebound` or `copy(from:)` (as source) are initialised.
- Binding: `span`, `mutableSpan` and `mutableSpan(count:)` view the region as `Byte` (`assumingMemoryBound(to: Byte.self)`); the region must be bound to `Byte`, not to another type.
- Alignment and size for `withRebound(to:_:)`: it rebinds the region to `T` for the duration of the closure (`withMemoryRebound(to:)`), so the start must be aligned for `T` and the byte count must fit whole `T` values as that API requires. The typed buffer is valid only inside the closure and must not escape it.
- Count: `mutableSpan(count:)` requires `count <= self.count` and `copy(from:)` requires `source.count <= self.count`; both are checked with `precondition` and trap otherwise. `copy(from:)` writes `source.count` bytes at the start of the destination and leaves the rest unchanged.
- Overlap: `copy(from:)` is implemented with `copyMemory(from:)`. Use it only for non-overlapping source and destination regions; overlapping copies are not part of this API's contract.
- Aliasing: while a `Span.Raw.Mutable` is being written (through `mutableSpan`, `withRebound` or `copy(from:)`), no other code may read or write the same bytes, including through other descriptors or copies of this one. While a `Span.Raw` is being read, no other code may write the same bytes.

### How long the memory must stay valid

- Views (`span`, `mutableSpan`, `mutableSpan(count:)`): for as long as the returned `Span` / `MutableSpan` is used.
- Callbacks (`withRebound`): for the duration of the closure.
- Operations that take a descriptor (in this package or in packages that accept one): from the call until the operation returns or throws. For an `async` operation that includes every suspension, and cancellation does not end the obligation: the memory must remain valid, and exclusively reserved as described above, until the operation has actually returned or thrown, not merely until cancellation was requested. At most one in-flight operation should use a given region unless the operation documents otherwise.
- Whether a particular consumer's backend has finished with the memory when it returns is that consumer's contract; this package makes no claim about any backend.

### Diagnostics are opt-in

Marking these types `@unsafe` makes the compiler ask for an explicit `unsafe` at each use only in code built with strict memory safety enabled (`.strictMemorySafety()`). Without that setting there are no diagnostics, and in no configuration does the compiler check the preconditions above. They are the caller's obligation.

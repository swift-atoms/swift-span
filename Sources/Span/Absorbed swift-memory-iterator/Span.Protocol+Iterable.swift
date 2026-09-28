#if Iterator
public import Iterator
extension Span.`Protocol` where Self: Iterable, Self: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(borrow self)
    public borrowing func makeIterator() -> Iterator::Iterator.Chunk<Element> {
        Iterator::Iterator.Chunk(span)
    }
}
#endif

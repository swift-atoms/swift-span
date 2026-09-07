public import Index
public import Ordinal

extension __Span.Mutable {

    public protocol `Protocol`: Span.`Protocol`, ~Copyable {

        var mutableSpan: Swift.MutableSpan<Element> { @_lifetime(&self) mutating get }

        @_lifetime(&self)
        mutating func mutableSpan(count: Index<Element>.Count) -> Swift.MutableSpan<Element>
    }
}

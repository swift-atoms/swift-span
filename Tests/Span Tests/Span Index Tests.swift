import Cardinal
import Index
import Ordinal
import Span
import Testing

@Suite
struct `Span Index Tests` {

    @Test
    func `MutableSpan Protocol aliases the seam contract`() {
        #expect(requiresMutableSpanProtocol(Fixture.self))
    }

    @Test
    func `mutableSpan exposes full mutable storage`() {
        var fixture = Fixture()
        do {
            var span = fixture.mutableSpan
            #expect(span.count == 3)
            span[1] = 42
        }
        #expect(fixture.span[1] == 42)
    }

    @Test
    func `typed count limits the mutable view`() {
        var fixture = Fixture()
        let count = Index<Int>.Count(_unchecked: Cardinal(2))
        do {
            var prefix = fixture.mutableSpan(count: count)
            #expect(prefix.count == 2)
            prefix[1] = 7
        }
        #expect(fixture.span[1] == 7)
    }
}

private func requiresMutableSpanProtocol<
    S: Swift.MutableSpan<Int>.`Protocol` & ~Copyable
>(
    _: S.Type
) -> Bool {
    true
}

@safe
private struct Fixture: ~Copyable, Swift.MutableSpan<Int>.`Protocol` {

    private let storage: UnsafeMutablePointer<Int>

    init() {
        let storage = UnsafeMutablePointer<Int>.allocate(capacity: 3)
        unsafe storage.initialize(repeating: 0, count: 3)
        unsafe (self.storage = storage)
    }

    deinit {
        unsafe storage.deinitialize(count: 3)
        unsafe storage.deallocate()
    }

    var span: Swift.Span<Int> {
        @_lifetime(borrow self)
        borrowing get {
            unsafe Span(_unsafeStart: storage, count: 3)
        }
    }

    var mutableSpan: Swift.MutableSpan<Int> {
        @_lifetime(&self)
        mutating get {
            unsafe MutableSpan(_unsafeStart: storage, count: 3)
        }
    }

    @_lifetime(&self)
    mutating func mutableSpan(count: Index<Int>.Count) -> Swift.MutableSpan<Int> {
        let length = min(3, Int(count.underlying.rawValue))
        return unsafe MutableSpan(_unsafeStart: storage, count: length)
    }
}

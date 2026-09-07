import Index
import Ordinal
import Span
import Span_Test_Support
import Testing

@Suite struct `Span protocols lend owned and borrowed contiguous storage` {
    @Suite struct `Span conformers preserve borrowed views and element capabilities` {}
    @Suite struct `Span protocols preserve empty and single element regions` {}
    @Suite struct `Generic span algorithms read owned mutable and borrowed regions` {}
    @Suite(.serialized) struct `No span protocol performance cases are defined` {}
}

extension `Span protocols lend owned and borrowed contiguous storage` {

    struct Owned: Span.`Protocol` {
        var storage: [Int]
        init(_ storage: [Int]) { self.storage = storage }
    }

    struct Mutable: Span.Mutable.`Protocol` {
        var storage: [Int]
        init(_ storage: [Int]) { self.storage = storage }
    }

    struct Token: ~Copyable {
        let id: Int
        init(_ id: Int) { self.id = id }
    }

    struct Tokens: ~Copyable, Span.`Protocol` {
        var storage: InlineArray<3, Token>
        init(_ storage: consuming InlineArray<3, Token>) { self.storage = storage }
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.Owned {
    typealias Element = Int

    var span: Swift.Span<Int> {
        @_lifetime(borrow self) get { storage.span }
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.Mutable {
    typealias Element = Int

    var span: Swift.Span<Int> {
        @_lifetime(borrow self) get { storage.span }
    }
    var mutableSpan: Swift.MutableSpan<Int> {
        mutating get { storage.mutableSpan }
    }

    @_lifetime(&self)
    mutating func mutableSpan(count: Index<Int>.Count) -> Swift.MutableSpan<Int> {
        storage.mutableSpan
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.Tokens {
    typealias Element = `Span protocols lend owned and borrowed contiguous storage`.Token

    var span: Swift.Span<`Span protocols lend owned and borrowed contiguous storage`.Token> {
        @_lifetime(borrow self) get { storage.span }
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.`Span conformers preserve borrowed views and element capabilities` {

    @Test
    func `owned struct conforms to Span Protocol and vends span`() {
        let region = `Span protocols lend owned and borrowed contiguous storage`.Owned([10, 20, 30])
        let span = region.span
        #expect(span.count == 3)
        #expect(span[0] == 10)
        #expect(span[2] == 30)
    }

    @Test
    func `owned struct conforms to Span Mutable Protocol and vends mutableSpan`() {
        var region = `Span protocols lend owned and borrowed contiguous storage`.Mutable([1, 2, 3])
        do {
            var m = region.mutableSpan
            #expect(m.count == 3)
            m[0] = 99
        }
        let span = region.span
        #expect(span[0] == 99)
        #expect(span[1] == 2)
    }

    @Test
    func `bare Swift Span of UInt8 satisfies Span Protocol and round-trips bytes`() {
        let bytes: [UInt8] = [0xDE, 0xAD, 0xBE, 0xEF]
        let span: Swift.Span<UInt8> = bytes.span

        let vended = span.span
        #expect(vended.count == 4)
        #expect(vended[0] == 0xDE)
        #expect(vended[1] == 0xAD)
        #expect(vended[2] == 0xBE)
        #expect(vended[3] == 0xEF)
    }

    @Test
    func `~Copyable element owned region conforms to Span Protocol`() {
        let region = `Span protocols lend owned and borrowed contiguous storage`.Tokens(
            InlineArray<3, `Span protocols lend owned and borrowed contiguous storage`.Token> { `Span protocols lend owned and borrowed contiguous storage`.Token($0 + 1) }
        )
        let span = region.span
        #expect(span.count == 3)
        #expect(span[0].id == 1)
        #expect(span[2].id == 3)
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.`Span protocols preserve empty and single element regions` {

    @Test
    func `empty Swift Span satisfies Span Protocol with zero count`() {
        let empty: [UInt8] = []
        let span: Swift.Span<UInt8> = empty.span
        let vended = span.span

        let count = vended.count
        let isEmpty = vended.isEmpty
        #expect(count == 0)
        #expect(isEmpty)
    }

    @Test
    func `single-element owned region vends length-one span`() {
        let region = `Span protocols lend owned and borrowed contiguous storage`.Owned([42])
        let span = region.span
        #expect(span.count == 1)
        #expect(span[0] == 42)
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.`Generic span algorithms read owned mutable and borrowed regions` {

    static func sum<R: Span.`Protocol` & ~Copyable>(_ region: borrowing R) -> Int
    where R.Element == Int {
        let span = region.span
        var total = 0

        for i in 0..<span.count { total += span[i] }
        return total
    }

    static func firstByte<R: Span.`Protocol` & ~Copyable & ~Escapable>(
        _ region: borrowing R
    ) -> UInt8? where R.Element == UInt8 {
        let span = region.span
        return span.isEmpty ? nil : span[0]
    }

    @Test
    func `generic over Span Protocol sums an owned region`() {
        let region = `Span protocols lend owned and borrowed contiguous storage`.Owned([5, 7, 11])
        #expect(Self.sum(region) == 23)
    }

    @Test
    func `generic over Span Protocol sums a mutable region after edit`() {
        var region = `Span protocols lend owned and borrowed contiguous storage`.Mutable([1, 1, 1])
        do {
            var m = region.mutableSpan
            m[2] = 8
        }

        #expect(Self.sum(region) == 10)
    }

    @Test
    func `generic over suppressed Span Protocol reads first byte of a bare span`() {
        let bytes: [UInt8] = [0x7F, 0x00]
        let span: Swift.Span<UInt8> = bytes.span
        #expect(Self.firstByte(span) == 0x7F)
    }
}

extension `Span protocols lend owned and borrowed contiguous storage`.`No span protocol performance cases are defined` {}

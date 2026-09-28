#if Iterator
import Cardinal
import Iterator
import Span
import Testing

private struct BorrowedBuffer<Element: ~Copyable>: ~Copyable, ~Escapable, Span::__Span.`Protocol`, Iterable {
    let storage: Swift.Span<Element>
    typealias Iterator = Iterator::Iterator.Chunk<Element>

    @_lifetime(copy storage)
    init(_ storage: Swift.Span<Element>) { self.storage = storage }

    var span: Swift.Span<Element> {
        @_lifetime(borrow self) borrowing get { storage }
    }
}

@Suite struct `Memory Iterator Tests` {
    @Test func chunkingAndZeroDemandPreserveProgress() {
        let values = [10, 20, 30]
        let buffer = BorrowedBuffer(values.span)
        var iterator = buffer.makeIterator()
        let initiallyEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(initiallyEmpty)
        do {
            let first = iterator.next(maximumCount: Cardinal(2))
            #expect(first.count == 2)
            #expect(first[0] == 10 && first[1] == 20)
        }
        do {
            let tail = iterator.next(maximumCount: Cardinal.max)
            #expect(tail.count == 1)
            #expect(tail[0] == 30)
        }
        let exhausted = iterator.next(maximumCount: Cardinal.one).isEmpty
        #expect(exhausted)
    }

    @Test func emptyStorageStaysExhausted() {
        let values: [Int] = []
        let buffer = BorrowedBuffer(values.span)
        var iterator = buffer.makeIterator()
        let empty = iterator.next(maximumCount: Cardinal.max).isEmpty
        #expect(empty)
        #expect(iterator.next() == nil)
    }

    @Test func independentIteratorsBorrowSameSource() {
        let values = [10, 20, 30]
        let buffer = BorrowedBuffer(values.span)
        var first = buffer.makeIterator()
        var second = buffer.makeIterator()
        #expect(first.next() == 10)
        #expect(first.next() == 20)
        #expect(second.next() == 10)
        #expect(first.next() == 30)
        #expect(second.next() == 20)
    }

    @Test func noncopyableElementsAreBorrowedInChunks() {
        let values: InlineArray<2, OwnedValue> = [OwnedValue(value: 17), OwnedValue(value: 23)]
        let buffer = BorrowedBuffer(values.span)
        var iterator = buffer.makeIterator()
        do {
            let chunk = iterator.next(maximumCount: Cardinal.max)
            #expect(chunk.count == 2)
            #expect(chunk[0].value == 17)
            #expect(chunk[1].value == 23)
        }
        let empty = iterator.next(maximumCount: Cardinal.one).isEmpty
        #expect(empty)
    }
}

private struct OwnedValue: ~Copyable { let value: Int }
#endif

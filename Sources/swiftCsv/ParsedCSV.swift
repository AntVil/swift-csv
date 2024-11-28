public final class ParsedCSV: Sendable {
    private let values: ContiguousArray<Substring>
    public let hasHeaderRow: Bool
    public let columnCount: Int

    /// Number of rows including header row
    public var rowCount: Int {
        guard columnCount != 0 else {
            return 0
        }
        return self.values.count / self.columnCount
    }

    /// Total count of values (all rows with header * all columns)
    public var count: Int {
        return self.values.count
    }

    public var header: [Substring]? {
        guard hasHeaderRow else {
            return nil
        }
        guard values.count >= columnCount else {
            return []
        }
        return values[0 ..< columnCount].map { $0 }
    }

    public subscript(column column: Int) -> [Substring] {
        if self.hasHeaderRow {
            return stride(from: column + columnCount, to: self.values.count, by: self.columnCount).map { self.values[$0] }
        } else {
            return stride(from: column, to: self.values.count, by: self.columnCount).map { self.values[$0] }
        }
    }

    public init(from csv: String, hasHeaderRow: Bool = true, rowSeparator: Character = "\n", columnSeparator: Character = ",", escapeStart: Character = "\"", escapingEnd: Character = "\\", escapeEnd: Character = "\"", trimCharacter: Character = " ") throws {
        enum State {
            case preValuePadding
            case readingValue
            case readEscapedStart
            case readingEscapingEnd
            case readingEscapedValue
            case postValuePadding
            case postValuePaddingUnaccounted
        }

        var startSubStringIndex = csv.startIndex
        var endSubStringIndex = csv.startIndex
        var state = State.preValuePadding

        var table = TableBuilder(expectedTotalValueCount: csv.count / 5)

        for (index, character) in zip(csv.indices, csv) {
            switch state {
            case .preValuePadding:
                if character == rowSeparator {
                    let value = Substring()
                    try table.addRow(value)
                } else if character == columnSeparator {
                    let value = Substring()
                    try table.addColumn(value)
                } else if character == escapeStart {
                    state = .readEscapedStart
                } else if character != trimCharacter {
                    startSubStringIndex = index
                    state = .readingValue
                }
            case .readingValue:
                if character == rowSeparator {
                    let value = csv[startSubStringIndex ..< index]
                    try table.addRow(value)
                    state = .preValuePadding
                } else if character == columnSeparator {
                    let value = csv[startSubStringIndex ..< index]
                    try table.addColumn(value)
                    state = .preValuePadding
                } else if character == trimCharacter {
                    endSubStringIndex = index
                    state = .postValuePaddingUnaccounted
                }
            case .readEscapedStart:
                if character == escapingEnd {
                    state = .readingEscapingEnd
                    startSubStringIndex = index
                } else if character == escapeEnd {
                    let value = Substring()
                    table.addValue(value)
                    state = .postValuePadding
                } else {
                    state = .readingEscapedValue
                    startSubStringIndex = index
                }
            case .readingEscapedValue:
                if character == escapingEnd {
                    state = .readingEscapingEnd
                } else if character == escapeEnd {
                    let value = Self.resolveEscaping(value: csv[startSubStringIndex ..< index], escapingEnd: escapingEnd, escapeEnd: escapeEnd)
                    table.addValue(value)
                    state = .postValuePadding
                }
            case .readingEscapingEnd:
                if character != escapeEnd && character != escapingEnd {
                    throw CSVParserError.corruptedCsv
                }
                state = .readingEscapedValue
            case .postValuePadding:
                if character == rowSeparator {
                    state = .preValuePadding
                    table.finishColumn()
                    try table.finishRow()
                } else if character == columnSeparator {
                    state = .preValuePadding
                    table.finishColumn()
                } else if character != trimCharacter {
                    throw CSVParserError.characterAfterEscapedCell(character: character)
                }
            case .postValuePaddingUnaccounted:
                if character == rowSeparator {
                    let value = csv[startSubStringIndex ..< endSubStringIndex]
                    try table.addRow(value)
                    state = .preValuePadding
                } else if character == columnSeparator {
                    let value = csv[startSubStringIndex ..< endSubStringIndex]
                    try table.addColumn(value)
                    state = .preValuePadding
                } else if character != trimCharacter {
                    state = .readingValue
                    continue
                }
            }
        }

        switch state {
        case .preValuePadding:
            try table.finishTable()
        case .readingValue:
            let value = csv[startSubStringIndex ..< csv.endIndex]
            try table.addRow(value)
        case .readEscapedStart:
            throw CSVParserError.unexpectedEndOfCsv
        case .readingEscapedValue:
            throw CSVParserError.unexpectedEndOfCsv
        case .readingEscapingEnd:
            throw CSVParserError.unexpectedEndOfCsv
        case .postValuePadding:
            table.finishColumn()
            try table.finishRow()
            try table.finishTable()
            break
        case .postValuePaddingUnaccounted:
            let value = csv[startSubStringIndex ..< endSubStringIndex]
            try table.addRow(value)
        }

        guard let columnCount = table.expectedColumnCount else {
            throw CSVParserError.emptyCsv
        }
        guard columnCount != 0 else {
            throw CSVParserError.emptyCsv
        }
        guard table.values.count % columnCount == 0 else {
            throw CSVParserError.corruptedCsv
        }

        self.hasHeaderRow = hasHeaderRow
        self.values = table.values
        self.columnCount = columnCount
    }

    fileprivate static func resolveEscaping(value: Substring, escapingEnd: Character, escapeEnd: Character) -> Substring {
        return value.replacing("\(escapingEnd)\(escapingEnd)", with: "\(escapingEnd)").replacing("\(escapingEnd)\(escapeEnd)", with: "\(escapeEnd)")
    }

    fileprivate struct TableBuilder {
        private(set) var values = ContiguousArray<Substring>()// [Substring]()
        private(set) var expectedColumnCount: Int?
        private var columnCount = 0

        init(expectedTotalValueCount: Int) {
            self.values.reserveCapacity(expectedTotalValueCount)
        }

        mutating func addValue(_ value: Substring) {
            self.values.append(value)
        }

        @inlinable
        mutating func finishColumn() {
            self.columnCount += 1
        }

        mutating func finishRow() throws {
            if let expectedColumnCount = self.expectedColumnCount {
                guard expectedColumnCount == columnCount else {
                    throw CSVParserError.columnCountMismatch(expected: expectedColumnCount, got: columnCount)
                }
            } else {
                guard self.columnCount > 0 else {
                    throw CSVParserError.emptyCsv
                }
                self.expectedColumnCount = self.columnCount
            }
            self.columnCount = 0
        }

        // @inline(__always)
        mutating func finishTable() throws {
            guard let lastValue = self.values.last, self.columnCount == 0 else {
                throw CSVParserError.emptyCsv
            }
            if lastValue == "" {
                _ = self.values.dropLast()
            }
        }

        // @inline(__always)
        mutating func addColumn(_ value: Substring) throws {
            self.values.append(value)
            finishColumn()
        }

        // @inline(__always)
        mutating func addRow(_ value: Substring) throws {
            self.values.append(value)
            finishColumn()
            try finishRow()
        }
    }
}

public enum CSVParserError: Error {
    case characterAfterEscapedCell(character: Character)
    case unexpectedEndOfCsv
    case emptyCsv
    case corruptedCsv
    case columnCountMismatch(expected: Int, got: Int)
}

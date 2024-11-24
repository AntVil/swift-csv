public final class ParsedCSV: Sendable {
    private let values: [Substring]
    public let hasHeaderRow: Bool
    public let columnCount: Int

    public var header: [Substring]? {
        guard hasHeaderRow else {
            return nil
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

        var table = TableBuilder()

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
            break
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
        private(set) var values = [Substring]()
        private(set) var expectedColumnCount: Int?
        private var columnCount = 0

        @inlinable
        mutating func addValue(_ value: Substring) {
            self.values.append(value)
        }

        @inlinable
        mutating func finishColumn() {
            self.columnCount += 1
        }

        @inlinable
        mutating func finishRow() throws {
            self.columnCount += 1

            if let expectedColumnCount = self.expectedColumnCount {
                guard expectedColumnCount == columnCount else {
                    throw CSVParserError.columnCountMismatch(expected: expectedColumnCount, got: columnCount)
                }
            } else {
                self.expectedColumnCount = self.columnCount
            }
            self.columnCount = 0
        }

        @inlinable
        mutating func addColumn(_ value: Substring) throws {
            self.values.append(value)
            self.finishColumn()
        }

        @inlinable
        mutating func addRow(_ value: Substring) throws {
            self.values.append(value)
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

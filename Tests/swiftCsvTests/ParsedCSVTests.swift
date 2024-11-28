import XCTest

@testable import swiftCsv

public final class ParsedCSVTests: XCTestCase {
    func testParseSingleColumn() throws {
        let csv = """
        row1
        1
        2
        3
        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 1)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 4)
    }

    func testParseSingleColumnWithNewLine() throws {
        let csv = """
        row1
        1
        2
        3

        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 1)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 4)
    }

    func testParseDoubleColumn() throws {
        let csv = """
        row1,row2
        1,4
        2,5
        3,6
        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 2)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 8)
    }

    func testParseDoubleColumnWithNewLine() throws {
        let csv = """
        row1,row2
        1,4
        2,5
        3,6

        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 2)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 8)
    }

    func testParseInconsistentColumnMiddle() throws {
        let csv = """
        row1
        1
        2,x
        3
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseInconsistentColumnMiddleEmpty() throws {
        let csv = """
        row1
        1
        2,
        3
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseInconsistentColumnEnd() throws {
        let csv = """
        row1
        1
        2
        3,x
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseInconsistentColumnEmptyEnd() throws {
        let csv = """
        row1
        1
        2
        3,
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEscapedSingleColumn() throws {
        let csv = """
        "row1"
        "1"
        "2"
        "3"
        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 1)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 4)
    }

    func testParseEscapedSingleColumnWithNewLine() throws {
        let csv = """
        "row1"
        "1"
        "2"
        "3"

        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 1)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 4)
    }

    func testParseEscapedDoubleColumn1() throws {
        let csv = """
        "row1","row2"
        "1","4"
        "2","5"
        "3","6"
        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 2)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 8)
    }

    func testParseEscapedDoubleColumnWithNewLine() throws {
        let csv = """
        "row1","row2"
        "1","4"
        "2","5"
        "3","6"

        """

        let parsedCsv = try ParsedCSV(from: csv)
        XCTAssertEqual(parsedCsv.columnCount, 2)
        XCTAssertEqual(parsedCsv.rowCount, 4)
        XCTAssertEqual(parsedCsv.count, 8)
    }

    func testParseEscapedInconsistentColumnMiddle() throws {
        let csv = """
        "row1"
        "1"
        "2","x"
        "3"
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEscapedInconsistentColumnMiddleEmpty() throws {
        let csv = """
        "row1"
        "1"
        "2",
        "3"
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEscapedInconsistentColumnEnd() throws {
        let csv = """
        "row1"
        "1"
        "2"
        "3","x"
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEscapedInconsistentColumnEmptyEnd() throws {
        let csv = """
        "row1"
        "1"
        "2"
        "3",
        """

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEmpty() throws {
        let csv = ""

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }
}

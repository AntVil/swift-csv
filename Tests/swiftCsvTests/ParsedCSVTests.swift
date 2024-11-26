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

        let _ = try ParsedCSV(from: csv)
    }

    func testParseDoubleColumn() throws {
        let csv = """
        row1,row2
        1,4
        2,5
        3,6
        """

        let _ = try ParsedCSV(from: csv)
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

    func testParseEmpty() throws {
        let csv = ""

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseEmptyLines() throws {
        let csv = "\n\n\n"

        XCTAssertThrowsError(
            try ParsedCSV(from: csv)
        )
    }

    func testParseWithFinalNewLine() throws {
        let csv = "row1\nvalue1\n"

        let _ = try ParsedCSV(from: csv)
    }

    func testParseWithoutFinalNewLine() throws {
        let csv = "row1\nvalue1"

        let _ = try ParsedCSV(from: csv)
    }
}

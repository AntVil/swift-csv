import XCTest

@testable import swiftCsv

public final class CSVDecoderTests: XCTestCase {
    func testDecode() throws {
        let csv = """
        row1,row2,row3
        1,4,7
        2,5,8
        3,6,9
        """

        struct CSV: Decodable {
            let row1: [Int]
            let row2: [Int]
            let row3: [Int]
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, [1, 2, 3])
        XCTAssertEqual(result.row2, [4, 5, 6])
        XCTAssertEqual(result.row3, [7, 8, 9])
    }

    func testDecodeNil() throws {
        let csv = """
        row1,y,row3
        1,4,7
        2,5,8
        3,6,9
        """

        struct CSV: Decodable {
            let row1: [Int]?
            let row2: [Int]?
            let row3: [Int]?
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, [1, 2, 3])
        XCTAssertEqual(result.row2, nil)
        XCTAssertEqual(result.row3, [7, 8, 9])
    }

    func testDecodeStringKeys() throws {
        let csv = """
        x,y,z
        1,4,7
        2,5,8
        3,6,9
        """

        struct CSV: Decodable {
            let row1: [Int]
            let row2: [Int]
            let row3: [Int]

            enum CodingKeys: String, CodingKey {
                case row1 = "x"
                case row2 = "y"
                case row3 = "z"
            }
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, [1, 2, 3])
        XCTAssertEqual(result.row2, [4, 5, 6])
        XCTAssertEqual(result.row3, [7, 8, 9])
    }

    func testDecodeIntKeys() throws {
        let csv = """
        x,y,z
        1,4,7
        2,5,8
        3,6,9
        """

        struct CSV: Decodable {
            let row1: [Int]
            let row2: [Int]
            let row3: [Int]

            enum CodingKeys: Int, CodingKey {
                case row1 = 0
                case row2 = 1
                case row3 = 2
            }
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, [1, 2, 3])
        XCTAssertEqual(result.row2, [4, 5, 6])
        XCTAssertEqual(result.row3, [7, 8, 9])
    }

    func testDecodeEscaped() throws {
        let csv = """
        row1,row2,row3
        1,4,7
        "2,
        3",5,8
        3,6,9
        """

        struct CSV: Decodable {
            let row1: [String]
            let row2: [Float]
            let row3: [UInt8]
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, ["1", "2,\n3", "3"])
        XCTAssertEqual(result.row2, [4, 5, 6])
        XCTAssertEqual(result.row3, [7, 8, 9])
    }

    func testDecodeEscapedEscaped() throws {
        let csv = """
        row1,row2
        a,b
        "\\"",d
        "e\\\\",f
        """

        struct CSV: Decodable {
            let row1: [String]
            let row2: [String]
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, ["a", "\"", "e\\"])
        XCTAssertEqual(result.row2, ["b", "d", "f"])
    }

    func testDecodeSingleLines() throws {
        let csv = """
        row1
        "1,4,7"
        "2,
        3"
        "3,6,9"
        """

        struct CSV: Decodable {
            let row1: [String]
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, ["1,4,7", "2,\n3", "3,6,9"])
    }

    func testDecodeOptionalColumn() throws {
        let csv = """
        row1
        1
        """

        struct CSV: Decodable {
            let row1: [String]?
            let row2: [String]?
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, ["1"])
        XCTAssertEqual(result.row2, nil)
    }

    func testDecodeOptionalValues() throws {
        let csv = """
        row1
        1

        3
        """

        struct CSV: Decodable {
            let row1: [String?]
        }

        let decoder = CSVDecoder()

        let result = try decoder.decode(CSV.self, from: csv)

        XCTAssertEqual(result.row1, ["1", nil, "3"])
    }
}

import Foundation

public struct CSVDecoder: Sendable {
    var userInfo: [CodingUserInfoKey: Sendable] = [:]
    var nilDecodingStrategy: NilDecodingStrategy = .empty
    var boolDecodingStrategy: BoolDecodingStrategy = .trueOrFalse

    func decode<T: Decodable>(_: T.Type, from csv: String) throws -> T {
        let decoder = CSVContainerDecoder(
            csv: try ParsedCSV(from: csv),
            userInfo: self.userInfo,
            options: CSVDecoderOptions(
                nilDecodingStrategy: self.nilDecodingStrategy,
                boolDecodingStrategy: self.boolDecodingStrategy
            )
        )

        return try T.init(from: decoder)
    }

    public enum NilDecodingStrategy: Sendable {
        case never
        case empty
        case custom(@Sendable (Substring) -> Bool)
    }

    public enum BoolDecodingStrategy: Sendable {
        case trueOrFalse
        case zeroOrOne
        case custom(@Sendable (Substring) -> Bool)
    }
}

fileprivate struct CSVDecoderOptions {
    let nilDecodingStrategy: CSVDecoder.NilDecodingStrategy
    let boolDecodingStrategy: CSVDecoder.BoolDecodingStrategy
}

fileprivate final class CSVContainerDecoder: Decoder, Sendable {
    let csv: ParsedCSV
    let userInfoSendable: [CodingUserInfoKey: Sendable]
    let options: CSVDecoderOptions

    let codingPath: [any CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }

    init(csv: ParsedCSV, userInfo: [CodingUserInfoKey: Sendable], options: CSVDecoderOptions) {
        self.csv = csv
        self.userInfoSendable = userInfo
        self.options = options
    }

    func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
        return KeyedDecodingContainer(CSVContainer<Key>(decoder: self))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'unkeyedContainer' for csv decoder.")
        )
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'singleValueContainer' for csv decoder.")
        )
    }
}

fileprivate struct CSVContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    let decoder: CSVContainerDecoder

    let codingPath: [any CodingKey] = []
    let allKeys: [Key] = []

    func decode(_: Bool.Type, forKey key: Key) throws -> Bool {
        throw DecodingError.typeMismatch(
            Bool.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Bool'.")
        )
    }

    func decode(_: Int.Type, forKey key: Key) throws -> Int {
        throw DecodingError.typeMismatch(
            Int.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Int'.")
        )
    }

    func decode(_: Int64.Type, forKey key: Key) throws -> Int64 {
        throw DecodingError.typeMismatch(
            Int64.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Int64'.")
        )
    }

    func decode(_: Int32.Type, forKey key: Key) throws -> Int32 {
        throw DecodingError.typeMismatch(
            Int32.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Int32'.")
        )
    }

    func decode(_: Int16.Type, forKey key: Key) throws -> Int16 {
        throw DecodingError.typeMismatch(
            Int16.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Int16'.")
        )
    }

    func decode(_: Int8.Type, forKey key: Key) throws -> Int8 {
        throw DecodingError.typeMismatch(
            Int8.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'Int8'.")
        )
    }

    func decode(_: UInt.Type, forKey key: Key) throws -> UInt {
        throw DecodingError.typeMismatch(
            UInt.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'UInt'.")
        )
    }

    func decode(_: UInt64.Type, forKey key: Key) throws -> UInt64 {
        throw DecodingError.typeMismatch(
            UInt64.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'UInt64'.")
        )
    }

    func decode(_: UInt32.Type, forKey key: Key) throws -> UInt32 {
        throw DecodingError.typeMismatch(
            UInt32.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'UInt32'.")
        )
    }

    func decode(_: UInt16.Type, forKey key: Key) throws -> UInt16 {
        throw DecodingError.typeMismatch(
            UInt16.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'UInt16'.")
        )
    }

    func decode(_: UInt8.Type, forKey key: Key) throws -> UInt8 {
        throw DecodingError.typeMismatch(
            UInt8.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'UInt8'.")
        )
    }

    func decode(_: String.Type, forKey key: Key) throws -> String {
        throw DecodingError.typeMismatch(
            String.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'String'.")
        )
    }

    func decode(_: Float.Type, forKey key: Key) throws -> Float {
        throw DecodingError.typeMismatch(
            String.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'String'.")
        )
    }

    func decode(_: Double.Type, forKey key: Key) throws -> Double {
        throw DecodingError.typeMismatch(
            String.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Expected to decode Array but got single value 'String'.")
        )
    }

    func contains(_ key: Key) -> Bool {
        return self.decoder.csv.contains(key: key)
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        return !contains(key)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try T(from: CSVColumnContainerDecoder(csv: self.decoder.csv, key: key, userInfo: self.decoder.userInfoSendable, options: self.decoder.options))
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw DecodingError.valueNotFound(
            NestedKey.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Unsupported decoding method 'nestedContainer' for csv container.")
        )
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<Any>.self,
            DecodingError.Context(codingPath: [key], debugDescription: "Unsupported decoding method 'nestedUnkeyedContainer' for csv container.")
        )
    }

    func superDecoder() throws -> Decoder {
        return self.decoder
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        guard key.stringValue == "super" && key.intValue == 0 else {
            throw DecodingError.valueNotFound(
                Decoder.self,
                DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'superDecoder' for csv container with key '\(key)'.")
            )
        }

        return self.decoder
    }
}

fileprivate final class CSVColumnContainerDecoder: Decoder, Sendable {
    let csv: ParsedCSV
    let key: any CodingKey
    let userInfoSendable: [CodingUserInfoKey: Sendable]
    let options: CSVDecoderOptions

    var codingPath: [any CodingKey] { [key] }
    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }

    init(csv: ParsedCSV, key: any CodingKey, userInfo: [CodingUserInfoKey: Sendable], options: CSVDecoderOptions) {
        self.csv = csv
        self.key = key
        self.userInfoSendable = userInfo
        self.options = options
    }

    func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'unkeyedContainer' for csv decoder.")
        )
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        return try CSVColumnContainer(decoder: self, key: self.key, options: options)
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'singleValueContainer' for csv decoder.")
        )
    }
}

fileprivate struct CSVColumnContainer: UnkeyedDecodingContainer {
    let decoder: CSVColumnContainerDecoder
    let column: [Substring]
    let key: CodingKey
    let userInfoSendable: [CodingUserInfoKey: Sendable]
    let options: CSVDecoderOptions
    var currentIndex: Int = 0

    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }
    var codingPath: [any CodingKey] { [key, CSVRowIndex(intValue: self.currentIndex)] }
    var count: Int? { column.count }
    var isAtEnd: Bool { currentIndex >= column.count }

    fileprivate struct CSVRowIndex: CodingKey {
        let intValue: Int?
        let stringValue: String

        init(intValue: Int) {
            self.intValue = intValue
            self.stringValue = "\(intValue)"
        }

        @available(*, deprecated, message: "Only present for protocol conformance")
        init(stringValue: String) {
            self.intValue = nil
            self.stringValue = stringValue
        }
    }

    init(decoder: CSVColumnContainerDecoder, key: CodingKey, options: CSVDecoderOptions) throws {
        self.decoder = decoder
        self.key = key
        self.column = try decoder.csv.getColumn(key: key)
        self.userInfoSendable = decoder.userInfoSendable
        self.options = options
    }

    mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Never.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'nil' value because already at end"))
        }

        let result: Bool
        switch self.options.nilDecodingStrategy {
        case .never: result = false
        case .empty: result = column[currentIndex] != ""
        case .custom(let function): result = function(column[currentIndex])
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Bool' value because already at end"))
        }
        let result: Bool
        switch self.options.boolDecodingStrategy {
        case .trueOrFalse:
            switch column[currentIndex] {
            case "true": result = true
            case "false": result = false
            default: throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Bool' value from \(column[currentIndex])"))
            }
        case .zeroOrOne:
            switch column[currentIndex] {
            case "1": result = true
            case "0": result = false
            default: throw DecodingError.valueNotFound(Bool.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Bool' value from \(column[currentIndex])"))
            }
        case .custom(let function):
            result = function(column[currentIndex])
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: String.Type) throws -> String {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'String' value because already at end"))
        }
        let result = String(column[currentIndex])
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Float.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Float' value because already at end"))
        }
        guard let result = Float(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Float.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Float'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Double.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Double' value because already at end"))
        }
        guard let result = Double(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Double'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Int' value because already at end"))
        }
        guard let result = Int(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Int'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int64.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Int64' value because already at end"))
        }
        guard let result = Int64(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Int64.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Int64'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int32.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Int32' value because already at end"))
        }
        guard let result = Int32(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Int32.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Int32'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int16.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Int16' value because already at end"))
        }
        guard let result = Int16(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Int16.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Int16'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Int8.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'Int8' value because already at end"))
        }
        guard let result = Int8(column[currentIndex]) else {
            throw DecodingError.typeMismatch(Int8.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'Int8'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UInt.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'UInt' value because already at end"))
        }
        guard let result = UInt(column[currentIndex]) else {
            throw DecodingError.typeMismatch(UInt.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'UInt'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UInt64.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'UInt64' value because already at end"))
        }
        guard let result = UInt64(column[currentIndex]) else {
            throw DecodingError.typeMismatch(UInt64.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'UInt64'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UInt32.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'UInt32' value because already at end"))
        }
        guard let result = UInt32(column[currentIndex]) else {
            throw DecodingError.typeMismatch(UInt32.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'UInt32'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UInt16.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'UInt16' value because already at end"))
        }
        guard let result = UInt16(column[currentIndex]) else {
            throw DecodingError.typeMismatch(UInt16.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'UInt16'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UInt8.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'UInt8' value because already at end"))
        }
        guard let result = UInt8(column[currentIndex]) else {
            throw DecodingError.typeMismatch(UInt8.self, DecodingError.Context(codingPath: [key], debugDescription: "Could not decode '\(column[currentIndex])' to 'UInt8'."))
        }
        currentIndex += 1
        return result
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode 'any Decodable' value because already at end"))
        }
        let decoder = CSVValueContainerDecoder(value: column[currentIndex], codingPath: self.codingPath, userInfo: self.userInfoSendable)
        let result = try T.init(from: decoder)
        currentIndex += 1
        return result
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw DecodingError.valueNotFound(
            Decodable.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'nestedContainer' for csv decoder.")
        )
    }

    mutating func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'nestedUnkeyedContainer' for csv decoder.")
        )
    }

    func superDecoder() throws -> Decoder {
        return decoder
    }
}

fileprivate struct CSVValueContainerDecoder: Decoder {
    let value: Substring
    let codingPath: [any CodingKey]
    let userInfoSendable: [CodingUserInfoKey: Sendable]

    var userInfo: [CodingUserInfoKey: Any] { self.userInfoSendable }

    init(value: Substring, codingPath: [any CodingKey], userInfo: [CodingUserInfoKey: Sendable]) {
        self.value = value
        self.codingPath = codingPath
        self.userInfoSendable = userInfo
    }

    func container<Key: CodingKey>(keyedBy: Key.Type) throws -> KeyedDecodingContainer<Key> {
        throw DecodingError.valueNotFound(
            Decodable.self,
            DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported decoding method 'container' for csv decoder.")
        )
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: self.codingPath, debugDescription: "Unsupported decoding method 'singleValueContainer' for csv decoder.")
        )
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        return CSVValueContainer(value: self.value, codingPath: self.codingPath)
    }
}

fileprivate struct CSVValueContainer: SingleValueDecodingContainer {
    let value: Substring
    let codingPath: [any CodingKey]

    func decodeNil() -> Bool {
        return value == ""
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return value != ""
    }

    func decode(_ type: String.Type) throws -> String {
        return String(value)
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let result = Double(self.value) else {
            throw DecodingError.typeMismatch(Double.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Double'"))
        }
        return result
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard let result = Float(self.value) else {
            throw DecodingError.typeMismatch(Float.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Float'"))
        }
        return result
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let result = Int(self.value) else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Int'"))
        }
        return result
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let result = Int8(self.value) else {
            throw DecodingError.typeMismatch(Int8.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Int8'"))
        }
        return result
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let result = Int16(self.value) else {
            throw DecodingError.typeMismatch(Int16.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Int16'"))
        }
        return result
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let result = Int32(self.value) else {
            throw DecodingError.typeMismatch(Int32.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Int32'"))
        }
        return result
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let result = Int64(self.value) else {
            throw DecodingError.typeMismatch(Int64.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'Int64'"))
        }
        return result
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        guard let result = UInt(self.value) else {
            throw DecodingError.typeMismatch(UInt.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'UInt'"))
        }
        return result
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let result = UInt8(self.value) else {
            throw DecodingError.typeMismatch(UInt8.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'UInt8'"))
        }
        return result
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let result = UInt16(self.value) else {
            throw DecodingError.typeMismatch(UInt16.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'UInt16'"))
        }
        return result
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let result = UInt32(self.value) else {
            throw DecodingError.typeMismatch(UInt32.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'UInt32'"))
        }
        return result
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let result = UInt64(self.value) else {
            throw DecodingError.typeMismatch(UInt64.self, DecodingError.Context(codingPath: [], debugDescription: "Value '\(self.value)' was not a valid 'UInt64'"))
        }
        return result
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        throw DecodingError.valueNotFound(
            Array<any Decodable>.self,
            DecodingError.Context(codingPath: [], debugDescription: "Unsupported decoding method 'singleValueContainer' for csv decoder.")
        )
    }
}

internal extension ParsedCSV {
    func contains(key: any CodingKey) -> Bool {
        if let column = key.intValue {
            return column < self.columnCount
        }

        guard let header = self.header else {
            return false
        }

        return header.contains(Substring(key.stringValue))
    }

    func getColumn(key: any CodingKey) throws -> [Substring] {
        if let column = key.intValue {
            guard column < self.columnCount else {
                throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: [], debugDescription: "Tried to access key '\(column)' which does not exist."))
            }

            return self[column: column]
        }

        guard let header = self.header else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Decoding using header not possible because no header present."))
        }
        guard let column = header.firstIndex(of: Substring(key.stringValue)) else {
            throw DecodingError.valueNotFound(String.self, DecodingError.Context(codingPath: [], debugDescription: "Tried to access key '\(key.stringValue)' which does not exist."))
        }

        return self[column: column]
    }
}

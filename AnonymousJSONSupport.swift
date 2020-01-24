import Foundation

public typealias AnonymousJSONObject   = [String:AnonymousJSONValue]
public typealias AnonymousJSONArray    = [AnonymousJSONValue]
public typealias AnonymousJSONProperty = (String, AnonymousJSONValue)

public extension AnonymousJSONObject {

    func getJsonData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    func transcode<T:Decodable>(as _:T.Type) throws -> T {
        let jsonData = try getJsonData()
        return try JSONDecoder().decode(T.self, from:jsonData)
    }
}

public enum AnonymousJSONValue: Codable, Equatable {

    public enum Errors : Error {
        case decodingError(String)
    }
    
    case `nil`
    case boolean(Bool)
    case integer(Int)
    case double(Double)
    case string(String)
    case array(AnonymousJSONArray)
    case object(AnonymousJSONObject)

    public init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()

        if container.decodeNil() { self = .nil }
 
        else if let value = try? container.decode(Bool.self)                { self = .boolean(value) }
        else if let value = try? container.decode(Int.self)                 { self = .integer(value) }
        else if let value = try? container.decode(Double.self)              { self = .double(value)  }
        else if let value = try? container.decode(String.self)              { self = .string(value)  }
        else if let value = try? container.decode(AnonymousJSONArray.self)  { self = .array(value)   }
        else if let value = try? container.decode(AnonymousJSONObject.self) { self = .object(value)  }
        
        else {
            throw Errors.decodingError("could not decode a valid JSONValue")
        }
    }

    public func encode(to encoder: Encoder) throws {

        var container = encoder.singleValueContainer()

        switch self {
            case .nil                : try container.encodeNil()
            case .boolean(let value) : try container.encode(value)
            case .integer(let value) : try container.encode(value)
            case .double (let value) : try container.encode(value)
            case .string (let value) : try container.encode(value)
            case .array  (let value) : try container.encode(value)
            case .object (let value) : try container.encode(value)
        }
    }
}

// Convenience methods

extension AnonymousJSONValue {

    public var isNil:Bool {
        return self == .nil
    }

    public var asBoolean:Bool {
        guard case let .boolean(value) = self else { preconditionFailure("Not a boolean") }
        return value
    }

    public var asInteger:Int {
        guard case let .integer(value) = self else { preconditionFailure("Not an integer") }
        return value
    }

    public var asDouble:Double {

        switch self {
            case let .double(value)  : return value
            case let .integer(value) : return Double(value)
            default                  : preconditionFailure("Not a double")
        }
    }

    public var asString:String {
        guard case let .string(value) = self else { preconditionFailure("Not a string") }
        return value
    }

    public var asArray:AnonymousJSONArray {
        guard case let .array(value) = self else { preconditionFailure("Not an array") }
        return value
    }

    subscript(index:Int) -> AnonymousJSONValue {
        return asArray[index]
    }

    public var asObject:AnonymousJSONObject {
        guard case let .object(value) = self else { preconditionFailure("Not an object") }
        return value
    }

    subscript(key:String) -> AnonymousJSONValue {
        guard let value = asObject[key] else { preconditionFailure("key not found") }
        return value
    }

    func transcode<T:Decodable>(to _:T.Type) throws -> T {
        return try asObject.transcode(as:T.self)
    }
}

// Literal Conversions

extension AnonymousJSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) { self = .boolean(value) }
}

extension AnonymousJSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) { self = .integer(value) }
}

extension AnonymousJSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) { self = .double(value) }
}

extension AnonymousJSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) { self = .string(value) }
}

extension AnonymousJSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AnonymousJSONValue...) { self = .array(elements) }
}

extension AnonymousJSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral keyValuePairs: AnonymousJSONProperty...) { 
        self = .object(Dictionary.init(uniqueKeysWithValues: keyValuePairs))
    }
}
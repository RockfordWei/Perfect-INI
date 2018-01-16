import CoreFoundation
import Foundation

public enum INICodingError: Error {
  case unsupported
  case missing
  case malformed
}

open class INIEncoder: Encoder {
  public var codingPath: [CodingKey] = []

  public var userInfo: [CodingUserInfoKey : Any] = [:]

  internal let _depth: Int

  public init() {
    _depth = 0
  }

  internal init(depth: Int = 0) {
    _depth = depth + 1
    guard _depth < 2 else {
      fatalError("INI file layout doesn't supported nested sections")
    }
  }

  func push<Key: CodingKey>(key: Key, value: Any) throws {
    guard let k = CodingUserInfoKey.init(rawValue: key.stringValue) else {
      throw INICodingError.unsupported
    }
    userInfo[k] = value
  }

  public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
    return KeyedEncodingContainer(INIWriter<Key>(self))
  }

  public func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError("unsupported unkeyedContainer")
  }

  public func singleValueContainer() -> SingleValueEncodingContainer {
    fatalError("unsupported singleValueContainer")
  }

  open func encode<T : Encodable>(_ value: T) throws -> Data {
    try value.encode(to: self)
    var data = Data()
    // only top level needs to return the printed sheet.
    guard _depth == 0 else {
      return data
    }
    var top: [String: Any] = [:]
    for (k, v) in userInfo {
      if v is [CodingUserInfoKey: Any], let dic = v as? [CodingUserInfoKey: Any] {
        data.append(contentsOf: "\n[\(k.rawValue)]\n".utf8)
        for (subk, subv) in dic {
          if subv is [CodingUserInfoKey: Any] {
            throw INICodingError.unsupported
          } else {
            data.append(contentsOf: "\(subk.rawValue) = \(subv)\n".utf8)
          }
        }
      } else {
        top[k.rawValue] = v
      }
    }
    var anonymous = Data()
    for (k, v) in top {
      anonymous.append(contentsOf: "\(k) = \(v)\n".utf8)
    }
    return anonymous + data
  }
}

fileprivate struct INIWriter<K : CodingKey>: KeyedEncodingContainerProtocol {
  typealias Key = K
  let codingPath: [CodingKey] = []
  let _p: INIEncoder

  init(_ parent: INIEncoder) {
    self._p = parent
  }

  mutating func encodeNil(forKey key: K) throws {
    throw INICodingError.unsupported
  }

  mutating func encode(_ value: Bool, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Int, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Int8, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Int16, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Int32, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Int64, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: UInt, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: UInt8, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: UInt16, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: UInt32, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: UInt64, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Float, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: Double, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode(_ value: String, forKey key: K) throws {
    try self._p.push(key: key, value: value)
  }

  mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
    let child = INIEncoder(depth: _p._depth)
    _ = try child.encode(value)
    try self._p.push(key: key, value: child.userInfo)
  }

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
    fatalError("unimplemented nestedContainer")
  }

  mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
    fatalError("unimplemented nestedUnkeyedContainer")
  }

  mutating func superEncoder() -> Encoder {
    fatalError("unimplemented superEncoder")
  }

  mutating func superEncoder(forKey key: K) -> Encoder {
    fatalError("unimplemented superEncoder forKey")
  }
}

fileprivate class Stack<T> {
  internal var array: [T] = []
  public func push(_ element: T) {
    array.append(element)
  }
  public func pop () -> T? {
    if array.isEmpty { return nil }
    let element = array.removeLast()
    return element
  }
  public func top () -> T? {
    return array.last
  }
  public var isEmpty: Bool { return array.isEmpty }
}

fileprivate class INIParser {

  var _sections: [String:Any] = [:]

  enum State {
    case title, variable, value, singleQuotation, doubleQuotation
  }

  enum ContentType {
    case section(String)
    case assignment(String, String)
  }

  internal func parse(line: String) throws -> ContentType? {
    var cache = ""
    var state = State.variable
    let stack = Stack<State>()
    var variable: String? = nil
    for c in line {
      switch c {
      case " ", "\t":
        if state == .singleQuotation || state == .doubleQuotation {
          cache.append(c)
        }
        break
      case "[":
        if state == .variable {
          cache = ""
          stack.push(state)
          state = .title
        }
        break
      case "]":
        if state == .title {
          guard let last = stack.pop() else { throw INICodingError.unsupported }
          state = last
          return ContentType.section(cache)
        }
        break
      case "=":
        if state == .variable {
          variable = cache
          cache = ""
          state = .value
        }
        break
      case "#", ";":
        if state == .value {
          if let v = variable {
            return ContentType.assignment(v, cache)
          } else {
            throw INICodingError.unsupported
          }
        } else {
          return nil
        }
      case "\"":
        if state == .doubleQuotation {
          guard let last = stack.pop() else {
            throw INICodingError.unsupported
          }
          state = last
        } else {
          stack.push(state)
          state = .doubleQuotation
        }
        cache.append(c)
        break
      case "\'":
        if state == .singleQuotation {
          guard let last = stack.pop() else {
            throw INICodingError.unsupported
          }
          state = last
        } else {
          stack.push(state)
          state = .singleQuotation
        }
        cache.append(c)
        break
      default:
        cache.append(c)
      }
    }
    guard state == .value, let v = variable else {
      throw INICodingError.unsupported
    }
    return ContentType.assignment(v, cache)
  }

  public init(_ data: Data) throws {
    guard let text = String(bytes: data, encoding: .utf8) else {
      throw INICodingError.unsupported
    }
    let lines: [String] = text.split(separator: "\n").map { String($0) }
    var title = ""
    for line in lines {
      if let content = try parse(line: line) {
        switch content {
        case .section(let newTitle):
          if newTitle.isEmpty {
            break
          }
          title = newTitle
          break
        case .assignment(let variable, let value):
          if title.isEmpty {
            _sections[variable] = value
          } else {
            if var sec = _sections[title] as? [String:Any] {
              sec[variable] = value
              _sections[title] = sec
            } else {
              _sections[title] = [variable: value]
            }
          }
          break
        }
      }
    }
  }
}
fileprivate struct INIReader<K : CodingKey>: KeyedDecodingContainerProtocol {
  var codingPath: [CodingKey] = []

  typealias Key = K

  var allKeys: [K] {
    return _p.storage.keys.map { Key(stringValue: $0)! }
  }

  let _p: INIDecoder

  public init(parent: INIDecoder) {
    _p = parent
  }
  func contains(_ key: K) -> Bool {
    return _p.storage.keys.contains(key.stringValue)
  }

  func decodeNil(forKey key: K) throws -> Bool {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    return str.isEmpty
  }

  func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    switch str.lowercased() {
    case "true": return true
    case "false": return false
    case "0": return false
    default:
      return true
    }
  }

  func decode(_ type: Int.Type, forKey key: K) throws -> Int {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Int(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Int8(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Int16(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Int32(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Int64(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = UInt(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = UInt8(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = UInt16(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = UInt32(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = UInt64(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Float.Type, forKey key: K) throws -> Float {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Float(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: Double.Type, forKey key: K) throws -> Double {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    guard let i = Double(str) else {
      throw INICodingError.malformed
    }
    return i
  }

  func decode(_ type: String.Type, forKey key: K) throws -> String {
    guard let str = _p.storage[key.stringValue] as? String else {
      throw INICodingError.missing
    }
    return str
  }

  func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
    guard let dic = _p.storage[key.stringValue] as? [String:Any] else {
      throw INICodingError.missing
    }
    let decoder = INIDecoder()
    decoder.storage = dic
    return try decoder.decode(T.self)
  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
    throw INICodingError.unsupported
  }

  func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
    throw INICodingError.unsupported
  }

  func superDecoder() throws -> Decoder {
    throw INICodingError.unsupported
  }

  func superDecoder(forKey key: K) throws -> Decoder {
    throw INICodingError.unsupported
  }
}

open class INIDecoder: Decoder {
  public var codingPath: [CodingKey] = []

  public var userInfo: [CodingUserInfoKey : Any] = [:]

  fileprivate var storage: [String: Any] = [:]
  fileprivate var parser: INIParser? = nil

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
    let reader = INIReader<Key>(parent: self)
    return KeyedDecodingContainer(reader)
  }

  public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
    fatalError("unsupported unkeyedContainer")
  }

  public func singleValueContainer() throws -> SingleValueDecodingContainer {
    fatalError("unsupported singleValueContainer")
  }

  open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let ps = try INIParser(data)
    storage = ps._sections
    parser = ps
    return try type.init(from: self)
  }
  internal func decode<T: Decodable>(_ type: T.Type) throws -> T {
    return try type.init(from: self)
  }
}

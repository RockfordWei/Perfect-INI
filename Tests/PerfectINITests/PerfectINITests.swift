import XCTest
@testable import PerfectINI
struct Person: Codable, Equatable {

  static func ==(lhs: Person, rhs: Person) -> Bool {
    return lhs.age == rhs.age && lhs.name == rhs.name
  }

  public var name = ""
  public var age = 0

}

struct Place: Codable, Equatable {
  public var location = ""
  public var history = 0
  static func ==(lhs: Place, rhs: Place) -> Bool {
    return lhs.location == rhs.location && lhs.history == rhs.history
  }
}

struct Configuration: Codable, Equatable {
  public var id = 0
  public var tag = ""
  public var person = Person()
  public var place = Place()
  static func == (lhs: Configuration, rhs: Configuration) -> Bool {
    return lhs.person == rhs.person && lhs.place == rhs.place && lhs.id == rhs.id && lhs.tag == rhs.tag
  }
}

class PerfectINITests: XCTestCase {
  func testExample() {

    let rocky = Person(name: "rocky", age: 21)
    let hongkong = Place(location: "china", history: 1000)

    let conf = Configuration(id: 101, tag: "mynotes", person: rocky, place: hongkong)
    let encoder = INIEncoder()
    do {
      let data = try encoder.encode(conf)
      let str = String(bytes: data, encoding: .utf8) ?? ""
      XCTAssertFalse(data.isEmpty)
      XCTAssertFalse(str.isEmpty)
      print(str)
      let ini = INIDecoder()
      let config = try ini.decode(Configuration.self, from: data)
      print(config)
      XCTAssertEqual(config, conf)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }


  static var allTests = [
    ("testExample", testExample),
    ]
}

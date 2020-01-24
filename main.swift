import Foundation

// TEST 1 - Heterogeneous array of anonymous JSON types

let jsonData = """
    [
        {
            "typeKey" : "car",
            "payload" : {
                "make"  : "Smart",
                "model" : "ForTwo",
                "year"  : 2016
            }
        },
        {
            "typeKey" : "boat",
            "payload" : {
                "name"  : "Titanic",
                "smokestacks" : 4
            }
        },
        {
            "typeKey" : "string",
            "payload" : "What's the ultimate answer?"
        },
        {
            "typeKey" : "int",
            "payload" : 42
        },
        "I am a string in the array, followed by an int, then a float and finally a boolean",
        1988,
        3.14,
        true
    ]
    """.data(using: .utf8)!

let randomObjects = try! JSONDecoder().decode(AnonymousJSONArray.self, from:jsonData)
print("Decoded object count: \(randomObjects.count)\n")

// TEST 2 - Random access into JSON Dom

let carProxy = randomObjects[0]["payload"] // 'payload' property of the first array item
let make = carProxy["make"].asString // Read the 'make' property as a string
print("The make of the anonymous car is: \(make)")

// TEST 3 - Transcoding to concrete types

class Car : Codable {
    let make  : String
    let model : String
    let year  : Int
}

let car = try! carProxy.transcode(to:Car.self)
print("The model from the concrete car is: \(car.model)")

// TEST 4 - Constructing anonymous JSON objects

let arr:AnonymousJSONArray = [
    [
        "typeKey":"car",
        "payload": [
            "make":"Smart",
            "model":"ForTwo",
            "year":2016
        ]
    ],
    [
        "typeKey":"boat",
        "payload": [
            "name":"Titanic",
            "smokestacks":4
        ]
    ],
    [
        "typeKey":"string",
        "payload":"What\'s the ultimate answer?"
    ],
    [
        "typeKey":"int",
        "payload":42
    ],
    "I am a string in the array, followed by an int, then a float and finally a boolean",
    1988,
    3.14,
    true
]

// Prove what was constructed is equal to the earlier json-decoded version
print("The decoded and manually constructed arrays are \(randomObjects == arr ? "Equal" : "Not equal")")

// Spit out the JSON to be sure.
let jsonEncoder = JSONEncoder()
jsonEncoder.outputFormatting = .prettyPrinted
let jsonData2 = try! jsonEncoder.encode(arr)
let jsonString = String(data:jsonData2, encoding:.utf8)!

print(jsonString)

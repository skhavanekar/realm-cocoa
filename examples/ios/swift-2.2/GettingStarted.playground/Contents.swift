//: To get this Playground running do the following:
//:
//: 1) In the scheme selector choose RealmSwift > iPhone 6s
//: 2) Press Cmd + B
//: 3) If the Playground didn't already run press the ▶︎ button at the bottom

import Foundation
import RealmSwift

//: I. Define the data entities

class Person: Object {
    dynamic var name = ""
    dynamic var age = 0
    dynamic var spouse: Person?
    let cars = List<Car>()

    override var description: String { return "Person {\(name), \(age), \(spouse?.name)}" }
}

class Car: Object {
    dynamic var brand = ""
    dynamic var name: String?
    dynamic var year = 0

    override var description: String { return "Car {\(brand), \(name), \(year)}" }
}

//: II. Init the realm file

let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

//: III. Create the objects

let car1 = Car(value: ["brand": "BMW", "year": 1980])

let car2 = Car()
car2.brand = "DeLorean"
car2.name = "Outatime"
car2.year = 1981

// people
let wife = Person()
wife.name = "Jennifer"
#if swift(>=3.0)
wife.cars.append(objectsIn: [car1, car2])
#else
wife.cars.appendContentsOf([car1, car2])
#endif
wife.age = 47

let husband = Person(value: [
    "name": "Marty",
    "age": 47,
    "spouse": wife
])

wife.spouse = husband

//: IV. Write objects to the realm

try! realm.write {
    realm.add(husband)
}

//: V. Read objects back from the realm

let favorites = ["Jennifer"]

#if swift(>=3.0)
let favoritePeopleWithSpousesAndCars = realm.allObjects(ofType: Person.self)
    .filter(using: "cars.@count > 1 && spouse != nil && name IN %@", favorites)
    .sorted(onProperty: "age")
#else
let favoritePeopleWithSpousesAndCars = realm.objects(Person.self)
    .filter("cars.@count > 1 && spouse != nil && name IN %@", favorites)
    .sorted("age")
#endif

for person in favoritePeopleWithSpousesAndCars {
    person.name
    person.age

    guard let car = person.cars.first else {
        continue
    }
    car.name
    car.brand

//: VI. Update objects

    try! realm.write {
        car.year += 1
    }
    car.year
}

//: VII. Delete objects

try! realm.write {
    #if swift(>=3.0)
    realm.deleteAllObjects()
    #else
    realm.deleteAll()
    #endif
}

#if swift(>=3.0)
realm.allObjects(ofType: Person.self).count
#else
realm.objects(Person.self).count
#endif
//: Thanks! To learn more about Realm go to https://realm.io

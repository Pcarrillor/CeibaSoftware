////
////  Post+CoreDataClass.swift
////  Ceiba Software
////
////  Created by Admin on 5/12/22.
////
////
//
//import Foundation
//import CoreData
//
//@objc(Post)
//public class Post: NSManagedObject, Decodable {
//    enum CodingKeys: String, CodingKey {
//        case id, body, title, userId
//    }
//
//    public static var managedObjectContext: NSManagedObjectContext?
//
//    required public convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//
//        body = try values.decode(String.self, forKey: CodingKeys.body)
//        id = Int16(try values.decode(Int.self, forKey: CodingKeys.id))
//        title = try values.decode(String.self, forKey: CodingKeys.title)
//        userId = Int16(try values.decode(Int.self, forKey: CodingKeys.userId))
//    }
//}

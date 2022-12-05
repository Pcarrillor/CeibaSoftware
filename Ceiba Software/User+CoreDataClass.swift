//
//  User+CoreDataClass.swift
//  Ceiba Software
//
//  Created by Admin on 5/12/22.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject, Decodable {
    
    
//    var posts: [Post]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, phone, username, email, website, posts
    }
    
    public static var managedObjectContext: NSManagedObjectContext?
    
    required public convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = Int16(try values.decode(Int.self, forKey: CodingKeys.id))
        name = try values.decode(String.self, forKey: CodingKeys.name)
        phone = try values.decode(String.self, forKey: CodingKeys.phone)
        username = try values.decode(String.self, forKey: CodingKeys.username)
        email = try values.decode(String.self, forKey: CodingKeys.email)
        website = try values.decode(String.self, forKey: CodingKeys.website)
        posts = try values.decode([Post].self, forKey: CodingKeys.posts)
    }
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
}

//
//  UserDetailView.swift
//  Ceiba Software
//
//  Created by Admin on 4/12/22.
//

import SwiftUI
import Combine
import CoreData

class CoreDataViewModel : ObservableObject {
    
    let container : NSPersistentContainer
    @Published var savedUsers : [User] = []
    @Published var savedPosts : [Post] = []
    @State var isLoading : Bool = false
    
    init() {
        container = NSPersistentContainer(name: "Ceiba")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading data \(error)")
            }
        }
        fetchUsers()
    }
    
    func requestUsers(){
        isLoading = true
        var cancellables = Set<AnyCancellable>()
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = container.viewContext
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else{
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [User].self, decoder: decoder)
            .sink { (completion) in
                print("Completion: \(completion)")
                self.isLoading = false
            } receiveValue: { returnedUsers in
                self.saveUserData()
                print (returnedUsers)
            }
            .store(in: &cancellables)
    }
    
    public func requestPosts(user: User){
        isLoading = true
        var cancellables = Set<AnyCancellable>()
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        struct UploadData: Codable {
            let userId: Int
        }
        
        let uploadDataModel = UploadData(userId: Int(user.id))
        let data = try? JSONEncoder().encode(uploadDataModel)
        
        var request = URLRequest(url: url)
        request.httpBody = data
        let decoder = JSONDecoder()
        decoder.userInfo[.managedObjectContext] = container.viewContext
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode < 300 else{
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Post].self, decoder: decoder)
            .sink { (completion) in
                print("Completion: \(completion)")
                self.isLoading = false
            } receiveValue: { returnedPosts in
                self.savedPosts = returnedPosts
                self.addPost(user:user, posts: returnedPosts)
                print (returnedPosts)
            }
            .store(in: &cancellables)
    }
    
    func fetchUsers(){
        let request = NSFetchRequest<User>(entityName: "User")
        do{
            savedUsers = try container.viewContext.fetch(request)
            if savedUsers.isEmpty{
                requestUsers()
            }
        }catch let error{
            print("Error fetching: \(error)")
        }
    }
    
//    func fetchPosts(id: Int){
//        let request = NSFetchRequest<Post>(entityName: "Post")
//        do{
//            savedPosts = try container.viewContext.fetch(request)
//            if savedUsers.first(where: {$0.id == id})!.posts == nil {
//                requestPosts(id: Int(id))
//            }
//        }catch let error{
//            print("Error fetching: \(error)")
//        }
//    }
    
    func saveUserData(){
        do{
            try container.viewContext.save()
            fetchUsers()
        }catch let error{
            print("Error saving \(error)")
        }
    }
    
    func addPost(user:User, posts: [Post]){
        let index = savedUsers.firstIndex(where: {$0.id == user.id})
        user.posts = posts
        savedUsers[index!] = user
        savePostData()
    }
    
    func savePostData(){
        do{
            try container.viewContext.save()
            
            fetchUsers()
        }catch let error{
            print("Error saving \(error)")
        }
    }
    
}

import Foundation

// MARK: - Post
public class Post: NSObject, Codable, Identifiable {
    public let userID, id: Int
    let title, body: String

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }
}


struct UserDetailView: View {
    @StateObject var vm = CoreDataViewModel()
    let user : User
    var body: some View {
        ScrollView(){
            VStack(alignment:.leading){
                Text(user.name!).font(.title).foregroundColor(Color("Green"))
                Text("Email: \(user.email!)")
                Text("Phone: \(user.phone!)")
                Divider()
                
                Text("Publicaciones").font(.title3).foregroundColor(Color("Green")).padding(.vertical)
                
                ForEach(user.posts ?? []) { info in
                    Text("- \(info.title)")
                }
            }
        }.onAppear{
            if vm.savedUsers.first(where: {$0.id == user.id})!.posts == nil {
                vm.requestPosts(user: user)
            }
//            vm.fetchPosts(id: Int(user.id))
        }
    }
    
//    func loadDetail(id : Int){
//        var cancellables = Set<AnyCancellable>()
//        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
//
//        struct UploadData: Codable {
//            let userId: Int
//        }
//
//        let uploadDataModel = UploadData(userId: id)
//        let data = try? JSONEncoder().encode(uploadDataModel)
//
//        var request = URLRequest(url: url)
//        request.httpBody = data
//        print(request)
//        URLSession.shared.dataTaskPublisher(for: url)
//            .subscribe(on: DispatchQueue.global(qos: .background))
//            .receive(on: DispatchQueue.main)
//            .tryMap { (data, response) -> Data in
//                guard let response = response as? HTTPURLResponse,
//                      response.statusCode >= 200 && response.statusCode < 300 else{
//                    throw URLError(.badServerResponse)
//                }
//                return data
//            }
//            .decode(type: [Post].self, decoder: JSONDecoder())
//            .sink { (completion) in
//                print("Completion: \(completion)")
//            } receiveValue: { returnedPosts in
//                //                    globals.isLoading = false
////                postInfo = returnedPosts
//                ForEach(returnedPosts){post in
//
//                }
//
//                print (returnedPosts)
//            }
//            .store(in: &cancellables)
//    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailView(user: User())
    }
}

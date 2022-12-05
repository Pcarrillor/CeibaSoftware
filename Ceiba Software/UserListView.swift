//
//  UserListView.swift
//  Ceiba Software
//
//  Created by Admin on 3/12/22.
//

import SwiftUI
import Combine

struct UserListView: View {
    
    @StateObject var vm = CoreDataViewModel()
    
    @State var name : String = ""
    @State var users: [User] = []
    @State var existInfo : Bool = true
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    
                    VStack {
                        TextField("User", text: $name)
                            .onChange(of: name) { newValue in
                                users = vm.savedUsers.filter({($0.name?.contains(name))!})
                                (users.count == 0 && name != "") ? (existInfo = false) : (existInfo = true)
                        }
                        Divider()
                    }.padding()
                    
                    ScrollView{
                        if existInfo {
                            ForEach((name != "") ? users : vm.savedUsers) { user in
                                VStack(alignment:.leading) {
                                    Text(user.name ?? "").font(.title3).foregroundColor(Color("Green"))
                                    Label {
                                        Text(user.phone ?? "")
                                    } icon: {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(Color("Green"))
                                    }
                                    
                                    Label {
                                        Text(user.email ?? "")
                                    } icon: {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(Color("Green"))
                                    }
                                    
                                    HStack{
                                        Spacer()
                                        NavigationLink {
                                            UserDetailView(user: user)
                                        } label: {
                                            Text("VER PUBLICACIONES")
                                                .foregroundColor(Color("Green"))
                                        }
                                    }
                                }
                                .padding()
                                .background {
                                    Rectangle().foregroundColor(.white).shadow(radius: 5)
                                }.padding()
                            }
                        }else{
                            Text("List is Empty").font(.title)
                        }
                    }
                }
            }
            
            if vm.isLoading {
                ProgressView("Cargando")
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

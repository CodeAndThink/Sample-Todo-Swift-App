//
//  NetworkManager.swift
//  BaseMVVM
//
//  Created by Lê Thọ Sơn on 4/25/20.
//  Copyright © 2020 thoson.it. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Supabase
import ObjectMapper

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

struct ApiProvider {
    //MARK: Private
    private let supabaseProvider : SupabaseClient
    
    init(mockData: Bool = false) {
        self.supabaseProvider = SupabaseClient(supabaseURL: URL(string: Configs.Network.apiSupabaseBaseUrl)!, supabaseKey: Configs.Network.apiSubabaseKey)
    }
    
    //MARK: Public Function
    func login(deviceId: String, password: String) -> Single<Token> {
        return Single.create { single in
            let task = Task {
                do {
                    let response = try await supabaseProvider.auth.signIn(email: deviceId, password: password)
                    var token = Token()
                    token.accessToken = response.accessToken
                    token.refreshToken = response.refreshToken
                    single(.success(token))
                } catch {
                    single(.error(NSError(domain: "SignInError", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to signin."])))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func register(deviceId: String, password: String) -> Single<String> {
        return Single.create { single in
            let task = Task {
                do {
                    _ = try await supabaseProvider.auth.signUp(email: deviceId, password: password)
                    single(.success("Register Successfully!"))
                } catch {
                    single(.error(NSError(domain: "RegisterError", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to register new user."])))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func getProfile() -> Single<User> {
        return Single.create { item in
            let task = Task {
                do {
                    let tempUser = User()
                    tempUser.id = "123"
                    tempUser.email = "TesterTodoApp@gmail.com"
                    item(.success(tempUser))
                } catch {
                    print("Get user profile success")
                }
            }
            return Disposables.create{
                task.cancel()
            }
        }
    }
    
    func fetchNotesForUser() -> Single<[Note]> {
        return Single.create { single in
            let task = Task {
                do {
                    let data : [Note] = try await supabaseProvider
                        .from("Notes")
                        .select()
                        .eq("date", value: Date().string(withFormat: "yyyy-MM-dd"))
                        .execute()
                        .value
                    single(.success(data))
                } catch {
                    single(.error(NSError(domain: "FetchDataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch notes."])))
                }
                
            }
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func createNote(newNote: Note) -> Single<String> {
        return Single.create { single in
            let task = Task {
                do {
                    newNote.device_id = supabaseProvider.auth.currentUser?.email
                    let response = try await supabaseProvider
                        .from("Notes")
                        .insert(newNote)
                        .execute()
                    guard response.status < 300 else {
                        single(.error(NSError(domain: "CreateError", code: response.status, userInfo: [NSLocalizedDescriptionKey: "Failed to create note."])))
                        return
                    }
                    single(.success("Create new note successfully!"))
                } catch {
                    single(.error(NSError(domain: "CreateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create note."])))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func deleteNote(noteId: Int) -> Single<String> {
        return Single.create { single in
            let task = Task {
                do {
                    let response = try await supabaseProvider
                        .from("Notes")
                        .delete()
                        .eq("id", value: noteId)
                        .execute()
                    guard response.status < 300 else {
                        single(.error(NSError(domain: "DeleteError", code: response.status, userInfo: [NSLocalizedDescriptionKey: "Failed to delete note."])))
                        return
                    }
                    single(.success("Delete note successfully!"))
                } catch {
                    single(.error(NSError(domain: "DeleteError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to delete note."])))
                }
            }
            return Disposables.create{
                task.cancel()
            }
        }
    }
    
    func updateNoteStatus(noteId: Int, status: Bool) -> Single<String> {
        return Single.create { single in
            let task = Task {
                do {
                    let updateData: [String: Bool] = ["status": status]
                    
                    let response = try await supabaseProvider
                        .from("Notes")
                        .update(updateData)
                        .eq("id", value: noteId)
                        .execute()
                    
                    guard response.status < 300 else {
                        single(.error(NSError(domain: "UpdateError", code: response.status, userInfo: [NSLocalizedDescriptionKey: "Failed to update note."])))
                        return
                    }
                    single(.success("Update note successfully!"))
                } catch {
                    single(.error(NSError(domain: "UpdateError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to update note."])))
                }
            }
            return Disposables.create{
                task.cancel()
            }
        }
    }
    
    func updateNote(newNote : Note) -> Single<String> {
        return Single.create { single in
            let task = Task {
                do {
                    let response = try await supabaseProvider
                        .from("Notes")
                        .update(newNote)
                        .eq("id", value: newNote.id)
                        .execute()
                    print(response.value)
                    guard response.status < 300 else {
                        single(.error(NSError(domain: "UpdateError", code: response.status, userInfo: [NSLocalizedDescriptionKey: "Failed to update note."])))
                        return
                    }
                    single(.success("Update note successfully!"))
                } catch {
                    print(error)
                    single(.error(NSError(domain: "UpdateError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to update note."])))
                }
            }
            return Disposables.create{
                task.cancel()
            }
        }
    }
    
    //MARK: Private Function
}

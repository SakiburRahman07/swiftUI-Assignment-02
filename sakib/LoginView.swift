import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var todos: [ToDo] = []
    @State private var newTaskName: String = ""
    @State private var errorMessage: String?

    var body: some View {
        
    }
}



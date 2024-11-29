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
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]),
                           startPoint: .top,
                           endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                if isLoggedIn {
                    VStack {
                        Text("📋 Your To-Do List")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()

                        ZStack {
                            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white.opacity(0.2)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
                                .cornerRadius(20)
                                .shadow(radius: 10)

                            List {
                                ForEach($todos) { $todo in
                                    VStack(alignment: .leading, spacing: 10) {
                                        if todo.isEditing {
                                            HStack {
                                                TextField("Edit Task", text: $todo.title)
                                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                                
                                                Button(action: {
                                                    updateTask(todo: todo)
                                                    todo.isEditing = false
                                                }) {
                                                    Text("Save")
                                                        .font(.caption)
                                                        .padding(5)
                                                        .background(Color.green)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(5)
                                                }
                                            }
                                        } else {
                                            HStack {
                                                Text("✅ \(todo.title)")
                                                    .font(.headline)

                                                Spacer()

                                                Button(action: {
                                                    todo.isEditing.toggle()
                                                }) {
                                                    Text("Edit ✏")
                                                        .font(.caption)
                                                        .padding(5)
                                                        .background(Color.blue)
                                                        .foregroundColor(.white)
                                                        .cornerRadius(5)
                                                }

                                                Button(action: {
                                                    deleteTask(todo: todo)
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.red)
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        }

                                        Text("📅 Added: \(todo.dateFormatted)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .background(Color.clear)
                            .cornerRadius(20)
                        }
                        .padding()

                        HStack {
                            TextField("Enter New Task 📋", text: $newTaskName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            Button(action: {
                                addTask(title: newTaskName)
                            }) {
                                Text("Add ➕")
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        fetchTasks()
                    }
                } else {
                    VStack(spacing: 20) {
                        Text("📋 Welcome Back!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        HStack {
                            Text("📧")
                            TextField("Email", text: $email)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        HStack {
                            Text("🔒")
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        Button(action: {
                            login()
                        }) {
                            Text("Login 🚀")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    .padding()
                }
            }
        }
        
    }
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }

    private func fetchTasks() {
        let db = Firestore.firestore()
        db.collection("ToDos").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching tasks: \(error.localizedDescription)")
                return
            }

            self.todos = snapshot?.documents.map { doc in
                ToDo(id: doc.documentID, data: doc.data())
            } ?? []
        }
    }

    private func addTask(title: String) {
        let db = Firestore.firestore()
        let newTask = [
            "Title": title,
            "DateAdded": Timestamp()
        ] as [String: Any]

        db.collection("ToDos").addDocument(data: newTask) { error in
            if let error = error {
                print("Error adding task: \(error.localizedDescription)")
            } else {
                newTaskName = ""
            }
        }
    }

    private func deleteTask(todo: ToDo) {
        let db = Firestore.firestore()
        db.collection("ToDos").document(todo.id).delete { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            } else {
                print("Task \(todo.title) deleted successfully")
            }
        }
    }


    private func updateTask(todo: ToDo) {
        let db = Firestore.firestore()
        db.collection("ToDos").document(todo.id).updateData(["Title": todo.title]) { error in
            if let error = error {
                print("Error updating task: \(error.localizedDescription)")
            } else {
                print("Task updated to \(todo.title)")
            }
        }
    }

    
}



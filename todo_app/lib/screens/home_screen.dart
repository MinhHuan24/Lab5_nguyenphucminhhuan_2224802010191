import 'package:flutter/material.dart';

import '../models/todo_model.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  final TodoService todoService =
      TodoService();

  final AuthService authService =
      AuthService();

  final titleController =
      TextEditingController();

  List<TodoModel> todos = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadTodos();
  }

  Future<void> loadTodos() async {

    final data =
        await todoService.getTodos();

    setState(() {
      todos = data;
      isLoading = false;
    });
  }

  Future<void> addTodo() async {

    if (titleController.text.isEmpty) {
      return;
    }

    bool success =
        await todoService.addTodo(
      titleController.text,
    );

    if (success) {

      titleController.clear();

      await loadTodos();
    }
  }

  void logout() async {

    await authService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Todo App"),

        actions: [

          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            Row(

              children: [

                Expanded(
                  child: TextField(
                    controller:
                        titleController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "New Todo",
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: addTodo,
                  child: const Text("Add"),
                )
              ],
            ),

            const SizedBox(height: 20),

            Expanded(

              child: isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : ListView.builder(

                      itemCount:
                          todos.length,

                      itemBuilder:
                          (context, index) {

                        final todo =
                            todos[index];

                        return Card(

                          child: ListTile(

                            title:
                                Text(todo.title),

                            trailing: Icon(

                              todo.isDone
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,

                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
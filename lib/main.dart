import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:savedata_sqflite/repository/todo_repository.dart';

void main() async {
  // Attesa per la creazione del Canale di Comunicazione tra Framework ed Embedder (parte nativa)
  WidgetsFlutterBinding.ensureInitialized();
  // Creazione istanza del Database
  final todoRepository = TodoRepository();
  // Inizializzazione del Database, stabilendo la connessione
  await todoRepository.initialize();
  // Registrazione del Singleton, per poter utilizzare il Database all'interno della HomePage
  GetIt.I.registerSingleton(todoRepository);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller che Gestisce il Testo inserito nel TextField
  final todoTextFieldController = TextEditingController();
  // Lista inizialmente Vuota che conterrà Elementi della Funzione createTodo()
  List<String> todos = [];

  @override
  void initState() {
    super.initState();

    // Accesso al Database per Mostrare i Dati Salvati
    GetIt.I.get<TodoRepository>().all().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  // Funzione che CREA Promemoria da Aggiungere alla Lista "todos"
  void createTodo() {
    // Elemento che verrà aggiunto alla lista "todos"
    final todo = todoTextFieldController.text.trim();
    // Spazio di Inserimento azzerato dopo l'Aggiunta
    todoTextFieldController.clear();

    setState(() {
      todos.add(todo);
    });
    // Accesso al Database per Salvare i Dati
    GetIt.I.get<TodoRepository>().create(todo);
  }

  // Funzione che ELIMINA Promemoria al click dell'Icona Cestino
  void removeTodo(String todo) {
    setState(() {
      todos.remove(todo);
    });
    // Accesso al Database per Eliminare i Dati
    GetIt.I.get<TodoRepository>().delete(todo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: todoTextFieldController,
          decoration: InputDecoration(
            hintText: "Cosa devi fare?",
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: createTodo,
            icon: const Icon(
              Icons.check,
            ),
          ),
        ],
      ),
      body: ListView.separated(
        // Il numero degli elementi è determinato dagli elementi presenti nella Lista todos
        itemCount: todos.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          // Come title della ListTile avremo l'Elemento della Lista todos
          title: Text(todos[index]),
          trailing: IconButton(
            // Alla pressione dell'Icona Cestino verrà eliminato l'Elemento corrispondente
            onPressed: () => removeTodo(todos[index]),
            icon: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}

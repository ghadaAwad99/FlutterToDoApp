import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  int currentIndex = 0;
  late Database db;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertToDatabase(
                titleController.text,
                dateController.text,
                timeController.text,
              ).then((value) => {});
              Navigator.pop(context);
              isBottomSheetShown = false;
            }
          } else {
            scaffoldKey.currentState?.showBottomSheet((context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.00),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.00),
                      color: Colors.grey[200],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: titleController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                                label: Text("Task Title"),
                                prefixIcon: Icon(Icons.title),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Title must not be Empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            controller: timeController,
                            keyboardType: TextInputType.datetime,
                            onTap: () {
                              showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now())
                                  .then((value) {
                                timeController.text = value!.format(context);
                              });
                            },
                            decoration: const InputDecoration(
                                label: Text("Task Time"),
                                prefixIcon: Icon(Icons.watch_later_outlined),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Time must not be Empty";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          TextFormField(
                            controller: dateController,
                            keyboardType: TextInputType.datetime,
                            onTap: () {
                              showDatePicker(
                                      context: context,
                                      lastDate: DateTime.parse('2023-01-01'),
                                      firstDate: DateTime.now(),
                                      initialDate: DateTime.now())
                                  .then((value) {
                                dateController.text =
                                    DateFormat.yMMMEd().format(value!);
                              });
                            },
                            decoration: const InputDecoration(
                                label: Text("Task Date"),
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                                border: OutlineInputBorder()),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Date must not be Empty";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
            isBottomSheetShown = true;
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.done), label: "Done"),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: "Archived"),
        ],
      ),
    );
  }

  void createDatabase() async {
    db = await openDatabase('todo.db', version: 1,
        onCreate: (database, version) {
      database
          .execute(
              'CREATE TABLE Tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('error on creating table ${error.toString()}');
      });
    });
  }

  Future insertToDatabase(String title, String date, String time) async {
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")');
      print('inserted1: $id1');
    });
  }
}

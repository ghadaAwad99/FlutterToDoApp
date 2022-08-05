import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

import '../shared/components/constants.dart';

class HomeLayout extends StatelessWidget {
  late Database db;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  /* @override
  void initState() {
    super.initState();
    createDatabase();
  }*/

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.getCubitInstance(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: ConditionalBuilder(
              condition: tasks.isNotEmpty,
              builder: (context) => cubit.screens[cubit.currentIndex],
              fallback: (context) =>
                  const Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                if (isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    insertToDatabase(
                      titleController.text,
                      dateController.text,
                      timeController.text,
                    ).then((value) => fetchTasksFromDatabase(db).then((value) {
                          Navigator.pop(context);
                          /*setState(() {
                    tasks = value;

                    isBottomSheetShown = false;
                  });*/
                        }));
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet((context) => Padding(
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
                                          timeController.text =
                                              value!.format(context);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          label: Text("Task Time"),
                                          prefixIcon:
                                              Icon(Icons.watch_later_outlined),
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
                                                lastDate: DateTime.parse(
                                                    '2023-01-01'),
                                                firstDate: DateTime.now(),
                                                initialDate: DateTime.now())
                                            .then((value) {
                                          dateController.text =
                                              DateFormat.yMMMEd()
                                                  .format(value!);
                                        });
                                      },
                                      decoration: const InputDecoration(
                                          label: Text("Task Date"),
                                          prefixIcon: Icon(
                                              Icons.calendar_today_outlined),
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
                          ))
                      .closed
                      .then((value) {
                    isBottomSheetShown = false;
                  });
                  isBottomSheetShown = true;
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeBottomNavIndex(index);
                /* setState(() {
              currentIndex = index;
            });*/
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
                BottomNavigationBarItem(icon: Icon(Icons.done), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive), label: "Archived"),
              ],
            ),
          );
        },
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
    }, onOpen: (database) {
      fetchTasksFromDatabase(database).then((value) {
        /*     setState(() {
              tasks = value;
            });*/
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

  Future<List<Map>> fetchTasksFromDatabase(db) async {
    return await db.rawQuery('SELECT * FROM Tasks');
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/components.dart';
import 'package:todo_app/shared/constants.dart';

class NewTasksScreen extends StatelessWidget {
  const NewTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) => taskItem(tasks[index]),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 1,
        color: Colors.grey[300],
      ),
      itemCount: tasks.length,
    );
  }
}

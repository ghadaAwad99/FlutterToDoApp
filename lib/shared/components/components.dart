import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget taskItem(task, context) => Dismissible(
      key: Key(task['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(children: [
          CircleAvatar(
            radius: 40,

            child: Text(
              '${task['time']}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ), //Text
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${task['title']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${task['date']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          IconButton(
            onPressed: () {
              AppCubit.getCubitInstance(context)
                  .updateDatabase(status: Constants.DONE, id: task['id']);
            },
            icon: const Icon(Icons.check_box),
            color: Colors.green,
          ),
          IconButton(
            onPressed: () {
              AppCubit.getCubitInstance(context)
                  .updateDatabase(status: Constants.ARCHIVED, id: task['id']);
            },
            icon: const Icon(Icons.archive),
            color: Colors.black45,
          ),
        ]),
      ),
      onDismissed: (direction) {
        AppCubit.getCubitInstance(context).deleteTask(task['id']);
      },
    );

Widget tasksScreenBuilder(String message, tasksList) => ConditionalBuilder(
      condition: tasksList.isNotEmpty,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => taskItem(tasksList[index], context),
        separatorBuilder: (context, index) => Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[300],
        ),
        itemCount: tasksList.length,
      ),
      fallback: (context) => Center(
          child: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 32,
        ),
      )),
    );

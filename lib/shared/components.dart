import 'package:flutter/material.dart';

Widget taskItem(task) => Padding(
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
        Column(
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
      ]),
    );

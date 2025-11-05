import 'package:flutter/material.dart';

class DeleteCompletedAction extends StatelessWidget {
  const DeleteCompletedAction({
    super.key,
    required this.hasCompleted,
    required this.onDeleteCompleted,
  });

  final bool hasCompleted;
  final Future<void> Function() onDeleteCompleted;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '删除已勾选',
      icon: Icon(
        Icons.delete_outline,
        color: hasCompleted ? null : Theme.of(context).disabledColor,
      ),
      onPressed: hasCompleted ? () async => onDeleteCompleted() : null,
    );
  }
}



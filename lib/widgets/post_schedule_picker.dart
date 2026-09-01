import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/ai_video_controller.dart';

class PostSchedulePicker extends StatelessWidget {
  final AiVideoController controller;

  const PostSchedulePicker({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          SwitchListTile(
            title: const Text(
              'Schedule for Later',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            value: controller.isScheduled.value,
            activeColor: Colors.deepPurple,
            onChanged: (val) {
              controller.isScheduled.value = val;
              if (!val) controller.scheduledDateTime.value = null;
            },
          ),
          if (controller.isScheduled.value)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.scheduledDateTime.value == null
                          ? 'No date & time selected'
                          : 'Scheduled for: ${DateFormat('yyyy-MM-dd hh:mm a').format(controller.scheduledDateTime.value!)}',
                      style: TextStyle(
                        color: controller.scheduledDateTime.value == null
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_month, size: 16),
                    label: const Text('Pick Time'),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          controller.scheduledDateTime.value = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

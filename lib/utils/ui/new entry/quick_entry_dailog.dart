import 'package:flutter/material.dart';


class QuickEntryBottomSheet extends StatelessWidget {
  const QuickEntryBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Entry',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select reason for quick entry:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickEntryOption(
            context,
            'System Malfunction',
            Icons.error_outline,
          ),
          _buildQuickEntryOption(
            context,
            'Network Issues',
            Icons.wifi_off,
          ),
          _buildQuickEntryOption(
            context,
            'Guest in Hurry',
            Icons.timer,
          ),
          _buildQuickEntryOption(
            context,
            'Other Reason',
            Icons.more_horiz,
            showTextField: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickEntryOption(
    BuildContext context,
    String title,
    IconData icon, {
    bool showTextField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          if (showTextField) {
            showCustomReasonDialog(context);
          } else {
            Navigator.pop(context);
          }
        },
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1a237e)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

}
  void showCustomReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Reason'),
        content: TextField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter custom reason...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle custom reason
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
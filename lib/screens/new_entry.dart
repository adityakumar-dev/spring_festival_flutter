import 'package:flutter/material.dart';
import 'package:spring_admin/screens/new%20entry/manual_entry.dart';
import 'package:spring_admin/screens/new%20entry/qr_code_verify.dart';

class NewEntryScreen extends StatelessWidget {
  static const String routeName = '/newEntry';

  const NewEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a237e),
        title: const Text(
          'New Entry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading:  IconButton(onPressed: ()=>Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Standard Entry Methods'),
              const SizedBox(height: 16),
              const _StandardEntryOptions(),
              const SizedBox(height: 32),
              _buildSectionTitle('Special Entry Methods'),
              const SizedBox(height: 16),
              const _SpecialEntryOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1a237e),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a237e),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.how_to_reg,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select an entry method below',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StandardEntryOptions extends StatelessWidget {
  const _StandardEntryOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EntryOptionCard(
          title: 'QR Code + Face Recognition',
          subtitle: 'Standard verification process',
          icon: Icons.qr_code_scanner,
          color: const Color(0xFF4CAF50),
          onTap: () {
            Navigator.pushNamed(context, QrCodeVerifyScreen.routeName);
          },
        ),
        const SizedBox(height: 12),
        _EntryOptionCard(
          title: 'Manual ID Entry + Face',
          subtitle: 'Enter guest ID manually',
          icon: Icons.person_search,
          color: const Color(0xFF2196F3),
          onTap: () {
            // Navigate to manual ID entry
            Navigator.pushNamed(context, ManualEntryScreen.routeName);
          },
        ),
      ],
    );
  }
}

class _SpecialEntryOptions extends StatelessWidget {
  const _SpecialEntryOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EntryOptionCard(
          title: 'Quick Entry',
          subtitle: 'Bypass verification with reason',
          icon: Icons.flash_on,
          color: const Color(0xFFFFA000),
          onTap: () => _showQuickEntryDialog(context),
        ),
        const SizedBox(height: 12),
        _EntryOptionCard(
          title: 'Group Entry',
          subtitle: 'Multiple guests at once',
          icon: Icons.group_add,
          color: const Color(0xFF9C27B0),
          onTap: () {
            Navigator.pushNamed(context, '/groupEntry');
          },
        ),
        const SizedBox(height: 12),
        _EntryOptionCard(
          title: 'Emergency Entry',
          subtitle: 'Immediate access with logging',
          icon: Icons.warning_rounded,
          color: const Color(0xFFE53935),
          onTap: () => _showEmergencyEntryDialog(context),
        ),
      ],
    );
  }

  void _showQuickEntryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _QuickEntryBottomSheet(),
    );
  }

  void _showEmergencyEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Entry'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This will bypass all verification steps. Use only in emergencies.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Emergency Reason',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle emergency entry
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Confirm Emergency Entry'),
          ),
        ],
      ),
    );
  }
}

class _EntryOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EntryOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickEntryBottomSheet extends StatelessWidget {
  const _QuickEntryBottomSheet();

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
            _showCustomReasonDialog(context);
          } else {
            // Handle quick entry with selected reason
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

  void _showCustomReasonDialog(BuildContext context) {
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
}
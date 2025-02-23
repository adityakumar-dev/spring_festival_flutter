import 'package:flutter/material.dart';
import 'package:spring_admin/screens/new%20entry/manual_entry.dart';
import 'package:spring_admin/screens/new%20entry/qr_code_verify.dart';
import 'package:spring_admin/utils/ui/new%20entry/quick_entry_dailog.dart';
import 'package:spring_admin/utils/ui/new%20entry/show_emergency_dialog.dart';

// Move color constants here, outside the class
const Color primaryColor = Color(0xFF2C3E50);
const Color secondaryTextColor = Color(0xFF757575);
const Color cardBgColor = Color(0xFFF8F9FC);
const Color accentGreen = Color(0xFF43A047);
const Color accentOrange = Color(0xFFFB8C00);
const Color accentRed = Color(0xFFE53935);

class NewEntryScreen extends StatelessWidget {
  static const String routeName = '/newEntry';

  const NewEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Entry',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            _buildQuickStats(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionWithHelp('Standard Entry Methods'),
                  const SizedBox(height: 16),
                  const _StandardEntryOptions(),
                  const SizedBox(height: 32),
                  _buildSectionWithHelp('Special Entry Methods'),
                  const SizedBox(height: 16),
                  const _SpecialEntryOptions(),
                  const SizedBox(height: 24),
                  // _buildRecentEntriesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        color: cardBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.how_to_reg,
                  color: primaryColor,
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select an entry method below',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Today\'s Entries',
              '45',
              Icons.today,
              accentGreen,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Pending',
              '12',
              Icons.pending_actions,
              accentOrange,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Emergency',
              '2',
              Icons.warning_rounded,
              accentRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionWithHelp(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Tap for more information',
          child: IconButton(
            icon: const Icon(
              Icons.help_outline,
              size: 18,
              color: Color(0xFF1a237e),
            ),
            onPressed: () {
              // Show help dialog
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Entries',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a237e),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.shade200,
              height: 1,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF1a237e).withOpacity(0.1),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF1a237e),
                  ),
                ),
                title: const Text('John Doe'),
                subtitle: Text(
                  'Standard Entry • ${DateTime.now().difference(DateTime.now().subtract(const Duration(minutes: 5))).inMinutes}m ago',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // View entry details
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StandardEntryOptions extends StatelessWidget {
  const _StandardEntryOptions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          'QR Code + Face Recognition',
          'Standard verification process',
          Icons.qr_code_scanner,
          const Color(0xFF1a237e),
          () => Navigator.pushNamed(context, QrCodeVerifyScreen.routeName),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          'Manual ID Entry + Face',
          'Enter guest ID manually',
          Icons.person_search,
          const Color(0xFF1a237e),
          () => Navigator.pushNamed(context, ManualEntryScreen.routeName),
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
        _buildOptionCard(
          'Quick Entry',
          'Bypass verification with reason',
          Icons.flash_on,
          const Color(0xFF1a237e),
          () => _showQuickEntryDialog(context),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          'Group Entry',
          'Multiple guests at once',
          Icons.group_add,
          const Color(0xFF1a237e),
          () => Navigator.pushNamed(context, '/groupEntry'),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          'Emergency Entry',
          'Immediate access with logging',
          Icons.warning_rounded,
          const Color(0xFF1a237e),
          () => showEmergencyEntryDialog(context),
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
      builder: (context) => const QuickEntryBottomSheet(),
    );
  }
}

Widget _buildOptionCard(
  String title,
  String subtitle,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  return Card(
    elevation: 2,
    color: cardBgColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: primaryColor,
            ),
          ],
        ),
      ),
    ),
  );
}
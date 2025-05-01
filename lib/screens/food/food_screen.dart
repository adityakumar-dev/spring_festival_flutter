import 'package:flutter/material.dart';
import '../new entry/qr_code_verify.dart';
import '../../providers/app_user_manager.dart';
import 'package:provider/provider.dart';

class FoodScreen extends StatefulWidget {
  static const routeName = '/food-screen';
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    //  Provider.of<AppUserManager>(context, listen: false).setIsFoodEntryAlreadyExists(false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFCCCB),
                Color(0xFFF5F5F5),
                Color(0xFFF5F5F5).withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFF1A237E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Food Entry',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -190,
            left: 150,
            right: -150,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Image.asset(
                'assets/images/aipen.png',
                height: MediaQuery.of(context).size.height * 0.4,
                color: Color.fromARGB(255, 255, 165, 164),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Meal Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                // SizedBox(height: 20),
                // buildOptionTime(
                //   'Breakfast',
                //   Icons.breakfast_dining,
                //   Color(0xFF1A237E),
                //   'Morning meal time\n6:00 AM - 10:00 AM',
                //   () => _navigateToQRScanner(context, 'breakfast'),
                // ),
                buildOptionTime(
                  'Lunch',
                  Icons.lunch_dining,
                  Color(0xFF1A237E),
                  'Afternoon meal time\n12:00 PM - 3:00 PM',
                  () => _navigateToQRScanner(context, 'lunch'),
                ),
                buildOptionTime(
                  'Dinner',
                  Icons.dinner_dining,
                  Color(0xFF1A237E),
                  'Evening meal time\n7:00 PM - 10:00 PM',
                  () => _navigateToQRScanner(context, 'dinner'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToQRScanner(BuildContext context, String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrCodeVerifyScreen(isFood: true, mealType: mealType),
      ),
    );
  }

  Widget buildOptionTime(String time, IconData icon, Color color, String subtitle, Function onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => onTap(),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
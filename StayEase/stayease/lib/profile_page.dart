import 'package:flutter/material.dart';
import 'login_page.dart'; // Import the login page
import 'ListYourSpacePage.dart'; // Import the ListYourSpacePage

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Abhishek',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () {
                        // Show profile action
                      },
                      child: Text('Show profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),

          // Settings Section
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Personal information'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Personal Information
            },
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Login & security'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Login & Security
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Payments and payouts'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Payments
            },
          ),
          ListTile(
            leading: Icon(Icons.accessibility),
            title: Text('Accessibility'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Accessibility
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text('Taxes'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Taxes
            },
          ),
          ListTile(
            leading: Icon(Icons.translate),
            title: Text('Translation'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Translation
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Notifications
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy and sharing'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Privacy
            },
          ),
          ListTile(
            leading: Icon(Icons.card_travel),
            title: Text('Travel for work'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Travel for Work
            },
          ),
          Divider(),

          // Hosting Section
          ListTile(
            leading: Icon(Icons.home),
            title: Text('List your space'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to ListYourSpacePage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListYourSpacePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.lightbulb),
            title: Text('Learn about hosting'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Learn Hosting
            },
          ),
          ListTile(
            leading: Icon(Icons.explore),
            title: Text('Host an Experience'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Host Experience
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Find a co-host'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Co-host
            },
          ),
          Divider(),

          // Support Section
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Visit the Help Center'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Help Center
            },
          ),
          ListTile(
            leading: Icon(Icons.report),
            title: Text('Get help with a safety issue'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Safety
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on),
            title: Text('Report a neighborhood concern'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Neighborhood
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('How Airbnb works'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Airbnb Info
            },
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Give us feedback'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Feedback
            },
          ),
          Divider(),

          // Legal Section
          ListTile(
            leading: Icon(Icons.gavel),
            title: Text('Terms of Service'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Terms
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Privacy Policy
            },
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('Open source licenses'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to Licenses
            },
          ),
          Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Center(
                child: Text('Log out', style: TextStyle(color: Colors.red))),
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        child:
                            Text('Logout', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          // Close the dialog
                          Navigator.of(context).pop();
                          // Navigate to login page and remove all previous routes
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (Route<dynamic> route) =>
                                false, // Remove all previous routes
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

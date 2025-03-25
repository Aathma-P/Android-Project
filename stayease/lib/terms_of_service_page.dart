import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: March 25, 2024',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),

            // Agreement Section
            Text(
              '1. Agreement to Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'By accessing or using StayEase, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Service Description
            Text(
              '2. Description of Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'StayEase is a platform that connects property owners with individuals seeking accommodation. We provide listings for hostels, flats, and apartments, facilitating the search and booking process for temporary and long-term stays.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // User Responsibilities
            Text(
              '3. User Responsibilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Users must:\n'
              '• Provide accurate and complete information\n'
              '• Maintain the security of their account\n'
              '• Not misuse or abuse the platform\n'
              '• Respect other users and their properties\n'
              '• Comply with all applicable laws and regulations',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Property Listings
            Text(
              '4. Property Listings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Property owners must:\n'
              '• Provide accurate descriptions and images\n'
              '• Keep availability calendars updated\n'
              '• Maintain their properties as advertised\n'
              '• Comply with local housing laws and regulations\n'
              '• Respond to inquiries in a timely manner',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Liability
            Text(
              '5. Limitation of Liability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'StayEase serves as a platform connecting users and does not assume responsibility for:\n'
              '• The condition of listed properties\n'
              '• Disputes between users\n'
              '• Loss or damage of personal property\n'
              '• Actions of users outside our platform',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Changes to Terms
            Text(
              '6. Changes to Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We reserve the right to modify these terms at any time. Users will be notified of any changes through the app or via email.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

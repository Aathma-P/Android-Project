import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Privacy Policy',
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

            // Information Collection
            Text(
              '1. Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We collect information that you provide directly to us, including:\n'
              '• Personal information (name, email, phone number)\n'
              '• Profile information\n'
              '• Property details (for property owners)\n'
              '• Search preferences and history\n'
              '• Communication with other users',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Use of Information
            Text(
              '2. How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We use the collected information to:\n'
              '• Provide and improve our services\n'
              '• Personalize your experience\n'
              '• Process your transactions\n'
              '• Communicate with you\n'
              '• Ensure platform safety and security',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Information Sharing
            Text(
              '3. Information Sharing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We may share your information with:\n'
              '• Other users (as necessary for bookings)\n'
              '• Service providers\n'
              '• Legal authorities (when required by law)\n'
              '• Business partners (with your consent)',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Data Security
            Text(
              '4. Data Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We implement appropriate security measures to protect your personal information from unauthorized access, alteration, or destruction. This includes:\n'
              '• Encryption of sensitive data\n'
              '• Regular security assessments\n'
              '• Secure data storage\n'
              '• Access controls',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // User Rights
            Text(
              '5. Your Rights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You have the right to:\n'
              '• Access your personal information\n'
              '• Correct inaccurate information\n'
              '• Delete your account and data\n'
              '• Opt-out of marketing communications\n'
              '• Request data portability',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Contact Information
            Text(
              '6. Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions about this Privacy Policy, please contact us at:\n'
              'Email: privacy@stayease.com\n'
              'Address: [Your Company Address]',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

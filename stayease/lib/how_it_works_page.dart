import 'package:flutter/material.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How StayEase Works'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to StayEase!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your one-stop solution for finding the perfect accommodation.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // For Property Seekers
            _buildSection(
              title: 'For Property Seekers',
              icon: Icons.search,
              steps: [
                _buildStep(
                  number: '1',
                  title: 'Search Properties',
                  description:
                      'Use our powerful search filters to find hostels, flats, or apartments that match your preferences for location, price, and amenities.',
                ),
                _buildStep(
                  number: '2',
                  title: 'View Details',
                  description:
                      'Browse through detailed property listings with high-quality photos, amenities, house rules, and verified reviews from previous tenants.',
                ),
                _buildStep(
                  number: '3',
                  title: 'Contact Owners',
                  description:
                      'Connect directly with property owners through our secure messaging system to ask questions or schedule viewings.',
                ),
                _buildStep(
                  number: '4',
                  title: 'Book Your Stay',
                  description:
                      'Once you find your perfect place, follow the booking process to secure your accommodation.',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // For Property Owners
            _buildSection(
              title: 'For Property Owners',
              icon: Icons.home,
              steps: [
                _buildStep(
                  number: '1',
                  title: 'List Your Property',
                  description:
                      'Create detailed listings for your properties with photos, descriptions, amenities, and house rules.',
                ),
                _buildStep(
                  number: '2',
                  title: 'Manage Inquiries',
                  description:
                      'Receive and respond to inquiries from potential tenants through our messaging system.',
                ),
                _buildStep(
                  number: '3',
                  title: 'Screen Tenants',
                  description:
                      "Review tenant profiles and communicate with them to ensure they're a good fit for your property.",
                ),
                _buildStep(
                  number: '4',
                  title: 'Secure Bookings',
                  description:
                      'Confirm bookings and manage your property listings through your dashboard.',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Key Features
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeature(
              icon: Icons.verified_user,
              title: 'Verified Listings',
              description:
                  'All properties are verified for authenticity and safety.',
            ),
            _buildFeature(
              icon: Icons.rate_review,
              title: 'Review System',
              description:
                  'Honest reviews from verified tenants help you make informed decisions.',
            ),
            _buildFeature(
              icon: Icons.security,
              title: 'Secure Messaging',
              description:
                  'Built-in messaging system for safe communication between users.',
            ),
            _buildFeature(
              icon: Icons.support_agent,
              title: '24/7 Support',
              description: 'Our support team is always available to help you.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> steps,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...steps,
      ],
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
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
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
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

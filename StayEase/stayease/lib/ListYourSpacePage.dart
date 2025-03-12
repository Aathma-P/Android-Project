import 'package:flutter/material.dart';

class ListYourSpacePage extends StatelessWidget {
  // Dummy data for uploaded hostels (replace with your actual data source)
  final List<Map<String, dynamic>> uploadedHostels = [
    {
      'propertyName': 'Cozy Hostel in the City',
      'city': 'New York',
      'district': 'Manhattan',
      'region': 'NY',
      'imageUrl': 'https://example.com/image1.jpg',
      'price': 1000,
      'rating': 4.5,
    },
    {
      'propertyName': 'Mountain View Hostel',
      'city': 'Denver',
      'district': 'Colorado',
      'region': 'CO',
      'imageUrl': 'https://example.com/image2.jpg',
      'price': 1200,
      'rating': 4.8,
    },
    {
      'propertyName': 'Beachside Hostel',
      'city': 'Miami',
      'district': 'Florida',
      'region': 'FL',
      'imageUrl': 'https://example.com/image3.jpg',
      'price': 1500,
      'rating': 4.7,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Uploaded Hostels'),
        backgroundColor: Colors.blue[100],
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: uploadedHostels.length,
        itemBuilder: (context, index) {
          var hostel = uploadedHostels[index];
          return _buildHostelCard(hostel);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the page for uploading a new hostel
          // Navigator.push(context, MaterialPageRoute(builder: (context) => UploadHostelPage()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildHostelCard(Map<String, dynamic> hostel) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hostel Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              hostel['imageUrl'],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child:
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Name
                Text(
                  hostel['propertyName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),

                // Location
                Text(
                  "${hostel['city']}, ${hostel['district']}, ${hostel['region']}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),

                // Price and Rating
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      hostel['rating'].toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Spacer(),
                    Text(
                      "₹${hostel['price']} / month",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

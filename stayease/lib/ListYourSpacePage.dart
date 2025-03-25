import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UploadHostelPage.dart'; // Import the UploadHostelPage

class ListYourSpacePage extends StatelessWidget {
  final String userId; // User ID to filter hostels

  const ListYourSpacePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Uploaded Hostels'),
        backgroundColor: Colors.blue[100],
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostels')
            .where('uid', isEqualTo: userId) // Filter by user ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hostels uploaded yet.'));
          }

          final uploadedHostels = snapshot.data!.docs;

          return ListView.builder(
            itemCount: uploadedHostels.length,
            itemBuilder: (context, index) {
              var hostel =
                  uploadedHostels[index].data() as Map<String, dynamic>;
              return _buildHostelCard(
                  context, hostel, uploadedHostels[index].id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the page for uploading a new hostel
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UploadHostelPage(userId: userId)));
        },
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildHostelCard(
      BuildContext context, Map<String, dynamic> hostel, String hostelId) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              hostel['imageUrls']
                  [0], // Assuming the first image is the main one
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
                Text(
                  hostel['propertyName'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "${hostel['city']}, ${hostel['district']}, ${hostel['region']}",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      hostel['rating'].toString(),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Spacer(),
                    Text(
                      "₹${hostel['price']} / month",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800]),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to edit page
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UploadHostelPage(
                                    userId: userId,
                                    hostelId: hostelId,
                                    existingData: hostel)));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Delete hostel
                        FirebaseFirestore.instance
                            .collection('hostels')
                            .doc(hostelId)
                            .delete();
                      },
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

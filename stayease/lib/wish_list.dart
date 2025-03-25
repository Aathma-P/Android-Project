import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Please sign in to view your wishlist')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlists'),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to edit wishlist page
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_profiles')
            .doc(user.uid)
            .collection('wishlist')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hostels in your wishlist'));
          }

          var wishlistItems = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 16, // Horizontal space between items
              mainAxisSpacing: 16, // Vertical space between items
              childAspectRatio: 0.8, // Adjust the aspect ratio for better UI
            ),
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              var item = wishlistItems[index];
              var data = item.data() as Map<String, dynamic>;
              var imageUrls = data['imageUrls'] as List<dynamic>;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 250, // Constrain the height of the card
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hostel Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: imageUrls.isNotEmpty
                            ? Image.network(
                                imageUrls[0],
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.grey[200],
                                child:
                                    Icon(Icons.image, color: Colors.grey[400]),
                              ),
                      ),
                      // Hostel Details
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['propertyName'] ?? "Unnamed Property",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${data['city']}, ${data['district']}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Remove Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeFromWishlist(user.uid, item.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation bar taps
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Function to remove a hostel from the wishlist
  void _removeFromWishlist(String userId, String hostelId) async {
    print("Removing hostel with ID: $hostelId");
    print("User ID: $userId");

    try {
      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(userId)
          .collection('wishlist')
          .doc(hostelId)
          .delete();
      print("Hostel removed from wishlist.");
    } catch (e) {
      print("Error removing hostel from wishlist: $e");
    }
  }
}

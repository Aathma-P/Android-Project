import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'uploadHostelPage.dart';
import 'profile_page.dart';
import 'HostelDetailPage.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the custom color theme
    const Color backgroundColor = Color(0xFFF5F5F5);
    const Color primaryColor = Color(0xFF2196F3);
    const Color cardColor = Colors.white;
    const Color textColor = Color(0xFF333333);
    const Color secondaryTextColor = Color(0xFF666666);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Please sign in to view your wishlist',
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: cardColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: secondaryTextColor,
          elevation: 8,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: textColor),
          titleMedium: TextStyle(color: textColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: cardColor,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Wishlist'),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: primaryColor),
              onPressed: () {
                // Navigate to edit wishlist page
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_profiles')
              .doc(user.uid)
              .collection('wishlist')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: secondaryTextColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wishlist is empty',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save properties you love to see them here',
                      style: TextStyle(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            var wishlistItems = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                var item = wishlistItems[index];
                var data = item.data() as Map<String, dynamic>;
                var imageUrls = data['imageUrls'] as List<dynamic>;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      // Navigate to property details
                    },
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Property Image
                            Container(
                              height: 120,
                              width: double.infinity,
                              child: imageUrls.isNotEmpty
                                  ? Image.network(
                                      imageUrls[0],
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: backgroundColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          color: secondaryTextColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                            ),
                            // Property Details
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['propertyName'] ?? "Unnamed Property",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${data['city']}, ${data['district']}",
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        data['rating']?.toString() ?? "N/A",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Remove button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: cardColor.withOpacity(0.9),
                            child: IconButton(
                              icon: Icon(
                                Icons.favorite,
                                size: 14,
                                color: Colors.redAccent,
                              ),
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
          backgroundColor: Colors.blue[100],
          currentIndex: 1,
          selectedItemColor: Colors.blue[800],
          unselectedItemColor: Colors.blueGrey,
          showUnselectedLabels: true,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadHostelPage(
                    userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  ),
                ),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: "Explore",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Wishlists",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload),
              label: "Upload",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromWishlist(String userId, String hostelId) async {
    try {
      await FirebaseFirestore.instance
          .collection('user_profiles')
          .doc(userId)
          .collection('wishlist')
          .doc(hostelId)
          .delete();
    } catch (e) {
      print("Error removing hostel from wishlist: $e");
    }
  }
}

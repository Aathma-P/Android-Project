import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wish_list.dart';
import 'profile_page.dart';
import 'uploadHostelPage.dart';
import 'HostelDetailPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Fetch hostel data from Firestore
  Stream<QuerySnapshot> _fetchHostels() {
    return FirebaseFirestore.instance.collection('hostels').snapshots();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadHostelPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 2,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Start your search",
              prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.blue[50],
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildPriceToggle(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchHostels(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No hostels available"));
                  }

                  var propertyList = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: propertyList.length > 5
                        ? 5
                        : propertyList.length, // Display up to 5 properties
                    itemBuilder: (context, index) {
                      var property = propertyList[index];
                      var data = property.data() as Map<String, dynamic>;
                      data['id'] = property.id; // Add document ID to data

                      return _buildPropertyCard(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[100],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.blueGrey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
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
    );
  }

  Widget _buildPriceToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Display total price",
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          Switch(
            value: false,
            onChanged: (value) {},
            activeColor: Colors.blue,
            inactiveTrackColor: Colors.blueGrey[200],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> data) {
    List<dynamic> imageUrls = data['imageUrls'] ?? [];
    String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HostelDetailPage(hostelData: data),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Image.asset(
                              'assets/placeholder.jpg',
                              fit: BoxFit.cover),
                        )
                      : Image.asset('assets/placeholder.jpg',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['propertyName'] ?? "Unnamed Property",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data['city']}, ${data['district']}, ${data['region']}",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pincode: ${data['pincode']}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coordinates: ${data['latitude']}, ${data['longitude']}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Place Type: ${data['place']}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amenities: ${data['amenities']?.join(', ') ?? 'No amenities listed'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('user_profiles')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('wishlist')
                    .doc(data['id'])
                    .snapshots(),
                builder: (context, snapshot) {
                  final isInWishlist =
                      snapshot.hasData && snapshot.data!.exists;
                  return IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: isInWishlist ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleWishlist(data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleWishlist(Map<String, dynamic> hostelData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userWishlistRef = FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(user.uid)
        .collection('wishlist');

    final hostelId =
        hostelData['id']; // Ensure your hostel data has an 'id' field

    final doc = await userWishlistRef.doc(hostelId).get();
    if (doc.exists) {
      await userWishlistRef.doc(hostelId).delete();
    } else {
      await userWishlistRef.doc(hostelId).set(hostelData);
    }
  }
}

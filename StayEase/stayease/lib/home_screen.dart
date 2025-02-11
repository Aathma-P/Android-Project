import 'package:flutter/material.dart';
import 'wish_list.dart'; // Import the WishlistPage
import 'profile_page.dart'; // Import the ProfilePage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Tracks the current selected tab

  final List<Map<String, dynamic>> propertyList = [
    {
      "image": "lib/images/zostel-gokarna.jpg",
      "location": "Gokarna, India",
      "distance": "521 kilometers away",
      "date": "Jan 21 - 26",
      "price": "\$347",
    },
    {
      "image": "lib/images/hostel1.jpg",
      "location": "Varkala, India",
      "distance": "450 kilometers away",
      "date": "Feb 10 - 15",
      "price": "\$299",
    },
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WishlistPage()),
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
              child: ListView.builder(
                itemCount: propertyList.length,
                itemBuilder: (context, index) {
                  final property = propertyList[index];
                  return _buildPropertyCard(property);
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
            icon: Icon(Icons.trip_origin),
            label: "Trips",
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

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              property['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['location'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                Text(property['distance'],
                    style: TextStyle(color: Colors.grey)),
                Text(property['date'], style: TextStyle(color: Colors.grey)),
                Text(
                  "${property['price']} / night",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey,
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

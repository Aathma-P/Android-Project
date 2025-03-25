import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

// Import other necessary pages
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedPlaceType = 'All'; // Default filter option
  bool _ascending = true; // Default sort direction
  Position? _currentPosition;
  bool _isLocationLoading = false;

  // List of place types with their icons
  final List<Map<String, dynamic>> _placeTypes = [
    {'name': 'All', 'icon': Icons.home},
    {'name': 'PG', 'icon': Icons.house},
    {'name': 'Hostel', 'icon': Icons.apartment},
    {'name': 'House', 'icon': Icons.home_work},
    {'name': 'Flat', 'icon': Icons.business},
    {'name': 'Apartment', 'icon': Icons.location_city},
    {'name': 'Nearest', 'icon': Icons.near_me},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

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
        MaterialPageRoute(
            builder: (context) => UploadHostelPage(
                userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
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

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLocationLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLocationLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLocationLoading = false;
    });
  }

  // Calculate distance between two coordinates
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Format distance for display
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} meters';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  // Sort properties by distance
  void _sortByDistance(List<DocumentSnapshot> propertyList) {
    if (_currentPosition != null) {
      propertyList.sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;

        final aLat = double.tryParse(aData['latitude'].toString());
        final aLon = double.tryParse(aData['longitude'].toString());
        final bLat = double.tryParse(bData['latitude'].toString());
        final bLon = double.tryParse(bData['longitude'].toString());

        if (aLat != null && aLon != null && bLat != null && bLon != null) {
          final aDistance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            aLat,
            aLon,
          );
          final bDistance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            bLat,
            bLon,
          );

          return aDistance.compareTo(bDistance);
        }
        return 0;
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
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Start your search",
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 8),
                child: Icon(Icons.search, color: Colors.blue[800]),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterModal(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue[50],
        child: Column(
          children: [
            _buildAirbnbStyleFilters(),
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

                  // Filter based on place type
                  if (_selectedPlaceType != 'All' &&
                      _selectedPlaceType != 'Nearest') {
                    propertyList = propertyList.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final placeType = data['place']?.toString() ?? '';
                      return placeType == _selectedPlaceType;
                    }).toList();
                  }

                  // Filter the list based on search query
                  if (_searchQuery.isNotEmpty) {
                    propertyList = propertyList.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final propertyName =
                          data['propertyName']?.toString().toLowerCase() ?? '';
                      final city = data['city']?.toString().toLowerCase() ?? '';
                      final district =
                          data['district']?.toString().toLowerCase() ?? '';
                      final region =
                          data['region']?.toString().toLowerCase() ?? '';
                      final pincode =
                          data['pincode']?.toString().toLowerCase() ?? '';
                      final place =
                          data['place']?.toString().toLowerCase() ?? '';

                      final searchLower = _searchQuery.toLowerCase();

                      return propertyName.contains(searchLower) ||
                          city.contains(searchLower) ||
                          district.contains(searchLower) ||
                          region.contains(searchLower) ||
                          pincode.contains(searchLower) ||
                          place.contains(searchLower);
                    }).toList();
                  }

                  if (propertyList.isEmpty) {
                    return const Center(
                        child: Text("No matching hostels found"));
                  }

                  // Sort by distance if "Nearest" is selected
                  if (_selectedPlaceType == 'Nearest') {
                    _sortByDistance(propertyList);
                  }

                  return ListView.builder(
                    itemCount: propertyList.length,
                    itemBuilder: (context, index) {
                      var property = propertyList[index];
                      var data = property.data() as Map<String, dynamic>;
                      data['id'] = property.id;
                      data['hostelId'] = property.id;

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

  // Build Airbnb-style filters
  Widget _buildAirbnbStyleFilters() {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _placeTypes.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final placeType = _placeTypes[index];
          final isSelected = _selectedPlaceType == placeType['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlaceType = placeType['name'];
              });
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[800] : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue[800]!
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      placeType['icon'],
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    placeType['name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.blue[800] : Colors.grey,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build property card
  Widget _buildPropertyCard(Map<String, dynamic> data) {
    // Improved image URL handling
    List<dynamic> imageUrls = data['imageUrls'] ?? [];
    String imageUrl =
        imageUrls.isNotEmpty ? imageUrls[0].toString().trim() : '';

    // Debug print statements
    debugPrint('Property: ${data['propertyName']}');
    debugPrint('Image URLs: $imageUrls');
    debugPrint('First Image URL: $imageUrl');

    // Calculate distance if location is available
    double? distance;
    if (_currentPosition != null &&
        data['latitude'] != null &&
        data['longitude'] != null) {
      double? hostelLat = double.tryParse(data['latitude'].toString());
      double? hostelLon = double.tryParse(data['longitude'].toString());

      if (hostelLat != null && hostelLon != null) {
        distance = _calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          hostelLat,
          hostelLon,
        );
      }
    }

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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: _buildImageWidget(imageUrl),
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
                        "${data['city'] ?? ''}, ${data['district'] ?? ''}, ${data['region'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pincode: ${data['pincode'] ?? ''}",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Place Type: ${data['place'] ?? ''}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          if (distance != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatDistance(distance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.green[800],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amenities: ${data['amenities']?.join(', ') ?? 'No amenities listed'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isInWishlist ? Icons.favorite : Icons.favorite_border,
                        color: isInWishlist ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                      onPressed: () {
                        _toggleWishlist(data);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build image widget with multiple fallback mechanisms
  Widget _buildImageWidget(String imageUrl) {
    // Comprehensive image loading with multiple fallback mechanisms
    if (imageUrl.isEmpty) {
      return _placeholderImage();
    }

    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          debugPrint('Image load error: $error');
          debugPrint('Failed URL: $url');
          return _placeholderImage();
        },
      );
    } catch (e) {
      debugPrint('Exception in image loading: $e');
      return _placeholderImage();
    }
  }

  // Placeholder image with error handling
  Widget _placeholderImage() {
    return Image.asset(
      'assets/placeholder.jpg',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Placeholder image load error: $error');
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 50,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Toggle wishlist functionality
  void _toggleWishlist(Map<String, dynamic> hostelData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userWishlistRef = FirebaseFirestore.instance
        .collection('user_profiles')
        .doc(user.uid)
        .collection('wishlist');

    final hostelId = hostelData['id'];

    final doc = await userWishlistRef.doc(hostelId).get();
    if (doc.exists) {
      await userWishlistRef.doc(hostelId).delete();
    } else {
      await userWishlistRef.doc(hostelId).set(hostelData);
    }
  }

  // Show filter modal
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter by",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sort Direction
              ListTile(
                title: const Text("Sort Direction"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_ascending ? "A to Z" : "Z to A"),
                    const SizedBox(width: 8),
                    Switch(
                      value: !_ascending,
                      onChanged: (value) {
                        Navigator.pop(context);
                        setState(() {
                          _ascending = !value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Price Range (if available in your data)
              const ListTile(
                title: Text("Price Range"),
                subtitle: Text("Coming soon"),
              ),

              // Amenities Filter (if available in your data)
              const ListTile(
                title: Text("Amenities"),
                subtitle: Text("Coming soon"),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Apply Filters"),
              ),
            ],
          ),
        );
      },
    );
  }
}

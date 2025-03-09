import 'package:flutter/material.dart';

class UploadHostelPage extends StatefulWidget {
  const UploadHostelPage({super.key});

  @override
  _UploadHostelPageState createState() => _UploadHostelPageState();
}

class _UploadHostelPageState extends State<UploadHostelPage> {
  int _currentStep = 0; // Tracks the current step
  String? selectedPlace; // For Place Selection
  final Set<String> selectedAmenities = {}; // For Amenities Selection
  int guests = 4, bedrooms = 1, beds = 1, bathrooms = 1; // For Basic Details
  String selectedRegion = ""; // For region input

  // List of places for Step 1
  final List<Map<String, dynamic>> places = [
    {'name': 'House', 'icon': Icons.home},
    {'name': 'Hostel', 'icon': Icons.location_city},
    {'name': 'PG', 'icon': Icons.meeting_room},
    {'name': 'Flat/Apartment', 'icon': Icons.apartment},
  ];

  // List of amenities for Step 2
  final List<Map<String, dynamic>> amenities = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'TV', 'icon': Icons.tv},
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Washing Machine', 'icon': Icons.local_laundry_service},
    {'name': 'Free Parking', 'icon': Icons.directions_car},
    {'name': 'Paid Parking', 'icon': Icons.local_parking},
  ];

  // Function to move to the next step
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  // Function to move to the previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD8C3A5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Save & exit",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4, // 4 steps in total
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
              minHeight: 8,
            ),
            const SizedBox(height: 20),

            // Step 1: Place Selection
            if (_currentStep == 0) ...[
              const Text(
                "Which of these best describes your place?",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2,
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPlace = place['name'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedPlace == place['name']
                                ? Colors.blueGrey
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: selectedPlace == place['name']
                              ? Color(0xFFEAE7DC)
                              : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(place['icon'], color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            Text(
                              place['name'],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Step 2: Amenities Selection
            if (_currentStep == 1) ...[
              const Text(
                "Tell guests what your place has to offer",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),
              const Text(
                "You can add more amenities after you publish your listing.",
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2,
                  ),
                  itemCount: amenities.length,
                  itemBuilder: (context, index) {
                    final amenity = amenities[index];
                    final isSelected =
                        selectedAmenities.contains(amenity['name']);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedAmenities.remove(amenity['name']);
                          } else {
                            selectedAmenities.add(amenity['name']);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blueGrey : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Color(0xFFEAE7DC) : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(amenity['icon'], color: Colors.blueGrey),
                            const SizedBox(width: 10),
                            Text(
                              amenity['name'],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Step 3: Basic Details
            if (_currentStep == 2) ...[
              const Text(
                "Share some basics about your place",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
              const SizedBox(height: 5),
              const Text(
                "You'll add more details later, such as bed types.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Region Input Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Enter your property's region/location",
                    hintText: "e.g., Gokarna, India",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(Icons.location_on, color: Colors.blueGrey),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedRegion = value; // Update the selected region
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a region/location";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Counters for Guests, Bedrooms, Beds, and Bathrooms
              _buildCounter(
                "Guests",
                guests,
                () => setState(() {
                  if (guests > 1) guests--;
                }),
                () => setState(() {
                  guests++;
                }),
              ),
              _buildCounter(
                "Bedrooms",
                bedrooms,
                () => setState(() {
                  if (bedrooms > 1) bedrooms--;
                }),
                () => setState(() {
                  bedrooms++;
                }),
              ),
              _buildCounter(
                "Beds",
                beds,
                () => setState(() {
                  if (beds > 1) beds--;
                }),
                () => setState(() {
                  beds++;
                }),
              ),
              _buildCounter(
                "Bathrooms",
                bathrooms,
                () => setState(() {
                  if (bathrooms > 1) bathrooms--;
                }),
                () => setState(() {
                  bathrooms++;
                }),
              ),
            ],

            // Step 4: Photo Upload
            if (_currentStep == 3) ...[
              const Text(
                "Add some photos of your flat/apartment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "You'll need 5 photos to get started. You can add more or make changes later.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildPhotoOption(
                  'Add photos', Icons.add_photo_alternate_outlined),
              const SizedBox(height: 10),
              _buildPhotoOption('Take new photos', Icons.camera_alt_outlined),
            ],

            const Spacer(),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _previousStep,
                  child: const Text("Back",
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                ),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build counters for Step 3
  Widget _buildCounter(
      String title, int value, Function onDecrement, Function onIncrement) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onDecrement(),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.blueGrey,
                  ),
                  Text(value.toString(), style: const TextStyle(fontSize: 18)),
                  IconButton(
                    onPressed: () => onIncrement(),
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.blueGrey,
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  // Helper method to build photo options for Step 4
  Widget _buildPhotoOption(String title, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: () {
          // Handle photo option selection
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import the AuthService and FirestoreService
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

// LocationSelectorPage remains unchanged
class LocationSelectorPage extends StatefulWidget {
  final Function(double, double) onLocationSelected;

  const LocationSelectorPage({super.key, required this.onLocationSelected});

  @override
  _LocationSelectorPageState createState() => _LocationSelectorPageState();
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation =
      LatLng(20.5937, 78.9629); // Default to center of India
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permissions are permanently denied, please enable in settings'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_selectedLocation, 15);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: const Color(0xFFD8C3A5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back without selecting
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 15.0,
                      onTap: (tapPosition, latLng) {
                        setState(() {
                          _selectedLocation = latLng;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40.0,
                            height: 40.0,
                            point: _selectedLocation,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        'Selected Location: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.my_location),
                            label: const Text('My Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.onLocationSelected(
                                _selectedLocation.latitude,
                                _selectedLocation.longitude,
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Confirm Location'),
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

class UploadHostelPage extends StatefulWidget {
  const UploadHostelPage({super.key});

  @override
  _UploadHostelPageState createState() => _UploadHostelPageState();
}

class _UploadHostelPageState extends State<UploadHostelPage> {
  int _currentStep = 0; // Tracks the current step
  String? selectedPlace; // For Place Selection
  final Set<String> selectedAmenities = {}; // For Amenities Selection
  String selectedRegion = ""; // For region input

  // New fields for property details
  String propertyName = "";
  String city = "";
  String district = "";
  String pincode = "";

  // Location coordinates
  double? selectedLatitude;
  double? selectedLongitude;

  final FirestoreService _firestoreService =
      FirestoreService(); // Firestore Service
  final ImagePicker _picker = ImagePicker(); // Image Picker

  // Updated to store both URLs and filenames
  List<Map<String, String>> uploadedImages =
      []; // List to hold image info (URL and filename)
  bool isUploading = false; // Track upload status

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

  // Function to open location selector
  void _openLocationSelector() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationSelectorPage(
          onLocationSelected: (lat, lng) {
            setState(() {
              selectedLatitude = lat;
              selectedLongitude = lng;
            });
          },
        ),
      ),
    );
  }

  // Function to upload image to Cloudinary
  Future<Map<String, String>?> _uploadImage(XFile image) async {
    final String cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/dkaoszzid/image/upload';
    final String uploadPreset = 'StayEase';

    setState(() {
      isUploading = true;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final result = json.decode(String.fromCharCodes(responseData));

        // Extract the filename from the image path
        final String fileName = path.basename(image.path);

        setState(() {
          isUploading = false;
        });

        return {'url': result['secure_url'], 'filename': fileName};
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to upload image: ${response.reasonPhrase}')),
        );
        setState(() {
          isUploading = false;
        });
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during upload: $e')),
      );
      setState(() {
        isUploading = false;
      });
      return null;
    }
  }

  // Function to save hostel data to Firestore
  void _saveHostel() async {
    // Extract just the URLs for Firestore
    List<String> imageUrls = uploadedImages.map((img) => img['url']!).toList();

    Map<String, dynamic> hostelData = {
      'place': selectedPlace ?? "", // Handle null with empty string
      'amenities': selectedAmenities.toList(),
      'region': selectedRegion,
      'propertyName': propertyName,
      'city': city,
      'district': district,
      'pincode': pincode,
      'latitude': selectedLatitude?.toString() ?? "",
      'longitude': selectedLongitude?.toString() ?? "",
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
      'imageUrls': imageUrls, // Add image URLs
      'imageCount': imageUrls.length, // Add count of images
    };

    setState(() {
      isUploading = true;
    });

    try {
      await _firestoreService.addHostel(hostelData);
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hostel uploaded successfully!')),
      );
      // Navigate back or to another page
      Navigator.pop(context);
    } catch (error) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload hostel: $error')),
      );
    }
  }

  // Function to take photo with camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Map<String, String>? imageInfo = await _uploadImage(photo);
      if (imageInfo != null) {
        setState(() {
          uploadedImages.add(imageInfo);
        });
      }
    }
  }

  // Function to pick images from gallery
  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      for (XFile image in images) {
        Map<String, String>? imageInfo = await _uploadImage(image);
        if (imageInfo != null) {
          setState(() {
            uploadedImages.add(imageInfo);
          });
        }
      }
    }
  }

  // Function to remove an image from the list
  void _removeImage(int index) {
    setState(() {
      uploadedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD8C3A5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save current progress and exit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress saved as draft')),
              );
              Navigator.pop(context);
            },
            child: const Text("Save & exit",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Uploading... Please wait"),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4, // 4 steps in total
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    ? const Color(0xFFEAE7DC)
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  color: isSelected
                                      ? Colors.blueGrey
                                      : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: isSelected
                                    ? const Color(0xFFEAE7DC)
                                    : Colors.white,
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

                  // Step 3: Property Details
                  if (_currentStep == 2) ...[
                    const Text(
                      "Enter property details",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Property Name
                            _buildTextField("Property Name", (value) {
                              setState(() {
                                propertyName = value;
                              });
                            }),
                            const SizedBox(height: 16),

                            // City
                            _buildTextField("City", (value) {
                              setState(() {
                                city = value;
                              });
                            }),
                            const SizedBox(height: 16),

                            // District
                            _buildTextField("District", (value) {
                              setState(() {
                                district = value;
                              });
                            }),
                            const SizedBox(height: 16),

                            // Pincode
                            _buildTextField("Pincode", (value) {
                              setState(() {
                                pincode = value;
                              });
                            }),
                            const SizedBox(height: 16),

                            // Location Selection Card
                            Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Property Location",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey),
                                    ),
                                    const SizedBox(height: 8),

                                    // Display selected coordinates if available
                                    if (selectedLatitude != null &&
                                        selectedLongitude != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: Text(
                                          "Selected Location: ${selectedLatitude!.toStringAsFixed(6)}, ${selectedLongitude!.toStringAsFixed(6)}",
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),

                                    ElevatedButton.icon(
                                      onPressed: _openLocationSelector,
                                      icon: const Icon(Icons.map),
                                      label: Text(selectedLatitude == null
                                          ? "Select Location on Map"
                                          : "Change Location"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Step 4: Photo Upload (Optional)
                  if (_currentStep == 3) ...[
                    const Text(
                      "Add some photos of your place",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You'll need photos to get started. You can add more or make changes later.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Photo upload options
                            _buildPhotoOption(
                                'Add photos from gallery',
                                Icons.add_photo_alternate_outlined,
                                _pickImages),
                            const SizedBox(height: 10),
                            _buildPhotoOption('Take new photos',
                                Icons.camera_alt_outlined, _takePhoto),

                            // Display uploaded images with filenames
                            if (uploadedImages.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                "Uploaded Images:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: uploadedImages.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: const Icon(Icons.image,
                                          color: Colors.blueGrey),
                                      title: Text(uploadedImages[index]
                                              ['filename'] ??
                                          'Image ${index + 1}'),
                                      subtitle: Text('Uploaded successfully'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _removeImage(index),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],

                            if (uploadedImages.isEmpty) ...[
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  "No images uploaded yet",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  // Skip photo upload and save the hostel data
                                  _saveHostel();
                                },
                                child: const Text(
                                  "Skip for now",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _previousStep,
                        child: const Text("Back",
                            style: TextStyle(
                                fontSize: 16, color: Colors.blueGrey)),
                      ),
                      if (_currentStep < 3)
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Next"),
                        ),
                      if (_currentStep == 3)
                        ElevatedButton(
                          onPressed: () {
                            // Save hostel data with optional images
                            _saveHostel();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Save"),
                        ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String label, Function(String) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: onChanged,
    );
  }

  // Helper method to build photo options for Step 4
  Widget _buildPhotoOption(String title, IconData icon, Function() onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        onTap: onTap,
      ),
    );
  }
}

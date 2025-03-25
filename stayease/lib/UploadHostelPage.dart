import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

// Location Selector Page
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

// Upload Hostel Page
class UploadHostelPage extends StatefulWidget {
  final String userId;
  final String? hostelId;
  final Map<String, dynamic>? existingData;

  const UploadHostelPage(
      {super.key, required this.userId, this.hostelId, this.existingData});

  @override
  _UploadHostelPageState createState() => _UploadHostelPageState();
}

class _UploadHostelPageState extends State<UploadHostelPage> {
  int _currentStep = 0;
  String? selectedPlace;
  final Set<String> selectedAmenities = {};
  String selectedRegion = "";

  // Property details
  String propertyName = "";
  String city = "";
  String district = "";
  String pincode = "";

  // Location coordinates
  double? selectedLatitude;
  double? selectedLongitude;

  final ImagePicker _picker = ImagePicker();
  List<Map<String, String>> uploadedImages = [];
  bool isUploading = false;

  // Cloudinary configuration
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dkaoszzid/image/upload';
  final String cloudinaryPreset = 'StayEase';

  // Lists for places and amenities
  final List<Map<String, dynamic>> places = [
    {'name': 'House', 'icon': Icons.home},
    {'name': 'Hostel', 'icon': Icons.location_city},
    {'name': 'PG', 'icon': Icons.meeting_room},
    {'name': 'Flat/Apartment', 'icon': Icons.apartment},
  ];

  final List<Map<String, dynamic>> amenities = [
    {'name': 'Wifi', 'icon': Icons.wifi},
    {'name': 'TV', 'icon': Icons.tv},
    {'name': 'Kitchen', 'icon': Icons.kitchen},
    {'name': 'Washing Machine', 'icon': Icons.local_laundry_service},
    {'name': 'Free Parking', 'icon': Icons.directions_car},
    {'name': 'Paid Parking', 'icon': Icons.local_parking},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Populate fields with existing data if editing
      propertyName = widget.existingData!['propertyName'] ?? "";
      city = widget.existingData!['city'] ?? "";
      district = widget.existingData!['district'] ?? "";
      pincode = widget.existingData!['pincode'] ?? "";
      selectedLatitude =
          double.tryParse(widget.existingData!['latitude'] ?? "");
      selectedLongitude =
          double.tryParse(widget.existingData!['longitude'] ?? "");
      uploadedImages = List<Map<String, String>>.from(widget
              .existingData!['imageUrls']
              ?.map((url) => {'url': url, 'filename': url.split('/').last}) ??
          []);
    }
  }

  // Image upload to Cloudinary
  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));

      // Add Cloudinary upload preset
      request.fields['upload_preset'] = cloudinaryPreset;

      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
          'file', imageFile.path,
          filename: path.basename(imageFile.path)));

      // Send the request
      var response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        // Parse the response
        var responseData = await response.stream.toBytes();
        var result = String.fromCharCodes(responseData);
        var jsonResponse = json.decode(result);

        // Return the secure URL of the uploaded image
        return jsonResponse['secure_url'];
      } else {
        // Handle upload error
        print('Image upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  // Navigation methods
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Location selector
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

  // Save hostel method
  void _saveHostel() async {
    setState(() {
      isUploading = true;
    });

    try {
      // Upload images to Cloudinary
      List<String> cloudinaryUrls = [];
      for (var imageData in uploadedImages) {
        // Check if it's a local file or already an uploaded URL
        if (imageData['url']!.startsWith('http') == false) {
          File imageFile = File(imageData['url']!);
          String? cloudinaryUrl = await _uploadImageToCloudinary(imageFile);

          if (cloudinaryUrl != null) {
            cloudinaryUrls.add(cloudinaryUrl);
          }
        } else {
          // If it's already a URL (from previous upload), keep it
          cloudinaryUrls.add(imageData['url']!);
        }
      }

      // Create hostel data map
      Map<String, dynamic> hostelData = {
        'uid': widget.userId,
        'place': selectedPlace ?? "",
        'amenities': selectedAmenities.toList(),
        'region': selectedRegion,
        'propertyName': propertyName,
        'city': city,
        'district': district,
        'pincode': pincode,
        'latitude': selectedLatitude?.toString() ?? "",
        'longitude': selectedLongitude?.toString() ?? "",
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrls': cloudinaryUrls,
        'imageCount': cloudinaryUrls.length,
      };

      // Save to Firestore
      if (widget.hostelId != null) {
        // Update existing hostel
        await FirebaseFirestore.instance
            .collection('hostels')
            .doc(widget.hostelId)
            .update(hostelData);
      } else {
        // Add new hostel
        await FirebaseFirestore.instance.collection('hostels').add(hostelData);
      }

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

  // Image selection methods
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        uploadedImages.add({'url': photo.path, 'filename': photo.name});
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      for (XFile image in images) {
        setState(() {
          uploadedImages.add({'url': image.path, 'filename': image.name});
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      uploadedImages.removeAt(index);
    });
  }

  // Build method for text fields
  Widget _buildTextField(String label, Function(String) onChanged,
      {String initialValue = ""}) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[100]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[800]!),
        ),
      ),
      onChanged: onChanged,
    );
  }

  // Build method for photo options
  Widget _buildPhotoOption(String title, IconData icon, Function() onTap) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[800]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue[800],
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[800]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Upload Property",
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress saved as draft')),
              );
              Navigator.pop(context);
            },
            child: Text(
              "Save & exit",
              style: TextStyle(color: Colors.blue[800]),
            ),
          ),
        ],
      ),
      body: isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Uploading... Please wait",
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ],
              ),
            )
          : Container(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      backgroundColor: Colors.blue[100],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 20),

                    // Step 1: Place Selection
                    if (_currentStep == 0) ...[
                      Text(
                        "Which of these best describes your place?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
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
                                        ? Colors.blue[800]!
                                        : Colors.blue[100]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: selectedPlace == place['name']
                                      ? Colors.blue[50]
                                      : Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(place['icon'],
                                        color: Colors.blue[800]),
                                    const SizedBox(width: 10),
                                    Text(
                                      place['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[800],
                                      ),
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
                      Text(
                        "Tell guests what your place has to offer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You can add more amenities after you publish your listing.",
                        style: TextStyle(fontSize: 16, color: Colors.blue[800]),
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
                                        ? Colors.blue[800]!
                                        : Colors.blue[100]!,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? Colors.blue[50]
                                      : Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(amenity['icon'],
                                        color: Colors.blue[800]),
                                    const SizedBox(width: 10),
                                    Text(
                                      amenity['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[800],
                                      ),
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
                      Text(
                        "Enter property details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField("Property Name", (value) {
                                setState(() {
                                  propertyName = value;
                                });
                              }, initialValue: propertyName),
                              const SizedBox(height: 16),
                              _buildTextField("City", (value) {
                                setState(() {
                                  city = value;
                                });
                              }, initialValue: city),
                              const SizedBox(height: 16),
                              _buildTextField("District", (value) {
                                setState(() {
                                  district = value;
                                });
                              }, initialValue: district),
                              const SizedBox(height: 16),
                              _buildTextField("Pincode", (value) {
                                setState(() {
                                  pincode = value;
                                });
                              }, initialValue: pincode),
                              const SizedBox(height: 16),
                              Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Property Location",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (selectedLatitude != null &&
                                          selectedLongitude != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Text(
                                            "Selected Location: ${selectedLatitude!.toStringAsFixed(6)}, ${selectedLongitude!.toStringAsFixed(6)}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue[800]),
                                          ),
                                        ),
                                      ElevatedButton.icon(
                                        onPressed: _openLocationSelector,
                                        icon: Icon(Icons.map,
                                            color: Colors.white),
                                        label: Text(
                                          selectedLatitude == null
                                              ? "Select Location on Map"
                                              : "Change Location",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[800],
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

                    // Step 4: Photo Upload
                    if (_currentStep == 3) ...[
                      Text(
                        "Add some photos of your place",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You'll need photos to get started. You can add more or make changes later.",
                        style: TextStyle(fontSize: 14, color: Colors.blue[800]),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildPhotoOption(
                                'Add photos from gallery',
                                Icons.add_photo_alternate_outlined,
                                _pickImages,
                              ),
                              const SizedBox(height: 10),
                              _buildPhotoOption(
                                'Take new photos',
                                Icons.camera_alt_outlined,
                                _takePhoto,
                              ),
                              if (uploadedImages.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Text(
                                  "Uploaded Images:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
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
                                        leading: Icon(Icons.image,
                                            color: Colors.blue[800]),
                                        title: Text(
                                          uploadedImages[index]['filename'] ??
                                              'Image ${index + 1}',
                                          style: TextStyle(
                                              color: Colors.blue[800]),
                                        ),
                                        subtitle: Text(
                                          'Uploaded successfully',
                                          style: TextStyle(
                                              color: Colors.blue[800]),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete,
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
                                Center(
                                  child: Text(
                                    "No images uploaded yet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    _saveHostel();
                                  },
                                  child: Text(
                                    "Skip for now",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[800],
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
                          child: Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                        if (_currentStep < 3)
                          ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Next"),
                          ),
                        if (_currentStep == 3)
                          ElevatedButton(
                            onPressed: _saveHostel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Save"),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

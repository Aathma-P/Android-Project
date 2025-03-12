import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HostelDetailPage extends StatelessWidget {
  final Map<String, dynamic> hostelData;

  const HostelDetailPage({super.key, required this.hostelData});

  void _launchGoogleMaps(String latitude, String longitude) async {
    // Parse latitude and longitude as double
    double lat = double.tryParse(latitude) ?? 0.0;
    double lng = double.tryParse(longitude) ?? 0.0;

    final Uri url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  void _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: hostelData['phoneNumber'] ?? '+1234567890',
    );
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch phone call');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the list of image URLs from Firestore
    List<dynamic> imageUrls = hostelData['imageUrls'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(hostelData['propertyName'] ?? 'Hostel Details'),
        backgroundColor: Colors.blue[100],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Image Carousel**
            SizedBox(
              height: 200,
              child: imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      },
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(child: Text("No Image Available")),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // **Property Name**
                  Text(
                    hostelData['propertyName'] ?? "Unnamed Property",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // **Location Details**
                  const SizedBox(height: 8),
                  Text(
                    "${hostelData['city'] ?? 'Unknown'}, ${hostelData['district'] ?? 'Unknown'}, ${hostelData['region'] ?? 'Unknown'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "Pincode: ${hostelData['pincode'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),

                  // **Rating & Reviews**
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(
                        hostelData['rating']?.toString() ?? "4.5",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${hostelData['reviews']?.toString() ?? "100"} reviews)",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),

                  // **Amenities Section**
                  const SizedBox(height: 16),
                  const Text(
                    "Amenities",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: (hostelData['amenities'] is List)
                        ? (hostelData['amenities'] as List)
                            .map((amenity) => Chip(
                                  label: Text(amenity.toString()),
                                  backgroundColor: Colors.blue[50],
                                ))
                            .toList()
                        : [
                            Chip(
                              label: const Text('No amenities'),
                              backgroundColor: Colors.blue[50],
                            ),
                          ],
                  ),

                  // **Description Section**
                  const SizedBox(height: 16),
                  const Text(
                    "About this place",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hostelData['description'] ?? "No description available.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),

                  // **Action Buttons (Map & Contact)**
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _launchGoogleMaps(
                              hostelData['latitude']?.toString() ?? "0.0",
                              hostelData['longitude']?.toString() ?? "0.0",
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("View on Google Maps"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _launchPhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Contact Host"),
                        ),
                      ),
                    ],
                  ),

                  // **Price & Booking**
                  const SizedBox(height: 16),
                  const Text(
                    "Price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${hostelData['price']?.toString() ?? "1000"} / month",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Booking functionality coming soon!"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

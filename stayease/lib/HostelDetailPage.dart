import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class HostelDetailPage extends StatefulWidget {
  final Map<String, dynamic> hostelData;

  const HostelDetailPage({super.key, required this.hostelData});

  @override
  _HostelDetailPageState createState() => _HostelDetailPageState();
}

class _HostelDetailPageState extends State<HostelDetailPage> {
  final _reviewController = TextEditingController();
  int _rating = 0;

  // Function to submit a review
  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to submit a review')),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
      return;
    }

    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a review')),
      );
      return;
    }

    final reviewData = {
      'userId': user.uid,
      'userName': user.displayName ?? 'Anonymous',
      'rating': _rating,
      'comment': _reviewController.text,
    };

    print('Review Data: $reviewData'); // Debug statement

    try {
      // Add the review to the existing hostel document
      await FirebaseFirestore.instance
          .collection('hostels')
          .doc(widget.hostelData['hostelId']) // Ensure hostelId is correct
          .update({
        'reviews': FieldValue.arrayUnion([reviewData]),
      });

      print('Review added to Firestore'); // Debug statement

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );

      // Clear the input fields
      setState(() {
        _rating = 0;
        _reviewController.clear();
      });
    } catch (e) {
      print('Error submitting review: $e'); // Debug statement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  // Function to open Google Maps
  void _launchGoogleMaps(String latitude, String longitude) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  // Function to launch phone call
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch phone call';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageUrls = widget.hostelData['imageUrls'] ?? [];
    List<dynamic> reviews = widget.hostelData['reviews'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostelData['propertyName'] ?? 'Hostel Details'),
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
                    widget.hostelData['propertyName'] ?? "Unnamed Property",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // **Location Details**
                  const SizedBox(height: 8),
                  Text(
                    "${widget.hostelData['city'] ?? 'Unknown'}, ${widget.hostelData['district'] ?? 'Unknown'}, ${widget.hostelData['region'] ?? 'Unknown'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  Text(
                    "Pincode: ${widget.hostelData['pincode'] ?? 'N/A'}",
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
                        widget.hostelData['rating']?.toString() ?? "4.5",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "(${reviews.length} reviews)",
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
                    children: (widget.hostelData['amenities'] is List)
                        ? (widget.hostelData['amenities'] as List)
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
                    widget.hostelData['description'] ??
                        "No description available.",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),

                  // **Google Maps & Contact Buttons**
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _launchGoogleMaps(
                              widget.hostelData['latitude']?.toString() ??
                                  "0.0",
                              widget.hostelData['longitude']?.toString() ??
                                  "0.0",
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
                          onPressed: () {
                            _launchPhone(widget.hostelData['phoneNumber'] ??
                                '+1234567890');
                          },
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

                  // **Review Section**
                  const SizedBox(height: 24),
                  const Text(
                    "Reviews",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (reviews.isEmpty)
                    const Text("No reviews yet.")
                  else
                    Column(
                      children: [
                        // Average Rating
                        Text(
                          "Average Rating: ${_calculateAverageRating(reviews).toStringAsFixed(1)}/5",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reviews List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            var review = reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // User Name and Rating
                                    Row(
                                      children: [
                                        Text(
                                          review['userName'] ?? 'Anonymous',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text('${review['rating']} stars'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Comment
                                    Text(review['comment']),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  // **Inline Review Input**
                  const SizedBox(height: 16),
                  const Text(
                    "Write a Review",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Review Text Field
                  TextFormField(
                    controller: _reviewController,
                    decoration: InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitReview,
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
                      "Submit Review",
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

  // Function to calculate average rating
  double _calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    int totalRating = reviews
        .map((review) => review['rating'] as int)
        .reduce((a, b) => a + b);
    return totalRating / reviews.length;
  }
}

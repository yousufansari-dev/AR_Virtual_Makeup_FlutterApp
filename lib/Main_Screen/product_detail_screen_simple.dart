import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class ProductDetailScreenSimple extends StatefulWidget {
  final String productId;
  final String userId; // Current logged-in user
  final String userName; // Current logged-in user's name
  const ProductDetailScreenSimple({
    super.key,
    required this.productId,
    required this.userId,
    required this.userName,
    required Map<String, dynamic> productData,
  });

  @override
  State<ProductDetailScreenSimple> createState() => _ProductDetailScreenSimpleState();
}

class _ProductDetailScreenSimpleState extends State<ProductDetailScreenSimple> {
  Map<String, dynamic>? productData;
  List<Map<String, dynamic>> comments = [];
  double averageRating = 0.0;

  TextEditingController commentController = TextEditingController();
  double userRating = 0.0;
  PageController pageController = PageController();
  String userName = "";
  bool canReview = false;
  bool hasReviewed = false;
  bool isLoadingReviewStatus = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchProductData();
    checkReviewStatus();
    startAutoSlider();
  }

  Future<void> checkReviewStatus() async {
    setState(() => isLoadingReviewStatus = true);
    
    try {
      // Check if user has purchased this product
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: widget.userId)
          .where('status', isEqualTo: 'completed')
          .get();

      bool hasPurchased = false;
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data();
        final items = orderData['items'] as List<dynamic>? ?? [];
        
        for (var item in items) {
          if (item['productId'] == widget.productId) {
            hasPurchased = true;
            break;
          }
        }
        if (hasPurchased) break;
      }

      // Check if user has already reviewed this product
      final reviewSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('userId', isEqualTo: widget.userId)
          .where('productId', isEqualTo: widget.productId)
          .get();

      setState(() {
        canReview = hasPurchased;
        hasReviewed = reviewSnapshot.docs.isNotEmpty;
        isLoadingReviewStatus = false;
      });
    } catch (e) {
      print('Error checking review status: $e');
      setState(() => isLoadingReviewStatus = false);
    }
  }

  Future<void> fetchUserName() async {
    try {
      String uid = widget.userId;
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?["name"] ?? "Anonymous";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
      userName = "Anonymous";
    }
  }

  void startAutoSlider() {
    Future.delayed(const Duration(seconds: 3), () {
      if (pageController.hasClients && productData != null) {
        int currentPage = (pageController.page?.toInt() ?? 0);
        int nextPage =
            ((currentPage + 1) % (productData!["images"]?.length ?? 1)).toInt();
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        startAutoSlider();
      }
    });
  }

  Future<void> fetchProductData() async {
    var doc = await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      setState(() {
        productData = doc.data();
      });

      try {
        var commentSnapshot = await FirebaseFirestore.instance
            .collection("comments")
            .where("productId", isEqualTo: widget.productId)
            .orderBy("timestamp", descending: true)
            .get();

        var fetchedComments = commentSnapshot.docs.map((doc) {
          var data = doc.data();
          return {
            "name": data["name"] ?? "Anonymous",
            "comment": data["comment"] ?? "",
            "rating": (data["rating"] ?? 0).toDouble(),
            "timestamp": data["timestamp"],
          };
        }).toList();

        double totalRating = 0;
        for (var c in fetchedComments) {
          totalRating += c["rating"];
        }
        double avg = fetchedComments.isNotEmpty
            ? totalRating / fetchedComments.length
            : 0.0;

        setState(() {
          comments = fetchedComments;
          averageRating = avg;
        });
      } catch (e) {
        print("Error fetching comments: $e");
      }
    }
  }

  Future<void> submitComment() async {
    if (commentController.text.isEmpty || userRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both rating and comment')),
      );
      return;
    }

    if (!canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only review products you have purchased')),
      );
      return;
    }

    if (hasReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reviewed this product')),
      );
      return;
    }

    try {
      String productName = productData!["name"] ?? "Unknown Product";
      String productImage =
          (productData!["images"] != null &&
              (productData!["images"] as List).isNotEmpty)
          ? (productData!["images"] as List)[0]
          : "";

      var commentData = {
        "name": userName,
        "comment": commentController.text,
        "rating": userRating,
        "productId": widget.productId,
        "userId": widget.userId, // Add userId for tracking
        "productName": productName,
        "productImage": productImage,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection("comments").add(commentData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      commentController.clear();
      setState(() {
        userRating = 0.0;
        hasReviewed = true;
      });

      // Refresh comments
      Future.delayed(const Duration(milliseconds: 500), () {
        fetchProductData();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (productData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Product Detail",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    List<String> images =
        (productData!["images"] as List?)?.map((e) => e.toString()).toList() ??
        [];
    String name = productData!["name"] ?? "";
    String category = productData!["category"] ?? "";
    String description = productData!["description"] ?? "";
    double price = (productData!["price"] ?? 0).toDouble();
    List<String> shades =
        (productData!["shades"] as List?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: $category",
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PKR $price",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (shades.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shades",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: shades
                              .map(
                                (s) => Chip(
                                  label: Text(s),
                                  backgroundColor: Colors.pink.shade50,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Text(
                    "Description",
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: GoogleFonts.nunito(fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: averageRating,
                        itemBuilder: (context, _) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 24.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${comments.length} reviews)',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Customer Reviews",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  comments.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text("No reviews yet"),
                        )
                      : Column(
                          children: comments.map((comment) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(comment["name"] ?? "Anonymous"),
                                subtitle: Text(comment["comment"] ?? ""),
                                trailing: RatingBarIndicator(
                                  rating: comment["rating"] ?? 0,
                                  itemBuilder: (context, _) =>
                                      const Icon(Icons.star, color: Colors.amber),
                                  itemCount: 5,
                                  itemSize: 18.0,
                                  direction: Axis.horizontal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 20),
                  if (isLoadingReviewStatus)
                    const Center(child: CircularProgressIndicator())
                  else if (!canReview)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You can only review products you have purchased. Buy this product to leave a review!',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (hasReviewed)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Thank you! You have already reviewed this product.',
                              style: TextStyle(color: Colors.green.shade700),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified_user, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You purchased this product! Share your experience.',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Write a Review",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating: userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              userRating = rating;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: "Write your comment...",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: submitComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                          ),
                          child: Text(
                            "Submit Review",
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        child: const Text(
          '💄',
          style: TextStyle(fontSize: 24),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
      ),
    );
  }
}
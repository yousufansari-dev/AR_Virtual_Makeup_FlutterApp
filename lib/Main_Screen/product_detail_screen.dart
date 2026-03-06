import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/review_service.dart';
import '../Models/review_model.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String userId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.userId, required Map<String, dynamic> productData, required String userName,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productData;
  List<Review> reviews = [];
  double averageRating = 0.0;
  final ReviewService _reviewService = ReviewService();

  TextEditingController commentController = TextEditingController();
  double userRating = 0.0;
  PageController pageController = PageController();
  String userName = "Anonymous";

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

  // ✅ Fetch user name
  Future<void> fetchUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?["name"] ?? "Anonymous";
        });
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  // ✅ Check if user can review
  Future<void> checkReviewStatus() async {
    setState(() => isLoadingReviewStatus = true);

    try {
      final hasPurchased = await _reviewService.hasUserPurchasedProduct(
        widget.userId,
        widget.productId,
      );
      final hasReviewedProduct = await _reviewService.hasUserReviewedProduct(
        widget.userId,
        widget.productId,
      );

      setState(() {
        canReview = hasPurchased && !hasReviewedProduct;
        hasReviewed = hasReviewedProduct;
        isLoadingReviewStatus = false;
      });
    } catch (e) {
      print('Error checking review status: $e');
      setState(() => isLoadingReviewStatus = false);
    }
  }

  // ✅ Fetch product data
  Future<void> fetchProductData() async {
    final doc = await FirebaseFirestore.instance
        .collection("products")
        .doc(widget.productId)
        .get();

    if (doc.exists) {
      setState(() {
        productData = doc.data();
      });
      await loadReviews();
    }
  }

  // ✅ Load reviews and average rating
  Future<void> loadReviews() async {
    final fetchedReviews = await _reviewService.getReviews(widget.productId);
    final avgRating = await _reviewService.getAverageRating(widget.productId);

    setState(() {
      reviews = fetchedReviews;
      averageRating = avgRating;
    });
  }

  // ✅ Auto slider for images
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

  // ✅ Submit review
  Future<void> submitComment() async {
    if (commentController.text.isEmpty || userRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating aur comment dono zaroori hain')),
      );
      return;
    }

    if (!canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sirf purchased product review ho sakta hai'),
        ),
      );
      return;
    }

    if (hasReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aap pehle hi review de chuke ho')),
      );
      return;
    }

    await _reviewService.submitReview(
      productId: widget.productId,
      userId: widget.userId,
      userName: userName,
      comment: commentController.text,
      rating: userRating,
    );

    await loadReviews(); // Refresh reviews

    setState(() {
      hasReviewed = true;
      canReview = false;
      userRating = 0;
    });

    commentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (productData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Product Detail"),
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
        title: Text(name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images slider
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
              const SizedBox(height: 12),
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
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
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

              // Rating & Reviews
              Row(
                children: [
                  RatingBarIndicator(
                    rating: averageRating,
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${reviews.length} reviews)',
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

              // Reviews list
              reviews.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text("No reviews yet"),
                    )
                  : Column(
                      children: reviews
                          .map(
                            (review) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(review.userName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(review.comment),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Reviewed on ${review.timestamp.toString().split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: RatingBarIndicator(
                                  rating: review.rating,
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 18,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 20),

              // Review Box
              if (isLoadingReviewStatus)
                const Center(child: CircularProgressIndicator())
              else if (!canReview && !hasReviewed)
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
                          Icon(
                            Icons.verified_user,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You purchased this product! Share your experience with other customers.',
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
                    Text(
                      "Rate this product:",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 12),
                    Text(
                      "Write your review:",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: "Share your experience with this product...",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(177, 8, 46, 92),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Submit Review",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(177, 8, 46, 92),
        child: const Text('💄', style: TextStyle(fontSize: 24)),
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

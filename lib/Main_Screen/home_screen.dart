import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtualmakeupapp/Category_Pages/Blush_try_on.dart';
import 'package:virtualmakeupapp/Category_Pages/Foundation_try_on.dart';
import 'package:virtualmakeupapp/Category_Pages/Glasses_try_on.dart';
import 'package:virtualmakeupapp/Category_Pages/Hair_try_on.dart';
import 'package:virtualmakeupapp/Category_Pages/SkinToneAnalyzer.dart';
import 'package:virtualmakeupapp/Category_Pages/Lipstick_try_on.dart';
import 'package:virtualmakeupapp/Category_Pages/chatbot.dart';
import 'package:virtualmakeupapp/Main_Screen/WishlistScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/CartScreen.dart';
import 'package:virtualmakeupapp/Main_Screen/product_detail_screen.dart';
import 'package:lottie/lottie.dart';

// Import your ProductDetailScreen

class HomeScreen extends StatefulWidget {
  final String userName;

  // const HomeScreen({super.key, required this.userName});

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userGender;
  String selectedCategory = "All";
  String searchQuery = "";
  Set<String> wishlist = {};
  List<Map<String, dynamic>> cartProducts = []; // Add cart functionality

  final List<Map<String, String>> categories = [
    {"name": "Lipstick", "image": "assets/images/lipstick.png"},
    {"name": "Blush", "image": "assets/images/blush.png"},
    {"name": "Foundation", "image": "assets/images/foundation.png"},
    {"name": "Hairstyle", "image": "assets/images/hairstyle.png"},
    {"name": "Glasses", "image": "assets/images/glasses.png"},
  ];

  final List<String> sliderImages = const [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
  ];

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  void initState() {
    super.initState();
    _fetchGender(); // 🔥 Fetch gender when screen loads
  }

  void _fetchGender() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    var user = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (user.exists) {
      setState(() {
        userGender = user.data()?["gender"]?.toString();
      });
    }
  }

  Stream<QuerySnapshot> _getProducts() {
    Query query = FirebaseFirestore.instance.collection("products");

    // Only filter if selectedCategory exists in categories list
    if (selectedCategory != "All" &&
        categories.any((cat) => cat['name'] == selectedCategory)) {
      query = query.where(
        "category",
        isEqualTo: selectedCategory.toLowerCase(),
      );
    }

    return query.snapshots();
  }

  int wishlistCount() => wishlist.length;

  // Gender-based image logic
  String _getUserImage() {
    if (userGender == null) {
      return "https://cdn-icons-png.flaticon.com/512/149/149071.png"; // default icon
    }

    if (userGender!.toLowerCase() == "female") {
      return "https://st4.depositphotos.com/13193658/25036/i/450/depositphotos_250363326-stock-photo-smiling-attractive-woman-white-sweater.jpg"; // NEW Female Image
    } else {
      return "https://t3.ftcdn.net/jpg/02/00/90/24/360_F_200902415_G4eZ9Ok3Ypd4SZZKjc8nqJyFVp1eOD6V.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDECF7),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFFDECF7),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(177, 8, 46, 92),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(_getUserImage()),
                ),
                accountName: Text(
                  widget.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: null,
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              ListTile(
                leading: Icon(
                  Icons.shopping_bag,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "My Orders",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/orders'),
              ),
              ListTile(
                leading: Icon(
                  Icons.info,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "About",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(
                  Icons.compare,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "Comparison Tool",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/comparisonTool'),
              ),
              ListTile(
                leading: Icon(
                  Icons.help,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "Help Center",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/helpCenter'),
              ),
              ListTile(
                leading: Icon(
                  Icons.contact_mail,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "Contact Us",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pushNamed(context, '/ContactUs'),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Color.fromARGB(177, 8, 46, 92),
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut(); // Firebase logout
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ); // Redirect to Login screen
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 2,
        backgroundColor: Color.fromARGB(177, 8, 46, 92),
        title: GestureDetector(
          onTap: () {
            // Popup dialog on title click
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  "Hello 👋",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Greeting: ${getGreeting()}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Username: ${widget.userName}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                ],
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${getGreeting()} 👋",
                style: GoogleFonts.poppins(
                  color: Colors.white, // ✅ text white kar diya
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white,
                      ], // ✅ Pure white gradient
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: Text(
                  widget.userName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Logout Icon
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),

          // Wishlist Icon with badge
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.favorite, color: Colors.white),
                if (wishlist.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${wishlist.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WishlistScreen(
                    wishlist: wishlist.toList(),
                    onWishlistChanged: (id, added) {
                      setState(() {
                        added ? wishlist.add(id) : wishlist.remove(id);
                      });
                    },
                  ),
                ),
              );
            },
          ),

          // Cart Icon with badge
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                if (cartProducts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cartProducts.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              if (cartProducts.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("No products in cart")));
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    cartProducts: cartProducts,
                    cartItems: cartProducts
                        .map((p) => p["id"].toString())
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // SEARCH BAR
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) =>
                        setState(() => searchQuery = val.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search product, brand, category...",
                      prefixIcon: Icon(Icons.search, color: Color(0xFFB83280)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    cursorColor: Color.fromARGB(177, 8, 46, 92),
                  ),
                ),
              ),

              // SLIDER
              CarouselSlider(
                items: sliderImages.map((img) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 160,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 0.90,
                ),
              ),

              SizedBox(height: 10),

              // VIRTUAL TRY ON BUTTON
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(177, 8, 46, 92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/SkinToneAnalyzer',
                    arguments: "",
                  ),
                  child: Text(
                    "Skin Tone Analyzer",
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // CATEGORIES
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Categories",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(177, 8, 46, 92),
                    ),
                  ),
                ),
              ),
              SizedBox(
                //trynow button
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () async {
                        if (cat['name'] == "Lipstick") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LipstickTryNowPage(),
                            ), // Correct Lipstick page
                          );
                        } else if (cat['name'] == "Blush") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlushTryNowPage(),
                            ),
                          );
                        } else if (cat['name'] == "Foundation") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoundationTryNowPage(),
                            ),
                          );
                        } else if (cat['name'] == "Glasses") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GlassesTryNowPage(),
                            ),
                          );
                        } else if (cat['name'] == "Hairstyle") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HairTryNowPage()),
                          );
                        } else if (cat['name'] == "Skin Tone Analyzer") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SkinToneAnalyzerPage(),
                            ),
                          );
                        } else {
                          print("Unknown category: ${cat['name']}");
                        }
                      },

                      child: Container(
                        width: 100,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFC1E3), Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color.fromARGB(177, 8, 46, 92),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(cat['image']!, height: 40),
                            SizedBox(height: 5),
                            Text(
                              cat['name']!,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // RECOMMENDED PRODUCTS
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recommended Products",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(177, 8, 46, 92),
                    ),
                  ),
                ),
              ),
              //StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: _getProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return GridView.builder(
                      padding: EdgeInsets.all(12),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58, // Match the main grid
                      ),
                      itemCount: 6,
                      itemBuilder: (_, __) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    );
                  }

                  var filteredProducts = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final query = searchQuery.toLowerCase();
                    return (data['name'] ?? "")
                        .toString()
                        .toLowerCase()
                        .contains(query);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return Center(child: Text("No products found"));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(12),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58, // Reduced to give more height
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final data =
                          filteredProducts[index].data()
                              as Map<String, dynamic>;

                      final image = (data['images'] as List).isNotEmpty
                          ? data['images'][0]
                          : "https://via.placeholder.com/150";

                      final stock = data['stock'] ?? 0;
                      final sold = data['sold'] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(
                                productId: filteredProducts[index].id,
                                productData: data,
                                userId: FirebaseAuth
                                    .instance
                                    .currentUser!
                                    .uid, // ✅ current user id
                                userName:
                                    widget.userName, // ✅ HomeScreen ka userName
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child:
                                        (data['images'] != null &&
                                            data['images'] is List &&
                                            data['images'].isNotEmpty &&
                                            data['images'][0]
                                                .toString()
                                                .startsWith('http'))
                                        ? Image.network(
                                            data['images'][0],
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Image.asset(
                                                    "assets/images/no_image.png",
                                                    height: 120,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                          )
                                        : Image.asset(
                                            "assets/images/no_image.png",
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),

                                  // ❤️ Wishlist Icon
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        final productId =
                                            filteredProducts[index].id;
                                        final productStock = data['stock'] ?? 0;

                                        setState(() {
                                          if (wishlist.contains(productId)) {
                                            wishlist.remove(productId);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "${data['name']} removed from wishlist",
                                                ),
                                                backgroundColor: Colors.orange,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          } else {
                                            // Check stock before adding to wishlist
                                            if (productStock <= 0) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "${data['name']} is out of stock! Cannot add to wishlist.",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              wishlist.add(productId);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "${data['name']} added to wishlist",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          wishlist.contains(
                                                filteredProducts[index].id,
                                              )
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.pink,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // CONTENT
                              Expanded(
                                // Wrap in Expanded to prevent overflow
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        data['name'] ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14, // Reduced from 15
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2), // Reduced from 4
                                      Text(
                                        "PKR ${data['price']}",
                                        style: TextStyle(
                                          color: Colors.pink,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 2), // Reduced from 4
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Stock: $stock",
                                              style: TextStyle(
                                                fontSize: 10, // Reduced from 11
                                                color: stock == 0
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Sold: $sold",
                                            style: TextStyle(
                                              fontSize: 10, // Reduced from 11
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2), // Reduced from 4
                                      Text(
                                        data['brand'] ?? "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10, // Reduced from 11
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Spacer(), // Push button to bottom
                                      // Add to Cart Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 28, // Reduced from 32
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: stock <= 0
                                                ? Colors.grey
                                                : Color.fromARGB(
                                                    177,
                                                    8,
                                                    46,
                                                    92,
                                                  ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ), // Reduced padding
                                          ),
                                          onPressed: stock <= 0
                                              ? null
                                              : () {
                                                  if (stock <= 0) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "${data['name']} is out of stock! Please update stock.",
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration: Duration(
                                                          seconds: 3,
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  setState(() {
                                                    cartProducts.add({
                                                      "id":
                                                          filteredProducts[index]
                                                              .id,
                                                      "name":
                                                          data['name'] ?? "",
                                                      "image":
                                                          (data["images"]
                                                                  as List)
                                                              .isNotEmpty
                                                          ? data["images"][0]
                                                          : "",
                                                      "price":
                                                          data['price'] ?? 0,
                                                      "brand":
                                                          data['brand'] ?? "",
                                                      "shades":
                                                          (data['shades']
                                                                  as List?)
                                                              ?.cast<
                                                                String
                                                              >() ??
                                                          [],
                                                      "quantity": 1,
                                                    });
                                                  });

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "${data['name']} added to cart",
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                      duration: Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          child: Text(
                                            stock <= 0
                                                ? "Out of Stock"
                                                : "Add to Cart",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9, // Reduced from 10
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(177, 8, 46, 92), // #831843
        child: Text(
          '💄', // Lipstick emoji
          style: TextStyle(fontSize: 24), // make it big enough
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatBotPage()),
          );
        },
      ),

      //bottom navbar
    );
  }
}

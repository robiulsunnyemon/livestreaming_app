import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/explore_controller.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../routes/app_pages.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B15), // Deep dark background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: const Text(
                "Discover",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search creators, tags, or categories",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFF161621),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return Obx(() {
                      final isSelected = controller.selectedCategory.value == cat;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => controller.selectCategory(cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF4C4DDC) : const Color(0xFF161621),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey.shade800,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade400,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),

            // Grid Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4C4DDC)));
                }
                
                if (controller.streams.isEmpty) {
                  return Center(
                    child: Text(
                      "No active streams found.",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7, // Adjust based on your card design
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: controller.streams.length,
                  itemBuilder: (context, index) {
                    final stream = controller.streams[index];
                    return _buildLiveCard(stream);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar placeholder if needed, or integrated into main layout
    );
  }

  Widget _buildLiveCard(LiveStreamModel stream) {
    return GestureDetector(
      onTap: () => controller.joinStream(stream),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(stream.thumbnail != null && stream.thumbnail!.isNotEmpty 
                ? AuthService.getFullUrl(stream.thumbnail!)
                : "https://via.placeholder.com/300"), // Fallback or base URL handling
            fit: BoxFit.cover,
          ),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            
            // Live Tag & Viewers
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF005C), // Pink/Red for LIVE
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Live",
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "${stream.totalViews}", // Or active viewers if model has it
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stream.isPremium ? const Color(0xFFFFD700) : const Color(0xFF4CAF50), // Gold/Green
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stream.isPremium ? "${stream.entryFee}" : "Free",
                      style: TextStyle(
                        color: stream.isPremium ? Colors.black : Colors.white, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // User Info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                       CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(stream.thumbnail ?? ""), // Theoretically host image
                         // If model has host object, use stream.host.profileImage
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stream.title ?? "Unknown User",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stream.category ?? "General",
                    style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  
                  // Trust Score Bar (Mockup based on image)
                  Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        height: 4,
                        width: 100, // Dynamic based on score needed
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Legit: 98%", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                      Text("Shady: 2%", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

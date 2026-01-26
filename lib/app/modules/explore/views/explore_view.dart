import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../controllers/explore_controller.dart';
import '../../../data/models/live_stream_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Deep dark background
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
                controller: controller.searchController,
                onChanged: (val) => controller.onSearch(val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  filled: true,
                  fillColor: AppColors.surface,
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
                              color: isSelected ? AppColors.secondaryPrimary : const Color(0xFF161621),
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
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
                    childAspectRatio: 0.65, // Unified ratio
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
    final shady = stream.host?.shady ?? 0;
    final legit = 100 - shady;
    return GestureDetector(
      onTap: () => controller.joinStream(stream),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(
                stream.thumbnail != null && stream.thumbnail!.isNotEmpty 
                ? AuthService.getFullUrl(stream.thumbnail!)
                : "https://via.placeholder.com/300"
            ),
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
            // Dark Gradient Overlay
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

            // Top Tags
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("Live", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                        const SizedBox(width: 4),
                        Text("${stream.totalViews}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stream.isPremium ? AppColors.warning : AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        stream.isPremium ? "${stream.entryFee}" : "Free",
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
                   // Row(
                   //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   //    children: [
                   //       Container(
                   //        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   //        decoration: BoxDecoration(
                   //          color: AppColors.secondaryPrimary,
                   //          borderRadius: BorderRadius.circular(8),
                   //        ),
                   //        child: Row(
                   //          children: [
                   //            const Icon(Icons.remove_red_eye, color: Colors.white, size: 10),
                   //            const SizedBox(width: 4),
                   //            Text("${stream.totalViews}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                   //          ],
                   //        ),
                   //      ),
                   //      const SizedBox(width: 6),
                   //      Container(
                   //        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   //        decoration: BoxDecoration(
                   //          color: stream.isPremium ? AppColors.warning : AppColors.yellow,
                   //          borderRadius: BorderRadius.circular(8),
                   //        ),
                   //        child: Text(
                   //            stream.isPremium ? "${stream.entryFee}" : "Free",
                   //            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)
                   //        ),
                   //      ),
                   //    ],
                   // )
                ],
              ),
            ),

            // Bottom Info
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 14,
                           backgroundImage: NetworkImage(stream.thumbnail ?? ""),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${stream.hostFirstName ?? ''} ${stream.hostLastName ?? ''}".trim().isEmpty 
                                  ? "Unknown Host" 
                                  : "${stream.hostFirstName ?? ''} ${stream.hostLastName ?? ''}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(
                              stream.title ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade300, fontSize: 10),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Legit Bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        if (legit > 0)
                          Expanded(
                            flex: legit.toInt(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.vibrantSuccess,
                                borderRadius: BorderRadius.horizontal(
                                  left: const Radius.circular(3),
                                  right: Radius.circular(shady == 0 ? 3 : 0),
                                ),
                              ),
                            ),
                          ),
                        if (shady > 0)
                          Expanded(
                            flex: shady.toInt(),
                             child: Container(
                               decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                borderRadius: BorderRadius.horizontal(
                                  right: const Radius.circular(3),
                                  left: Radius.circular(legit == 0 ? 3 : 0),
                                ),
                              ),
                             ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Legit: $legit%", style: TextStyle(color: Colors.grey.shade400, fontSize: 9)),
                      Text("Shady: $shady%", style: TextStyle(color: AppColors.error, fontSize: 9)),
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

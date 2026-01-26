import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../data/models/live_stream_model.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Dark background
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Obx(() => controller.isSearching.value 
                ? Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: TextField(
                            controller: controller.searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            onChanged: (val) => controller.onSearch(val),
                            decoration: const InputDecoration(
                              hintText: "Search by name, title, category...",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Colors.grey, size: 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          controller.isSearching.value = false;
                          controller.searchController.clear();
                          controller.onSearch("");
                        },
                        child: const Text("Cancel", style: TextStyle(color: AppColors.primary)),
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text(
                             "INSTALIVE", 
                             style: TextStyle(
                               color: Color(0xFF4C4DDC), 
                               fontWeight: FontWeight.bold, 
                               letterSpacing: 1.2
                             )
                           ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildIconButton(Icons.search, () {
                            controller.isSearching.value = true;
                          }),
                          const SizedBox(width: 12),
                          _buildIconButton(Icons.notifications_outlined, () {
                            Get.toNamed(Routes.NOTIFICATION);
                          }),
                        ],
                      )
                    ],
                  )
              ),
            ),

            // Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    return Obx(() {
                      final isSelected = controller.selectedFilter.value == filter;
                      return GestureDetector(
                        onTap: () => controller.onChangeFilter(filter),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.secondaryPrimary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey.shade800
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade400,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // Grid Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                if (controller.streams.isEmpty) {
                   return Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.videocam_off, color: Colors.grey, size: 48),
                         const SizedBox(height: 16),
                         Text("No active streams", style: TextStyle(color: Colors.grey.shade600)),
                       ],
                     ),
                   );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchStreams,
                  color: const Color(0xFF4C4DDC),
                  backgroundColor: const Color(0xFF161621),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65, // Taller cards
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: controller.streams.length,
                    itemBuilder: (context, index) {
                      final stream = controller.streams[index];
                      return _buildStreamCard(stream);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStreamCard(LiveStreamModel stream) {
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
                      color: AppColors.secondaryPrimary, // Blurple tag for view count
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
                      color: stream.isPremium ? AppColors.warning :  AppColors.warning, // Gold/Yellow
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                        stream.isPremium ? "${stream.entryFee}" : "Free",
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ),
                   // Row(
                   //    children: [
                   //       Container(
                   //        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   //        decoration: BoxDecoration(
                   //          color: AppColors.primary, // Blurple tag for view count
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
                   //          color: stream.isPremium ? const Color(0xFFFFD700) : const Color(0xFFFFFF00), // Gold/Yellow
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
                           backgroundImage: NetworkImage(stream.thumbnail ?? ""), // Should be host image
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
                        if (shady! > 0)
                          Expanded(
                            flex: shady.toInt(),
                             child: Container(
                               decoration: BoxDecoration(
                                color: AppColors.accent,
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
                      Text("Shady: $shady%", style: TextStyle(color: Colors.redAccent, fontSize: 9)),
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

import 'dart:io';
import 'package:get/get.dart';
import '../models/review.dart';
import '../service/review_service.dart';

/// Controller for managing reviews and ratings
class ReviewController extends GetxController {
  final ReviewService _reviewService = Get.find<ReviewService>();

  // Product reviews
  var productReviews = <Review>[].obs;
  var reviewSummary = Rx<ReviewSummary?>(null);
  var isLoadingReviews = false.obs;

  // User reviews
  var userReviews = <Review>[].obs;
  var isLoadingUserReviews = false.obs;

  // Review submission
  var isSubmitting = false.obs;

  // Filters
  var currentFilter = ReviewFilter().obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreReviews = true.obs;
  var isLoadingMore = false.obs;

  // Current product being reviewed
  var currentProductId = ''.obs;

  // ============================================
  // Product Reviews
  // ============================================

  /// Load reviews for a product
  Future<void> loadProductReviews({
    required String productId,
    bool resetPage = true,
  }) async {
    try {
      if (resetPage) {
        currentPage.value = 1;
        productReviews.clear();
        hasMoreReviews.value = true;
        currentProductId.value = productId;
      }

      isLoadingReviews.value = true;

      final reviews = await _reviewService.getProductReviews(
        productId: productId,
        page: currentPage.value,
        filter: currentFilter.value,
      );

      if (resetPage) {
        productReviews.value = reviews;
      } else {
        productReviews.addAll(reviews);
      }

      hasMoreReviews.value = reviews.length >= 20;

      // Load review summary
      if (resetPage) {
        await _loadReviewSummary(productId);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load reviews: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// Load more reviews (pagination)
  Future<void> loadMoreReviews() async {
    if (!hasMoreReviews.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;
      await loadProductReviews(
        productId: currentProductId.value,
        resetPage: false,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Load review summary
  Future<void> _loadReviewSummary(String productId) async {
    try {
      final summary = await _reviewService.getReviewSummary(productId);
      reviewSummary.value = summary;
    } catch (e) {
      print('Failed to load review summary: $e');
    }
  }

  // ============================================
  // Review Submission
  // ============================================

  /// Submit a review
  Future<bool> submitReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<File>? images,
  }) async {
    try {
      isSubmitting.value = true;

      final review = await _reviewService.submitReview(
        productId: productId,
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      );

      // Add to product reviews if currently viewing this product
      if (currentProductId.value == productId) {
        productReviews.insert(0, review);
        // Reload summary to update stats
        await _loadReviewSummary(productId);
      }

      Get.snackbar(
        'Success',
        'Review submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit review: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Update a review
  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  }) async {
    try {
      isSubmitting.value = true;

      final updatedReview = await _reviewService.updateReview(
        reviewId: reviewId,
        rating: rating,
        title: title,
        comment: comment,
      );

      // Update in product reviews list
      final index = productReviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        productReviews[index] = updatedReview;
      }

      // Update in user reviews list
      final userIndex = userReviews.indexWhere((r) => r.id == reviewId);
      if (userIndex != -1) {
        userReviews[userIndex] = updatedReview;
      }

      Get.snackbar(
        'Success',
        'Review updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update review: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Delete a review
  Future<bool> deleteReview(String reviewId) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await _reviewService.deleteReview(reviewId);

      // Remove from product reviews
      productReviews.removeWhere((r) => r.id == reviewId);

      // Remove from user reviews
      userReviews.removeWhere((r) => r.id == reviewId);

      // Reload summary
      if (currentProductId.value.isNotEmpty) {
        await _loadReviewSummary(currentProductId.value);
      }

      Get.snackbar(
        'Success',
        'Review deleted',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete review: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ============================================
  // Helpful Votes
  // ============================================

  /// Mark review as helpful or not helpful
  Future<void> markReviewHelpful({
    required String reviewId,
    required bool helpful,
  }) async {
    try {
      await _reviewService.markReviewHelpful(
        reviewId: reviewId,
        helpful: helpful,
      );

      // Update review in list
      final review = productReviews.firstWhere((r) => r.id == reviewId);
      if (helpful) {
        review.helpfulCount++;
      }
      productReviews.refresh();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark review: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // Filters
  // ============================================

  /// Apply review filter
  Future<void> applyFilter(ReviewFilter filter) async {
    currentFilter.value = filter;
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  /// Filter by rating
  Future<void> filterByRating(int? rating) async {
    currentFilter.value = currentFilter.value.copyWith(rating: rating);
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  /// Toggle verified only filter
  Future<void> toggleVerifiedOnly() async {
    currentFilter.value = currentFilter.value.copyWith(
      verifiedOnly: !(currentFilter.value.verifiedOnly ?? false),
    );
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  /// Toggle photos only filter
  Future<void> togglePhotosOnly() async {
    currentFilter.value = currentFilter.value.copyWith(
      withPhotosOnly: !(currentFilter.value.withPhotosOnly ?? false),
    );
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  /// Change sort option
  Future<void> changeSortOption(ReviewSortBy sortBy) async {
    currentFilter.value = currentFilter.value.copyWith(sortBy: sortBy);
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    currentFilter.value = ReviewFilter();
    await loadProductReviews(
      productId: currentProductId.value,
      resetPage: true,
    );
  }

  // ============================================
  // User Reviews
  // ============================================

  /// Load user's own reviews
  Future<void> loadUserReviews() async {
    try {
      isLoadingUserReviews.value = true;

      final reviews = await _reviewService.getUserReviews();
      userReviews.value = reviews;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load your reviews: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingUserReviews.value = false;
    }
  }

  // ============================================
  // Review Eligibility
  // ============================================

  /// Check if user can review product
  Future<bool> canReviewProduct(String productId) async {
    try {
      return await _reviewService.canReviewProduct(productId);
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // Report Review
  // ============================================

  /// Report a review
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      await _reviewService.reportReview(
        reviewId: reviewId,
        reason: reason,
      );

      Get.snackbar(
        'Success',
        'Review reported. Thank you for your feedback.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to report review: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // Getters
  // ============================================

  /// Get average rating
  double get averageRating => reviewSummary.value?.averageRating ?? 0.0;

  /// Get total reviews
  int get totalReviews => reviewSummary.value?.totalReviews ?? 0;

  /// Get reviews by rating
  Map<int, int> get ratingDistribution =>
      reviewSummary.value?.ratingDistribution ?? {};

  /// Check if user has reviewed the current product
  bool get hasUserReviewed {
    return userReviews.any((r) => r.productId == currentProductId.value);
  }

  /// Get user's review for current product
  Review? get userReviewForCurrentProduct {
    try {
      return userReviews.firstWhere((r) => r.productId == currentProductId.value);
    } catch (e) {
      return null;
    }
  }

  /// Check if has any filters active
  bool get hasActiveFilters {
    return currentFilter.value.rating != null ||
        currentFilter.value.verifiedOnly == true ||
        currentFilter.value.withPhotosOnly == true;
  }
}

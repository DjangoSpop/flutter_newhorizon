import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'api_service.dart';

/// Service for managing product reviews and ratings
class ReviewService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get reviews for a product
  Future<List<Review>> getProductReviews({
    required String productId,
    int page = 1,
    int pageSize = 20,
    ReviewFilter? filter,
  }) async {
    try {
      // Build query parameters
      String queryParams = '?page=$page&page_size=$pageSize';

      if (filter != null) {
        if (filter.rating != null) {
          queryParams += '&rating=${filter.rating}';
        }
        if (filter.verifiedOnly == true) {
          queryParams += '&verified=true';
        }
        if (filter.withPhotosOnly == true) {
          queryParams += '&with_photos=true';
        }
        queryParams += '&sort_by=${filter.sortBy.apiValue}';
      }

      final response = await _apiService.get(
        '/products/$productId/reviews/$queryParams',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reviews = data['reviews'] ?? data['results'] ?? [];

        return reviews.map((item) => Review.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get reviews');
      }
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  /// Get review summary for a product
  Future<ReviewSummary> getReviewSummary(String productId) async {
    try {
      final response = await _apiService.get(
        '/products/$productId/reviews/summary/',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ReviewSummary.fromJson(data);
      } else {
        throw Exception('Failed to get review summary');
      }
    } catch (e) {
      throw Exception('Failed to get review summary: $e');
    }
  }

  /// Submit a review
  Future<Review> submitReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<File>? images,
  }) async {
    try {
      // If there are images, use multipart request
      if (images != null && images.isNotEmpty) {
        return await _submitReviewWithImages(
          productId: productId,
          rating: rating,
          title: title,
          comment: comment,
          images: images,
        );
      }

      // Simple JSON request if no images
      final response = await _apiService.post('/reviews/', {
        'product_id': productId,
        'rating': rating,
        'title': title,
        'comment': comment,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  /// Submit review with images (multipart)
  Future<Review> _submitReviewWithImages({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    required List<File> images,
  }) async {
    try {
      final token = await _apiService.getToken();
      final baseUrl = _apiService.baseUrl;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reviews/'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';

      // Add fields
      request.fields['product_id'] = productId;
      request.fields['rating'] = rating.toString();
      if (title != null) request.fields['title'] = title;
      if (comment != null) request.fields['comment'] = comment;

      // Add images
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            file.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to submit review with images');
      }
    } catch (e) {
      throw Exception('Failed to submit review with images: $e');
    }
  }

  /// Update a review
  Future<Review> updateReview({
    required String reviewId,
    int? rating,
    String? title,
    String? comment,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (rating != null) data['rating'] = rating;
      if (title != null) data['title'] = title;
      if (comment != null) data['comment'] = comment;

      final response = await _apiService.patch('/reviews/$reviewId/', data);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Review.fromJson(responseData);
      } else {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await _apiService.delete('/reviews/$reviewId/');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Mark review as helpful
  Future<void> markReviewHelpful({
    required String reviewId,
    required bool helpful,
  }) async {
    try {
      final response = await _apiService.post('/reviews/$reviewId/helpful/', {
        'helpful': helpful,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to mark review as helpful');
      }
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  /// Get user's reviews
  Future<List<Review>> getUserReviews({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/reviews/my-reviews/?page=$page&page_size=$pageSize',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reviews = data['reviews'] ?? data['results'] ?? [];

        return reviews.map((item) => Review.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get user reviews');
      }
    } catch (e) {
      throw Exception('Failed to get user reviews: $e');
    }
  }

  /// Check if user can review product
  Future<bool> canReviewProduct(String productId) async {
    try {
      final response = await _apiService.get(
        '/products/$productId/can-review/',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['can_review'] ?? false;
      }

      return false;
    } catch (e) {
      print('Failed to check review eligibility: $e');
      return false;
    }
  }

  /// Report a review
  Future<void> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    try {
      final response = await _apiService.post('/reviews/$reviewId/report/', {
        'reason': reason,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report review');
      }
    } catch (e) {
      throw Exception('Failed to report review: $e');
    }
  }
}

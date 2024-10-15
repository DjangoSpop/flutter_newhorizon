import 'package:get/get.dart';
import 'package:lego_app/models/group_buy.dart';
import 'package:lego_app/models/group_buy_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroupBuyService extends GetxService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<GroupBuyItem>> getGroupBuyItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/group-buys/'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => GroupBuyItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load group buy items');
      }
    } catch (e) {
      throw Exception('Failed to load group buy items: $e');
    }
  }

  Future<GroupBuyItem> createGroupBuy(GroupBuyItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group-buys/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item.toJson()),
      );
      if (response.statusCode == 201) {
        return GroupBuyItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create group buy');
      }
    } catch (e) {
      throw Exception('Failed to create group buy: $e');
    }
  }

  Future<GroupBuyItem> joinGroupBuy(String groupBuyId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group-buys/$groupBuyId/join/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );
      if (response.statusCode == 200) {
        return GroupBuyItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to join group buy');
      }
    } catch (e) {
      throw Exception('Failed to join group buy: $e');
    }
  }

  Future<void> leaveGroupBuy(String groupBuyId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/group-buys/$groupBuyId/leave/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to leave group buy');
      }
    } catch (e) {
      throw Exception('Failed to leave group buy: $e');
    }
  }
}

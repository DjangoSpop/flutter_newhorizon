import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/group_buy_controller.dart';
import '../models/group_buy_item.dart';

class GroupBuyShareSheet extends StatelessWidget {
  final GroupBuyItem groupBuy;
  final GroupBuyController controller = Get.find();

  GroupBuyShareSheet({Key? key, required this.groupBuy}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Share Group Buy',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                icon: 'assets/icons/whatsapp.png',
                label: 'WhatsApp',
                color: Color(0xFF25D366),
                onTap: () => controller.shareViaWhatsApp(groupBuy),
              ),
              _buildShareButton(
                icon: 'assets/icons/facebook.png',
                label: 'Facebook',
                color: Color(0xFF1877F2),
                onTap: () => controller.shareViaFacebook(groupBuy),
              ),
              _buildShareButton(
                icon: Icons.share,
                label: 'More',
                color: Colors.grey[700]!,
                onTap: () => controller.shareGroupBuy(
                  groupBuy,
                  platform: SharePlatform.whatsapp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (controller.currentShareLink.isNotEmpty)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.currentShareLink.value,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: controller.currentShareLink.value,
                        ));
                        Get.snackbar(
                          'Copied',
                          'Share link copied to clipboard',
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required dynamic icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: icon is IconData
                ? Icon(icon, color: color, size: 30)
                : Image.asset(icon, width: 30, height: 30),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

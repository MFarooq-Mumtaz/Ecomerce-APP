import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../data/models/order_models.dart';

/// One order as a vendor sees it: only that vendor's own line items.
class VendorOrderCard extends StatelessWidget {
  const VendorOrderCard({required this.order, required this.items, super.key});

  final OrderModel order;
  final List<OrderItemSnapshot> items;

  @override
  Widget build(BuildContext context) {
    final vendorTotal = items.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.shortReference}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium,
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: context.colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            for (final item in items) _VendorOrderLine(item: item),
            Divider(
              height: 16,
              color: context.colors.background,
              thickness: 1.5,
            ),
            Row(
              children: [
                // The label takes all space the price leaves free.
                Expanded(
                  child: Text(
                    'Your items total',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${vendorTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Just now';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day} ${months[local.month - 1]} ${local.year}, '
        '${local.hour}:$minute';
  }
}

class _VendorOrderLine extends StatelessWidget {
  const _VendorOrderLine({required this.item});

  final OrderItemSnapshot item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Smaller thumbnail when the card is narrow.
        final imageSize = constraints.maxWidth < 300 ? 40.0 : 48.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.white,
                  child: ProductImage(imageUrl: item.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${item.lineTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty
        ? 'Pending'
        : '${status[0].toUpperCase()}${status.substring(1)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}

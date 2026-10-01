import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CheckoutSummary extends StatelessWidget {
  const CheckoutSummary({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onPlaceOrder,
    required this.isPlacingOrder,
    super.key,
  });

  final double subtotal;
  final double shipping;
  final double total;
  final VoidCallback? onPlaceOrder;
  final bool isPlacingOrder;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.surface)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Subtotal', value: subtotal),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Shipping', value: shipping),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Total', value: total, isStrong: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isPlacingOrder ? null : onPlaceOrder,
                child: isPlacingOrder
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  final String label;
  final double value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = isStrong
        ? AppTextStyles.titleMedium
        : AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700);

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: style.copyWith(color: isStrong ? AppColors.primary : null),
        ),
      ],
    );
  }
}

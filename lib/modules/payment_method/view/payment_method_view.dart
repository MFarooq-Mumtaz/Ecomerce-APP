import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_layout.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/unfocus_on_tap.dart';

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          title: Text('Payment Method', style: AppTextStyles.titleMedium),
          centerTitle: true,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.pagePadding,
                  16,
                  AppLayout.pagePadding,
                  32,
                ),
                children: [
                  const _PaymentInfoCard(),
                  const SizedBox(height: 24),
                  Text('Add Card', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  const _UiOnlyCardForm(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: AppLayout.buttonHeight,
                    child: FilledButton(
                      onPressed: () => Get.snackbar(
                        'Payment Method',
                        'Payment integration will be added later.',
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaymentInfoCard extends StatelessWidget {
  const _PaymentInfoCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              child: Icon(Icons.credit_card),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment UI only', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'No card data is saved or processed in this phase.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UiOnlyCardForm extends StatelessWidget {
  const _UiOnlyCardForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _PaymentInput(label: 'Card number'),
        _PaymentInput(label: 'Cardholder name'),
        Row(
          children: [
            Expanded(child: _PaymentInput(label: 'Expiry')),
            SizedBox(width: 12),
            Expanded(child: _PaymentInput(label: 'CVV')),
          ],
        ),
      ],
    );
  }
}

class _PaymentInput extends StatelessWidget {
  const _PaymentInput({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          helperText: 'Future payment integration',
        ),
      ),
    );
  }
}

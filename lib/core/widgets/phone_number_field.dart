import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';

export 'package:intl_phone_field/phone_number.dart' show PhoneNumber;

/// Phone input with a country code picker (flag + dial code) in front.
///
/// [onChanged] always receives the number with the currently selected
/// country code, also when only the country is changed.
class PhoneNumberField extends StatefulWidget {
  const PhoneNumberField({
    required this.controller,
    required this.onChanged,
    super.key,
    this.label = 'Phone number',
    this.initialCountryCode = defaultCountryCode,
    this.textInputAction = TextInputAction.next,
  });

  /// Pakistan is preselected; users can pick any other country.
  static const defaultCountryCode = 'PK';

  final TextEditingController controller;
  final ValueChanged<PhoneNumber> onChanged;
  final String label;
  final String initialCountryCode;
  final TextInputAction textInputAction;

  @override
  State<PhoneNumberField> createState() => _PhoneNumberFieldState();
}

/// In these countries the leading 0 is part of the number itself.
const _countriesKeepingZero = {'IT', 'SM', 'VA'};

class _PhoneNumberFieldState extends State<PhoneNumberField> {
  late Country _country = countries.firstWhere(
    (country) => country.code == widget.initialCountryCode,
  );

  void _notify(String number) {
    widget.onChanged(
      PhoneNumber(
        countryISOCode: _country.code,
        countryCode: '+${_country.fullCountryCode}',
        number: number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      controller: widget.controller,
      initialCountryCode: widget.initialCountryCode,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _DropLeadingZeroFormatter(
          isEnabled: () => !_countriesKeepingZero.contains(_country.code),
        ),
      ],
      textInputAction: widget.textInputAction,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      invalidNumberMessage: 'Enter a valid phone number.',
      style: AppTextStyles.bodyLarge,
      dropdownTextStyle: AppTextStyles.bodyLarge,
      dropdownIcon: Icon(
        Icons.arrow_drop_down,
        color: context.colors.textMuted,
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 12),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: _country.code == 'PK' ? '3001234567' : null,
        // Hides the "0/10" length counter under the field.
        counterText: '',
        errorStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
      ),
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: context.colors.background,
        countryNameStyle: AppTextStyles.bodyLarge,
        countryCodeStyle: AppTextStyles.bodyLarge.copyWith(
          color: context.colors.textMuted,
        ),
        searchFieldCursorColor: AppColors.primary,
        searchFieldInputDecoration: const InputDecoration(
          labelText: 'Search country',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      onChanged: (phone) => _notify(phone.number),
      onCountryChanged: (country) {
        setState(() => _country = country);
        _notify(widget.controller.text.trim());
      },
    );
  }
}

/// People often type the local "0" prefix (0300...). With the country code
/// already shown in front, that 0 must not be part of the number.
class _DropLeadingZeroFormatter extends TextInputFormatter {
  _DropLeadingZeroFormatter({required this.isEnabled});

  final bool Function() isEnabled;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!isEnabled() || !newValue.text.startsWith('0')) {
      return newValue;
    }
    final text = newValue.text.replaceFirst(RegExp('^0+'), '');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/phone_number_field.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/order_models.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../cart/controller/cart_controller.dart';

enum CheckoutLoadStatus { idle, loading, success, error }

class CheckoutController extends GetxController {
  CheckoutController(
    this._authService,
    this._addressRepository,
    this._orderRepository,
    this._cartController,
  );

  final AuthService _authService;
  final AddressRepository _addressRepository;
  final OrderRepository _orderRepository;
  final CartController _cartController;

  final status = CheckoutLoadStatus.idle.obs;
  final addresses = <AddressModel>[].obs;
  final selectedAddressId = RxnString();
  final showAddressForm = false.obs;
  final isSavingAddress = false.obs;
  final isPlacingOrder = false.obs;
  final errorMessage = RxnString();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();

  /// Latest value from the phone field, including the country code.
  PhoneNumber? _phone;
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final countryController = TextEditingController(text: 'Pakistan');

  double get subtotal => _cartController.subtotal;
  double get total => subtotal;
  int get itemCount => _cartController.itemCount;
  List<CartProductItem> get cartItems => _cartController.items.toList();

  AddressModel? get selectedAddress {
    final selectedId = selectedAddressId.value;
    if (selectedId == null) {
      return addresses.isEmpty ? null : addresses.first;
    }

    for (final address in addresses) {
      if (address.id == selectedId) {
        return address;
      }
    }

    return addresses.isEmpty ? null : addresses.first;
  }

  @override
  void onInit() {
    super.onInit();
    loadCheckout();
  }

  Future<void> loadCheckout() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      status.value = CheckoutLoadStatus.error;
      errorMessage.value = 'Please sign in to checkout.';
      return;
    }

    status.value = CheckoutLoadStatus.loading;
    errorMessage.value = null;

    try {
      await _cartController.loadCart();
      final loadedAddresses = await _addressRepository.getAddresses(uid);
      addresses.assignAll(loadedAddresses);
      selectedAddressId.value = loadedAddresses.isEmpty
          ? null
          : loadedAddresses.first.id;
      showAddressForm.value = loadedAddresses.isEmpty;
      status.value = CheckoutLoadStatus.success;
    } catch (_) {
      errorMessage.value = 'Checkout could not be loaded. Please try again.';
      status.value = CheckoutLoadStatus.error;
    }
  }

  void onPhoneChanged(PhoneNumber phone) {
    _phone = phone;
  }

  void selectAddress(AddressModel address) {
    selectedAddressId.value = address.id;
  }

  void toggleAddressForm() {
    showAddressForm.toggle();
  }

  Future<void> saveAddress() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null || isSavingAddress.value) {
      return;
    }

    final validation = _validateAddress();
    if (validation != null) {
      AppSnackbar.show('Address', validation);
      return;
    }

    isSavingAddress.value = true;
    try {
      final address = AddressModel(
        id: '',
        fullName: fullNameController.text.trim(),
        // Saved in international format, e.g. +923001234567.
        phone: _phone!.completeNumber,
        addressLine1: addressLine1Controller.text.trim(),
        addressLine2: addressLine2Controller.text.trim().isEmpty
            ? null
            : addressLine2Controller.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        country: countryController.text.trim(),
        isDefault: addresses.isEmpty,
      );
      final addressId = await _addressRepository.createAddress(
        uid: uid,
        address: address,
        makeDefault: addresses.isEmpty,
      );
      _clearAddressForm();
      await loadCheckout();
      selectedAddressId.value = addressId;
      showAddressForm.value = false;
      AppSnackbar.show('Address', 'Delivery address saved.');
    } catch (_) {
      AppSnackbar.show('Address', 'Could not save address. Try again.');
    } finally {
      isSavingAddress.value = false;
    }
  }

  Future<void> placeOrder() async {
    final firebaseUser = _authService.currentUser;
    final address = selectedAddress;
    if (firebaseUser == null || isPlacingOrder.value) {
      return;
    }
    if (_cartController.items.isEmpty) {
      AppSnackbar.show('Checkout', 'Your cart is empty.');
      return;
    }
    if (address == null) {
      AppSnackbar.show('Checkout', 'Add a delivery address first.');
      return;
    }

    isPlacingOrder.value = true;
    try {
      await _orderRepository.createOrder(
        draft: PlaceOrderDraft(customerId: firebaseUser.uid, address: address),
        cartItems: _cartController.items.toList(),
      );

      // The order transaction already removed the cart documents.
      _cartController.clearSession();
      await _cartController.loadCart();
      Get.offAllNamed(AppRoutes.home);
      AppSnackbar.show('Order placed', 'Your order has been placed.');
    } on OrderFailure catch (failure) {
      AppSnackbar.show('Checkout', failure.message);
      await _cartController.loadCart();
    } catch (_) {
      AppSnackbar.show('Checkout', 'Order could not be placed. Try again.');
    } finally {
      isPlacingOrder.value = false;
    }
  }

  String? _validateAddress() {
    if (fullNameController.text.trim().isEmpty) {
      return 'Enter full name.';
    }
    final phoneError = AppValidators.phone(_phone);
    if (phoneError != null) {
      return phoneError;
    }
    if (addressLine1Controller.text.trim().isEmpty) {
      return 'Enter address line 1.';
    }
    if (cityController.text.trim().isEmpty) {
      return 'Enter city.';
    }
    if (stateController.text.trim().isEmpty) {
      return 'Enter state or province.';
    }
    if (postalCodeController.text.trim().isEmpty) {
      return 'Enter postal code.';
    }
    if (countryController.text.trim().isEmpty) {
      return 'Enter country.';
    }
    return null;
  }

  void _clearAddressForm() {
    fullNameController.clear();
    phoneController.clear();
    _phone = null;
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.text = 'Pakistan';
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    super.onClose();
  }
}

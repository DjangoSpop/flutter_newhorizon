import 'package:get/get.dart';
import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/payment_method.dart';
import '../service/checkout_service.dart';
import '../service/cart_service.dart';
import 'cart_controller.dart';

/// Controller for managing checkout flow
class CheckoutController extends GetxController {
  final CheckoutService _checkoutService = Get.find<CheckoutService>();
  final CartController _cartController = Get.find<CartController>();

  // Checkout steps
  var currentStep = 0.obs;
  var isProcessing = false.obs;

  // Addresses
  var addresses = <Address>[].obs;
  var selectedShippingAddress = Rx<Address?>(null);
  var selectedBillingAddress = Rx<Address?>(null);
  var useSameAddress = true.obs;
  var isLoadingAddresses = false.obs;

  // Shipping
  var shippingMethods = <ShippingMethod>[].obs;
  var selectedShippingMethod = Rx<ShippingMethod?>(null);
  var isLoadingShipping = false.obs;

  // Payment
  var paymentMethods = <PaymentMethod>[].obs;
  var selectedPaymentMethod = Rx<PaymentMethod?>(null);
  var isLoadingPaymentMethods = false.obs;

  // Order summary
  var checkoutSummary = Rx<CheckoutSummary?>(null);
  var notes = ''.obs;

  // Promo code
  var promoCode = ''.obs;
  var promoDiscount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddresses();
    _loadPaymentMethods();
  }

  // ============================================
  // Step Navigation
  // ============================================

  /// Go to next step
  Future<bool> nextStep() async {
    if (!await _validateCurrentStep()) {
      return false;
    }

    if (currentStep.value < 4) {
      currentStep.value++;
      await _updateCheckoutSummary();
      return true;
    }

    return false;
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      currentStep.value = step;
    }
  }

  /// Validate current step
  Future<bool> _validateCurrentStep() async {
    switch (currentStep.value) {
      case 0: // Cart review
        return _cartController.validateCart();

      case 1: // Shipping address
        if (selectedShippingAddress.value == null) {
          Get.snackbar(
            'Error',
            'Please select a shipping address',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        if (!useSameAddress.value && selectedBillingAddress.value == null) {
          Get.snackbar(
            'Error',
            'Please select a billing address',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        return true;

      case 2: // Shipping method
        if (selectedShippingMethod.value == null) {
          Get.snackbar(
            'Error',
            'Please select a shipping method',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        return true;

      case 3: // Payment
        if (selectedPaymentMethod.value == null) {
          Get.snackbar(
            'Error',
            'Please select a payment method',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
        return true;

      case 4: // Review
        return true;

      default:
        return true;
    }
  }

  // ============================================
  // Address Management
  // ============================================

  /// Load user addresses
  Future<void> _loadAddresses() async {
    try {
      isLoadingAddresses.value = true;
      final addressList = await _checkoutService.getUserAddresses();
      addresses.value = addressList;

      // Auto-select default address
      final defaultAddress = addressList.firstWhereOrNull(
        (addr) => addr.isDefault,
      );
      if (defaultAddress != null) {
        selectedShippingAddress.value = defaultAddress;
        if (useSameAddress.value) {
          selectedBillingAddress.value = defaultAddress;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load addresses: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  /// Add new address
  Future<void> addAddress(Address address) async {
    try {
      isProcessing.value = true;
      final newAddress = await _checkoutService.addAddress(address);
      addresses.add(newAddress);

      // Auto-select if first address
      if (addresses.length == 1) {
        selectedShippingAddress.value = newAddress;
        if (useSameAddress.value) {
          selectedBillingAddress.value = newAddress;
        }
      }

      Get.snackbar(
        'Success',
        'Address added successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Update address
  Future<void> updateAddress(String addressId, Address address) async {
    try {
      isProcessing.value = true;
      final updatedAddress = await _checkoutService.updateAddress(
        addressId,
        address,
      );

      final index = addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        addresses[index] = updatedAddress;
      }

      Get.snackbar(
        'Success',
        'Address updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      await _checkoutService.deleteAddress(addressId);
      addresses.removeWhere((addr) => addr.id == addressId);

      Get.snackbar(
        'Success',
        'Address deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete address: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Select shipping address
  void selectShippingAddress(Address address) {
    selectedShippingAddress.value = address;
    if (useSameAddress.value) {
      selectedBillingAddress.value = address;
    }
    _loadShippingMethods();
  }

  /// Select billing address
  void selectBillingAddress(Address address) {
    selectedBillingAddress.value = address;
  }

  /// Toggle use same address for billing
  void toggleUseSameAddress(bool value) {
    useSameAddress.value = value;
    if (value && selectedShippingAddress.value != null) {
      selectedBillingAddress.value = selectedShippingAddress.value;
    } else {
      selectedBillingAddress.value = null;
    }
  }

  // ============================================
  // Shipping Methods
  // ============================================

  /// Load shipping methods
  Future<void> _loadShippingMethods() async {
    if (selectedShippingAddress.value == null) return;

    try {
      isLoadingShipping.value = true;
      final methods = await _checkoutService.getShippingMethods(
        addressId: selectedShippingAddress.value!.id,
        cartTotal: _cartController.subtotal,
      );
      shippingMethods.value = methods;

      // Auto-select first method or free shipping
      if (methods.isNotEmpty) {
        final freeMethod = methods.firstWhereOrNull((m) => m.isFree);
        selectedShippingMethod.value = freeMethod ?? methods.first;
        await _updateCheckoutSummary();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load shipping methods: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingShipping.value = false;
    }
  }

  /// Select shipping method
  Future<void> selectShippingMethod(ShippingMethod method) async {
    selectedShippingMethod.value = method;
    await _updateCheckoutSummary();
  }

  // ============================================
  // Payment Methods
  // ============================================

  /// Load payment methods
  Future<void> _loadPaymentMethods() async {
    try {
      isLoadingPaymentMethods.value = true;
      final methods = await _checkoutService.getPaymentMethods();
      paymentMethods.value = methods;

      // Auto-select default payment method
      final defaultMethod = methods.firstWhereOrNull((m) => m.isDefault);
      if (defaultMethod != null) {
        selectedPaymentMethod.value = defaultMethod;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payment methods: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingPaymentMethods.value = false;
    }
  }

  /// Select payment method
  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  /// Add payment method
  Future<void> addPaymentMethod(PaymentMethod method) async {
    try {
      isProcessing.value = true;
      final newMethod = await _checkoutService.addPaymentMethod(method);
      paymentMethods.add(newMethod);

      // Auto-select if first method
      if (paymentMethods.length == 1) {
        selectedPaymentMethod.value = newMethod;
      }

      Get.snackbar(
        'Success',
        'Payment method added successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add payment method: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // ============================================
  // Promo Code
  // ============================================

  /// Apply promo code
  Future<void> applyPromoCode(String code) async {
    if (code.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a promo code',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isProcessing.value = true;
      final result = await _checkoutService.applyCheckoutPromoCode(code);

      promoCode.value = code;
      promoDiscount.value = result['discount_amount']?.toDouble() ?? 0.0;

      await _updateCheckoutSummary();

      Get.snackbar(
        'Success',
        'Promo code applied successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Invalid promo code',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Remove promo code
  Future<void> removePromoCode() async {
    promoCode.value = '';
    promoDiscount.value = 0.0;
    await _updateCheckoutSummary();
  }

  // ============================================
  // Checkout Summary
  // ============================================

  /// Update checkout summary
  Future<void> _updateCheckoutSummary() async {
    try {
      final summary = await _checkoutService.getCheckoutSummary(
        items: _cartController.cartItems,
        addressId: selectedShippingAddress.value?.id,
        shippingMethodId: selectedShippingMethod.value?.id,
        promoCode: promoCode.value.isNotEmpty ? promoCode.value : null,
      );

      checkoutSummary.value = summary;
    } catch (e) {
      print('Failed to update checkout summary: $e');
    }
  }

  // ============================================
  // Order Creation
  // ============================================

  /// Place order
  Future<Order?> placeOrder() async {
    // Final validation
    if (!await _validateCurrentStep()) {
      return null;
    }

    try {
      isProcessing.value = true;

      final order = await _checkoutService.createOrder(
        items: _cartController.cartItems,
        shippingAddress: selectedShippingAddress.value!,
        billingAddress: useSameAddress.value
            ? null
            : selectedBillingAddress.value,
        shippingMethodId: selectedShippingMethod.value!.id,
        paymentMethodId: selectedPaymentMethod.value?.id,
        promoCode: promoCode.value.isNotEmpty ? promoCode.value : null,
        notes: notes.value.isNotEmpty ? notes.value : null,
      );

      // Clear cart after successful order
      await _cartController.clearCart();

      Get.snackbar(
        'Success',
        'Order placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      return order;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to place order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Reset checkout
  void resetCheckout() {
    currentStep.value = 0;
    selectedShippingAddress.value = null;
    selectedBillingAddress.value = null;
    selectedShippingMethod.value = null;
    selectedPaymentMethod.value = null;
    useSameAddress.value = true;
    notes.value = '';
    promoCode.value = '';
    promoDiscount.value = 0.0;
    checkoutSummary.value = null;
  }

  // ============================================
  // Getters
  // ============================================

  /// Get total steps
  int get totalSteps => 5;

  /// Check if can proceed to next step
  bool get canProceed {
    return !isProcessing.value;
  }

  /// Get progress percentage
  double get progressPercentage {
    return (currentStep.value + 1) / totalSteps;
  }

  /// Get step names
  List<String> get stepNames => [
        'Cart',
        'Shipping Address',
        'Shipping Method',
        'Payment',
        'Review',
      ];

  /// Get current step name
  String get currentStepName => stepNames[currentStep.value];
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controller/payment_controller.dart';
import '../../controller/reservation_controller.dart';
class PaymentScreen extends StatelessWidget {
  final double amount;
  final String garageName;
  /// Required when opened from MakeReservationScreen (booking + pay flow).
  final int? garageId;
  /// Optional: used when paying for an already-existing reservation.
  final int? reservationId;

  PaymentScreen({
    super.key,
    required this.amount,
    required this.garageName,
    this.garageId,
    this.reservationId,
  });

  static const Color _bg      = Color(0xFFF5F7FB);
  static const Color _card    = Colors.white;
  static const Color _heading = Color(0xFF0B1F45);
  static const Color _muted   = Color(0xFF5C6B82);
  static const Color _border  = Color(0xFFE2E7F0);
  static const Color _teal    = Color(0xFF2EC4B6);
  static const Color _amber   = Color(0xFFFFC107);

  final PaymentController controller =
      Get.put(PaymentController(), tag: 'pay');

  /// Only present when coming from MakeReservationScreen.
  ReservationController? get _reservationController =>
      Get.isRegistered<ReservationController>()
          ? Get.find<ReservationController>()
          : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        foregroundColor: _heading,
        elevation: 0.5,
        title: Text('payment'.tr,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),
            const SizedBox(height: 14),
            _methodPicker(),
            const SizedBox(height: 14),
            Obx(() {
              if (controller.paymentMethod.value == 'cash') {
                return _cashInfo();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _demoCardBanner(),
                  const SizedBox(height: 14),
                  _cardPreview(),
                  const SizedBox(height: 16),
                  _form(),
                ],
              );
            }),
            const SizedBox(height: 22),
            _payButton(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _heading.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('order_summary'.tr,
              style: const TextStyle(
                  color: _muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            garageName,
            style: const TextStyle(
                color: _heading,
                fontSize: 18,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'amount_due'.tr}:',
                  style: const TextStyle(color: _muted)),
              Text(
                '${amount.toStringAsFixed(2)} JOD',
                style: const TextStyle(
                    color: _heading,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Method picker (Card / Cash)
  // -------------------------------------------------------------------------

  Widget _methodPicker() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _methodTab(
                  icon: Icons.credit_card_rounded,
                  label: 'pay_with_card'.tr,
                  selected: controller.paymentMethod.value == 'card',
                  onTap: () => controller.paymentMethod.value = 'card',
                ),
              ),
              Expanded(
                child: _methodTab(
                  icon: Icons.payments_outlined,
                  label: 'pay_with_cash'.tr,
                  selected: controller.paymentMethod.value == 'cash',
                  onTap: () => controller.paymentMethod.value = 'cash',
                ),
              ),
            ],
          )),
    );
  }

  Widget _methodTab({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _teal.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _teal.withOpacity(0.45) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? _teal : _muted, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? _heading : _muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Cash info
  // -------------------------------------------------------------------------

  Widget _cashInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _heading.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_outlined,
                color: _teal, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cash_on_arrival'.tr,
                  style: const TextStyle(
                      color: _heading,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'cash_on_arrival_subtitle'.tr,
                  style: const TextStyle(color: _muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Card flow
  // -------------------------------------------------------------------------

  Widget _demoCardBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _amber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFB77C00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'demo_card_banner'.tr,
              style: const TextStyle(color: Color(0xFFB77C00)),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.useDemoCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: _amber,
              foregroundColor: _heading,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('use_demo_card'.tr,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _cardPreview() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.cardNumberController,
        controller.cardHolderController,
        controller.cardExpiryController,
      ]),
      builder: (context, _) {
        final number = controller.cardNumberController.text;
        final formatted = number.isEmpty
            ? '•••• •••• •••• ••••'
            : (number.length < 19 ? '$number  ••••'.padRight(19, ' ') : number);
        final holder = controller.cardHolderController.text.isEmpty
            ? 'CARDHOLDER NAME'
            : controller.cardHolderController.text.toUpperCase();
        final expiry = controller.cardExpiryController.text.isEmpty
            ? 'MM/YY'
            : controller.cardExpiryController.text;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF0B1F45), Color(0xFF2C3E70)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _heading.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: _amber),
                  const SizedBox(width: 8),
                  const Text('VISA',
                      style: TextStyle(
                          color: _amber, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text('Smart Park'.tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                formatted,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CARD HOLDER',
                            style: TextStyle(
                                color: Color(0xFFB0BAD0), fontSize: 10)),
                        Text(holder,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('EXPIRES',
                          style: TextStyle(
                              color: Color(0xFFB0BAD0), fontSize: 10)),
                      Text(expiry,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _form() {
    return Column(
      children: [
        _input(
          controller: controller.cardNumberController,
          label: 'card_number'.tr,
          icon: Icons.credit_card_outlined,
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
            LengthLimitingTextInputFormatter(19),
          ],
        ),
        const SizedBox(height: 12),
        _input(
          controller: controller.cardHolderController,
          label: 'card_holder'.tr,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _input(
                controller: controller.cardExpiryController,
                label: 'card_expiry'.tr,
                icon: Icons.calendar_month_outlined,
                formatters: [LengthLimitingTextInputFormatter(5)],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _input(
                controller: controller.cardCvvController,
                label: 'card_cvv'.tr,
                icon: Icons.lock_outline,
                obscure: true,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      style: const TextStyle(color: _heading),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _muted),
        prefixIcon: Icon(icon, color: _muted),
        filled: true,
        fillColor: _card,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _teal),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Pay button
  // -------------------------------------------------------------------------

  Widget _payButton() {
    return Obx(() {
      final isCash      = controller.paymentMethod.value == 'cash';
      final isBooking   = garageId != null; // came from MakeReservationScreen
      final resCtrl     = _reservationController;
      final isBusy      = controller.isProcessing.value ||
                          (resCtrl?.isSubmitting.value ?? false);

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          icon: Icon(isCash ? Icons.payments_outlined : Icons.lock_rounded),
          onPressed: isBusy
              ? null
              : () async {
                  if (isBooking && resCtrl != null) {
                    // ── Booking flow: single atomic request to POST /reservations ──
                    final ok = await resCtrl.createReservation(
                      garageId     : garageId!,
                      paymentMethod: controller.paymentMethod.value,
                      cardNumber   : isCash ? null : controller.cardNumberController.text,
                      cardHolder   : isCash ? null : controller.cardHolderController.text,
                      cardExpiry   : isCash ? null : controller.cardExpiryController.text,
                      cardCvv      : isCash ? null : controller.cardCvvController.text,
                    );
                    if (ok) {
                      // Pop back past PaymentScreen and MakeReservationScreen.
                      Get.until((route) => route.isFirst);
                    }
                  } else {
                    // ── Standalone payment flow (pay for existing reservation) ──
                    final ok = await controller.pay(
                      amount       : amount,
                      reservationId: reservationId,
                    );
                    if (ok) Get.back(result: true);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _amber,
            foregroundColor: _heading,
            elevation      : 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          label: Text(
            isBusy
                ? 'processing'.tr
                : isCash
                    ? 'reserve_cash_payment'.tr
                    : '${'pay'.tr} ${amount.toStringAsFixed(2)} JOD',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    });
  }
}

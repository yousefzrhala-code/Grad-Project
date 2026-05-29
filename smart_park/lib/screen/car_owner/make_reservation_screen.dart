import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant_api.dart';
import '../../controller/reservation_controller.dart';
import 'payment_screen.dart';

class MakeReservationScreen extends StatefulWidget {
  final int garageId;
  final String garageName;
  final double pricePerHour;

  const MakeReservationScreen({
    super.key,
    required this.garageId,
    required this.garageName,
    this.pricePerHour = 0,
  });

  @override
  State<MakeReservationScreen> createState() => _MakeReservationScreenState();
}

class _MakeReservationScreenState extends State<MakeReservationScreen> {
  static const Color _accent = Color(0xFF2EC4B6);
  static const Color _navy  = Color(0xFF0B1F45);
  static const Color _muted = Color(0xFF5C6B82);
  static const Color _bg    = Color(0xFFF5F7FB);
  static const Color _border = Color(0xFFE2E7F0);

  late ReservationController _ctrl;
  int _spots = 1;
  double _estimatedCost = 0;
  int _availableSpots = 99; // updated after live fetch
  bool _spotsLoading = true;
  DateTime? _selectedDate; // tracks the selected calendar date

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ReservationController());
    _ctrl.numberOfSpotsController.text = '1';
    _ctrl.startTimeController.addListener(_recalculate);
    _ctrl.endTimeController.addListener(_recalculate);
    _fetchAvailableSpots();
  }

  Future<void> _fetchAvailableSpots() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await http.get(
        Uri.parse('$baseUrl/garages/${widget.garageId}/availability'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final spots =
            int.tryParse((data['available_spots'] ?? 99).toString()) ?? 99;
        if (mounted) {
          setState(() {
            _availableSpots = spots;
            _spotsLoading = false;
            // clamp current selection if it exceeds available
            if (_spots > _availableSpots) {
              _spots = _availableSpots < 1 ? 1 : _availableSpots;
              _ctrl.numberOfSpotsController.text = '$_spots';
            }
          });
        }
      } else {
        if (mounted) setState(() => _spotsLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _spotsLoading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.startTimeController.removeListener(_recalculate);
    _ctrl.endTimeController.removeListener(_recalculate);
    super.dispose();
  }

  void _recalculate() {
    final cost = _calcCost();
    if (cost != _estimatedCost) setState(() => _estimatedCost = cost);
  }

  double _calcCost() {
    try {
      final start = _ctrl.startTimeController.text.trim();
      final end   = _ctrl.endTimeController.text.trim();
      if (start.isEmpty || end.isEmpty || widget.pricePerHour <= 0) return 0;
      final s = _toMinutes(start);
      final e = _toMinutes(end);
      if (e <= s) return 0;
      return double.parse(
          ((e - s) / 60.0 * widget.pricePerHour * _spots).toStringAsFixed(2));
    } catch (_) {
      return 0;
    }
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  double _durationHours() {
    try {
      final start = _ctrl.startTimeController.text.trim();
      final end   = _ctrl.endTimeController.text.trim();
      if (start.isEmpty || end.isEmpty) return 0;
      final s = _toMinutes(start);
      final e = _toMinutes(end);
      return e <= s ? 0 : (e - s) / 60.0;
    } catch (_) {
      return 0;
    }
  }

  void _changeSpots(int delta) {
    final next = _spots + delta;
    if (next < 1) return;
    if (next > _availableSpots) return;
    setState(() {
      _spots = next;
      _ctrl.numberOfSpotsController.text = next.toString();
      _estimatedCost = _calcCost();
    });
  }

  // Steps are considered filled when their data is entered
  bool get _step1Done =>
      _ctrl.reservationDateController.text.trim().isNotEmpty;
  bool get _step2Done =>
      _ctrl.startTimeController.text.trim().isNotEmpty &&
      _ctrl.endTimeController.text.trim().isNotEmpty;
  bool get _step3Done => _spots >= 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'make_reservation'.tr,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Garage info card ──────────────────────────────────────
              _garageHeader(),
              const SizedBox(height: 20),

              // ── Step progress bar ─────────────────────────────────────
              _stepProgressBar(),
              const SizedBox(height: 24),

              // ── Step 1: Date ──────────────────────────────────────────
              _stepCard(
                step: 1,
                label: 'reservation_date'.tr,
                icon: Icons.calendar_today_outlined,
                done: _step1Done,
                child: _datePickerRow(),
              ),
              const SizedBox(height: 14),

              // ── Step 2: Time ──────────────────────────────────────────
              _stepCard(
                step: 2,
                label: 'start_time'.tr + ' & ' + 'end_time'.tr,
                icon: Icons.access_time_rounded,
                done: _step2Done,
                child: _timePickerRow(),
              ),
              const SizedBox(height: 14),

              // ── Step 3: Spots ─────────────────────────────────────────
              _stepCard(
                step: 3,
                label: 'number_of_spots'.tr,
                icon: Icons.local_parking_outlined,
                done: _step3Done,
                child: _spotsRow(),
              ),
              const SizedBox(height: 20),

              // ── Cost summary ──────────────────────────────────────────
              _costSummaryCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // GARAGE HEADER
  // ─────────────────────────────────────────────────────────────────────

  Widget _garageHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecor(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.local_parking_rounded,
                color: _accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.garageName,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (widget.pricePerHour > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined,
                          size: 14, color: _accent),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.pricePerHour.toStringAsFixed(2)} ${'jod'.tr} ${'per_hour'.tr}',
                        style: const TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.local_parking_outlined,
                        size: 14,
                        color: _spotsLoading
                            ? _muted
                            : (_availableSpots > 0
                                ? Colors.green
                                : Colors.redAccent)),
                    const SizedBox(width: 4),
                    _spotsLoading
                        ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 1.5, color: _muted),
                          )
                        : Text(
                            _availableSpots > 0
                                ? '$_availableSpots ${'available_spots'.tr}'
                                : 'not_available'.tr,
                            style: TextStyle(
                              color: _availableSpots > 0
                                  ? Colors.green.shade700
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // STEP PROGRESS BAR
  // ─────────────────────────────────────────────────────────────────────

  Widget _stepProgressBar() {
    return Row(
      children: [
        _progressStep(1, 'reservation_date'.tr, _step1Done),
        _progressConnector(_step1Done),
        _progressStep(2, 'time'.tr, _step2Done),
        _progressConnector(_step2Done),
        _progressStep(3, 'spots'.tr, _step3Done),
      ],
    );
  }

  Widget _progressStep(int step, String label, bool done) {
    final active = done;
    return Expanded(
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: active ? _accent : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? _accent : _border,
                width: 2,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: _accent.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: active
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : Text(
                      '$step',
                      style: TextStyle(
                        color: active ? Colors.white : _muted,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? _accent : _muted,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressConnector(bool done) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 2,
          decoration: BoxDecoration(
            color: done ? _accent : _border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // STEP CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────

  Widget _stepCard({
    required int step,
    required String label,
    required IconData icon,
    required bool done,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: done ? _accent.withOpacity(0.45) : _border,
          width: done ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: done
                ? _accent.withOpacity(0.07)
                : _navy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // Step badge
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: done ? _accent : _accent.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 15)
                        : Text(
                            '$step',
                            style: TextStyle(
                              color: done ? Colors.white : _accent,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: _accent, size: 17),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEEF2F8)),
          const SizedBox(height: 14),
          // ── Card content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // INLINE CALENDAR DATE PICKER
  // ─────────────────────────────────────────────────────────────────────

  Widget _datePickerRow() {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    return Column(
      children: [
        // Month calendar
        Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _navy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _accent),
            ),
          ),
          child: CalendarDatePicker(
            initialDate: initialDate,
            firstDate: now,
            lastDate: now.add(const Duration(days: 365)),
            onDateChanged: (picked) {
              final formatted =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
                  '${picked.day.toString().padLeft(2, '0')}';
              setState(() {
                _selectedDate = picked;
                _ctrl.reservationDateController.text = formatted;
              });
            },
          ),
        ),

        // Selected date chip
        if (_selectedDate != null) ...[
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: _accent, size: 16),
                const SizedBox(width: 8),
                Text(
                  _ctrl.reservationDateController.text,
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TIME PICKERS
  // ─────────────────────────────────────────────────────────────────────

  Widget _timePickerRow() {
    return Row(
      children: [
        Expanded(child: _timePicker('start_time'.tr,
            _ctrl.startTimeController, Icons.play_circle_outline)),
        const SizedBox(width: 10),
        // Arrow connector
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_rounded,
              color: _accent, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(child: _timePicker('end_time'.tr,
            _ctrl.endTimeController, Icons.stop_circle_outlined)),
      ],
    );
  }

  Widget _timePicker(String label, TextEditingController tc, IconData icon) {
    final hasTime = tc.text.trim().isNotEmpty;
    return GestureDetector(
      onTap: () async {
        await _ctrl.pickTime(context, tc);
        setState(() => _estimatedCost = _calcCost());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: hasTime
              ? _accent.withOpacity(0.06)
              : const Color(0xFFF5F7FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasTime ? _accent.withOpacity(0.4) : _border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasTime ? _accent : _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(icon,
                    color: hasTime ? _accent : _muted, size: 18),
                const SizedBox(width: 6),
                Text(
                  hasTime ? tc.text.trim() : '--:--',
                  style: TextStyle(
                    color: hasTime ? _navy : _muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // SPOTS COUNTER
  // ─────────────────────────────────────────────────────────────────────

  Widget _spotsRow() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.directions_car_outlined,
              color: _accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'number_of_spots'.tr,
            style: const TextStyle(
                color: _navy, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        _counterBtn(Icons.remove_rounded, () => _changeSpots(-1),
            enabled: _spots > 1),
        const SizedBox(width: 16),
        SizedBox(
          width: 38,
          child: Text(
            '$_spots',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _counterBtn(Icons.add_rounded, () => _changeSpots(1),
            enabled: _spots < _availableSpots),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap,
      {required bool enabled}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? _accent : const Color(0xFFE2E7F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            size: 20,
            color: enabled ? Colors.white : _muted),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // COST SUMMARY
  // ─────────────────────────────────────────────────────────────────────

  Widget _costSummaryCard() {
    final hasTime = _ctrl.startTimeController.text.isNotEmpty &&
        _ctrl.endTimeController.text.isNotEmpty;
    final durH = _durationHours();
    final hasCost = _estimatedCost > 0 && widget.pricePerHour > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accent.withOpacity(0.10),
            _accent.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.28)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_outlined,
                    color: _accent, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'estimated_total'.tr,
                style: const TextStyle(
                  color: _navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          if (hasTime && durH > 0) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFD0E8E6), height: 1),
            const SizedBox(height: 12),
            _summaryLine(
              'duration'.tr,
              '${durH % 1 == 0 ? durH.toInt() : durH.toStringAsFixed(1)} ${'hours'.tr}',
            ),
            const SizedBox(height: 6),
            _summaryLine('spots'.tr, '$_spots'),
            if (widget.pricePerHour > 0) ...[
              const SizedBox(height: 6),
              _summaryLine(
                'price_per_hour'.tr,
                '${widget.pricePerHour.toStringAsFixed(2)} ${'jod'.tr}',
              ),
            ],
          ],

          const SizedBox(height: 14),
          const Divider(color: Color(0xFFD0E8E6), height: 1),
          const SizedBox(height: 12),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'total_cost'.tr,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  hasCost
                      ? '${_estimatedCost.toStringAsFixed(2)} ${'jod'.tr}'
                      : (widget.pricePerHour <= 0 ? 'free'.tr : '—'),
                  key: ValueKey(_estimatedCost),
                  style: TextStyle(
                    color: hasCost ? _accent : _muted,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: _muted, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: _navy, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BOTTOM BAR
  // ─────────────────────────────────────────────────────────────────────

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final submitting = _ctrl.isSubmitting.value;
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: submitting
                ? null
                : () {
                    if (_ctrl.reservationDateController.text.trim().isEmpty) {
                      Get.snackbar('error'.tr, 'please_select_date'.tr,
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    if (_ctrl.startTimeController.text.trim().isEmpty) {
                      Get.snackbar('error'.tr, 'please_select_start_time'.tr,
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    if (_ctrl.endTimeController.text.trim().isEmpty) {
                      Get.snackbar('error'.tr, 'please_select_end_time'.tr,
                          snackPosition: SnackPosition.BOTTOM);
                      return;
                    }
                    Get.to(() => PaymentScreen(
                          amount: _estimatedCost,
                          garageName: widget.garageName,
                          garageId: widget.garageId,
                        ));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              disabledBackgroundColor: const Color(0xFFE2E7F0),
              disabledForegroundColor: _muted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.pricePerHour > 0
                            ? 'proceed_to_payment'.tr
                            : 'confirm_reservation'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecor() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

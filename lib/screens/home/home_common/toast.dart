import 'package:flutter/material.dart';

OverlayEntry? _currentToast; // Keeps track of the current toast
DateTime? _lastToastTime; // Keeps track of the last time a toast was shown

void showCustomToast(BuildContext context, String message) {
  // Remove any existing toast if it's already displayed for more than 2 seconds
  if (_currentToast != null) {
    _currentToast!.remove();
    _currentToast = null;
  }

  // Create a new toast
  final overlay = Overlay.of(context);
  _currentToast = OverlayEntry(
    builder: (context) => Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 50, // Position 50 pixels from the bottom
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(12), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Subtle shadow
                    blurRadius: 6, // Blur radius
                    offset: const Offset(0, 3), // Shadow offset
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black, // Black text
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(_currentToast!);

  // Update the last toast time
  _lastToastTime = DateTime.now();

  // Automatically remove the toast after 1 seconds
  Future.delayed(const Duration(seconds: 1), () {
    if (_currentToast != null &&
        DateTime.now()
            .isAfter(_lastToastTime!.add(const Duration(seconds: 1)))) {
      _currentToast!.remove();
      _currentToast = null;
    }
  });
}

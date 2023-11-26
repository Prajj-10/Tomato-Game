import 'package:flutter/material.dart';

/// Custom button widget with a material design.
///
/// This widget represents a customizable button with elevation, border radius,
/// color, and an `onTap` callback. It is commonly used for triggering actions
/// in a Flutter application.
class CustomButton extends StatelessWidget {
  /// Creates a [CustomButton].
  ///
  /// The [key], [onTap], and [text] parameters must not be null.
  const CustomButton({
    Key? key,
    required this.onTap,
    required this.text,
  }) : super(key: key);

  /// The text to display inside the button.
  final String text;

  /// Callback function to be executed when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    /// Builds the structure of the custom button.
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(36.0),
      color: Color(0xF29F9F).withOpacity(1.0),
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width / 2,
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Electronic Highway Sign',
          ),
        ),
      ),
    );
  }
}

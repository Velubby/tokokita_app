import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RowRenderContainer extends StatelessWidget {
  final String assetsSvg;
  final String title;
  final String msg;
  final Function()? onTap;

  const RowRenderContainer({
    super.key,
    required this.assetsSvg,
    required this.title,
    required this.msg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show toast message
        Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );

        // Adding a delay to ensure toast doesn't appear for too long
        Future.delayed(Duration(seconds: 1), () {
          Fluttertoast.cancel(); // Cancel the toast after the delay
        });

        // Call the onTap function if provided
        if (onTap != null) {
          onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Container(
          color: Colors.transparent,
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/$assetsSvg', width: 30),
              const SizedBox(width: 10),
              Text(title),
              const Spacer(),
              const Icon(Icons.keyboard_arrow_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

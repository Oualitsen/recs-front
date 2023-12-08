import 'package:flutter/material.dart';

class SideMenuButton extends StatelessWidget {
  final IconData iconData;
  final bool isActive;
  final Function()? onTap;

  const SideMenuButton({super.key, required this.iconData, required this.isActive, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        iconSize: 28,
        onPressed: isActive ? null : onTap,
        icon: Icon(
          iconData,
          color: isActive ? Colors.white : Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}

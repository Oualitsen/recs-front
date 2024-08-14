import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SideMenuButton extends StatelessWidget {
  final String title;
  final IconData iconData;
  final IconData? activeIcon;
  final bool isActive;
  final Function()? onTap;
  final bool showTooltip;

  const SideMenuButton({
    super.key,
    required this.iconData,
    required this.isActive,
    required this.title,
    this.onTap,
    this.activeIcon,
    required this.showTooltip,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: TextButton(
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  border: Border.all(color: Colors.grey.shade100, width: 1.0),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(isActive ? activeIcon ?? iconData : iconData,
                    size: isActive ? 22 : 18,
                    color: isActive ? blueShade : greyShade),
                Gap(20),
                SizedBox(
                  width: 150,
                  child: Tooltip(
                    message: showTooltip ? title : "",
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isActive ? blueShade : greyShade,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: isActive ? 18 : 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onPressed: isActive ? null : onTap,
      ),
    );
  }

  Color get blueShade => Color.fromARGB(255, 0, 74, 143);
  Color get greyShade => Color.fromARGB(255, 33, 34, 34);
}

class SideMenuButton2 extends StatelessWidget {
  final IconData iconData;
  final bool isActive;
  final Function()? onTap;

  const SideMenuButton2(
      {super.key, required this.iconData, required this.isActive, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        borderRadius: BorderRadius.circular(8),
        color: isActive ? Theme.of(context).primaryColor : Colors.white,
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

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidget = isOutlined
        ? OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: icon != null
                ? Icon(icon, size: 20, color: color ?? AppColors.primary)
                : const SizedBox.shrink(),
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: color ?? AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.lg,
              ),
              side: BorderSide(
                color: color ?? AppColors.primary,
                width: 2,
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: icon != null
                ? Icon(icon, size: 20, color: Colors.white)
                : const SizedBox.shrink(),
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(width ?? double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.lg,
              ),
              elevation: 0,
            ),
          );

    return SizedBox(width: width, child: buttonWidget);
  }
}

class IconButtonWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const IconButtonWithLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 32),
          color: color ?? Theme.of(context).primaryColor,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

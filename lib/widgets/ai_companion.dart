import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AiCompanion extends StatelessWidget {
  const AiCompanion({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 1,
            child: Container(
              width: 5,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.cyanDeep,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            top: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.22,
            child: Container(
              width: size * 0.82,
              height: size * 0.66,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.cyan, AppColors.mint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size * 0.25),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.cyanDeep.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _eye(size * 0.09),
                      SizedBox(width: size * 0.17),
                      _eye(size * 0.09),
                    ],
                  ),
                  SizedBox(height: size * 0.08),
                  Container(
                    width: size * 0.2,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.ink.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.02,
            child: Container(
              width: size * 0.44,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: AppColors.cyanDeep,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
    );
  }
}

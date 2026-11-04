import 'package:flutter/material.dart';

class MajorOption {
  const MajorOption({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
  });

  final String id;
  final String name;
  final String shortName;
  final IconData icon;
}

const List<MajorOption> majorOptions = <MajorOption>[
  MajorOption(
    id: 'electrical',
    name: '전기·전자',
    shortName: '전기전자',
    icon: Icons.bolt_rounded,
  ),
  MajorOption(
    id: 'information',
    name: '정보·통신',
    shortName: '정보통신',
    icon: Icons.wifi_rounded,
  ),
  MajorOption(
    id: 'mechanical',
    name: '기계',
    shortName: '기계',
    icon: Icons.precision_manufacturing_rounded,
  ),
  MajorOption(
    id: 'cooking',
    name: '조리',
    shortName: '조리',
    icon: Icons.restaurant_rounded,
  ),
  MajorOption(
    id: 'beauty',
    name: '미용',
    shortName: '미용',
    icon: Icons.content_cut_rounded,
  ),
];

MajorOption majorById(String id) {
  return majorOptions.firstWhere(
    (major) => major.id == id,
    orElse: () => majorOptions.first,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test1/models/player_profile.dart';
import 'package:test1/screens/setup_screen.dart';

void main() {
  group('SetupScreen', () {
    testWidgets('사용자 이름과 전공을 선택하면 프로필을 생성한다', (tester) async {
      PlayerProfile? createdProfile;

      await tester.pumpWidget(
        MaterialApp(
          home: SetupScreen(
            onCompleted: (profile) async {
              createdProfile = profile;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '주원');
      await tester.tap(find.text('전기·전자'));
      await tester.pump();

      await tester.ensureVisible(find.text('시작하기'));
      await tester.tap(find.text('시작하기'));
      await tester.pumpAndSettle();

      expect(createdProfile, isNotNull);
      expect(createdProfile!.name, '주원');
      expect(createdProfile!.majorId, 'electrical');
    });
  });

  group('PlayerProfile', () {
    test('경험치에 따라 레벨과 능력치를 계산한다', () {
      const profile = PlayerProfile(
        name: '주원',
        majorId: 'electrical',
        experience: 150,
      );

      expect(profile.level, 2);
      expect(profile.maxHp, 110);
      expect(profile.attack, 22);
      expect(profile.experienceInCurrentLevel, 50);
    });
  });
}

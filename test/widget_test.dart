import 'package:flutter_test/flutter_test.dart';
import 'package:landlord_management_app/main.dart';
import 'package:landlord_management_app/repositories/in_memory_unit_lease_repository.dart';

void main() {
  testWidgets('Home screen renders core sections', (WidgetTester tester) async {
    await tester.pumpWidget(
      App(repository: InMemoryUnitLeaseRepository.withSampleData()),
    );

    expect(find.text('임대 관리 홈'), findsOneWidget);
    expect(find.text('이번 달 만료'), findsOneWidget);
    expect(find.text('만료 임박 TOP 3'), findsOneWidget);
    expect(find.text('호실 전체 보기'), findsOneWidget);
  });
}

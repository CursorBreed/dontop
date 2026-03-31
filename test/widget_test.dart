import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dont_tap_rogue_op/game/protocol_game.dart';

void main() {
  testWidgets('Game widget renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      GameWidget(game: ProtocolGame()),
    );
    await tester.pump();
    expect(find.byType(GameWidget<ProtocolGame>), findsOneWidget);
  });
}

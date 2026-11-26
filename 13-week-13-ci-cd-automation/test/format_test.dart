import 'package:campus_notify/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeFromMessage adds the leading slash and defaults to /', () {
    expect(routeFromMessage({}), '/');
    expect(routeFromMessage({'route': 'announcement/3'}), '/announcement/3');
    expect(routeFromMessage({'route': '/announcement/3'}), '/announcement/3');
  });

  test('truncateToken never exposes more than 12 characters', () {
    expect(truncateToken(null), '(no token)');
    expect(truncateToken('short'), 'short');
    expect(truncateToken('abcdefghijklmnopqrstuvwxyz'), 'abcdefghijkl...');
  });

  test('formatClock pads hours, minutes and seconds', () {
    expect(formatClock(DateTime(2026, 10, 15, 7, 5, 9)), '07:05:09');
  });
}

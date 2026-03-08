import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_app/core/config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppConfig resolves base URL successfully', (WidgetTester tester) async {
    final config = AppConfig();
    final url = await config.resolveBackendBaseUrl();
    
    expect(url, isNotNull);
    expect(url.startsWith('http'), isTrue);
  });
}

import 'package:mobile_app/pages/course_page_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test error messages from generateErrorMessage', () {
    test('Empty user response', () {
      expect(ErrorUtils.generateErrorMessage('', 'Something'), 'Le champ de saisie est vide. Veuillez entrer une réponse.');
    });

    test('Missing capital', () {
      expect(
        ErrorUtils.generateErrorMessage('hello world.', 'Hello World.'),
        'Vérifiez la majuscule: il pourrait y avoir des majuscules en trop ou manquants.',
      );
    });

    test('Extra capital', () {
      expect(
        ErrorUtils.generateErrorMessage('Hello World.', 'hello World.'),
        'Vérifiez la majuscule: il pourrait y avoir des majuscules en trop ou manquants.',
      );
    });

    test('Too much space', () {
      expect(
        ErrorUtils.generateErrorMessage('Hello   World.', 'Hello World.'),
        'Vérifiez les espaces : il pourrait y avoir des espaces en trop ou manquants.',
      );
    });

    test('Missing space', () {
      expect(
        ErrorUtils.generateErrorMessage('HelloWorld.', 'Hello World.'),
        'Vérifiez les espaces : il pourrait y avoir des espaces en trop ou manquants.',
      );
    });

    test('Missing period', () {
      expect(
        ErrorUtils.generateErrorMessage('Hello World', 'Hello World.'),
        'Votre réponse manque un point à la fin.',
      );
    });

    test('Other case not registered', () {
      expect(
        ErrorUtils.generateErrorMessage('Hallo wayayay.', 'Hello World.'),
        'Votre réponse est incorrecte. Veuillez revoir l’instruction.',
      );
    });
  });
}
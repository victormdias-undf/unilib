import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  group('Validações', () {
    test('CPF remove pontuação, valida dígitos e rejeita repetição', () {
      expect(Validacoes.somenteNumeros('529.982.247-25'), '52998224725');
      expect(Validacoes.cpfValido('529.982.247-25'), isTrue);
      expect(Validacoes.cpfValido('11111111111'), isFalse);
      expect(Validacoes.cpfValido('123'), isFalse);
    });
    test('e-mail e senha', () {
      expect(Validacoes.emailValido('aluno@exemplo.com'), isTrue);
      expect(Validacoes.emailValido('invalido'), isFalse);
      expect(Validacoes.senhaValida('SenhaTeste123'), isTrue);
      expect(Validacoes.senhaValida('1234'), isFalse);
    });
    test('campo obrigatório de item', () {
      expect(Validacoes.nome(' Atlas '), 'Atlas');
      expect(() => Validacoes.nome(' '), throwsA(isA<ErroApi>()));
    });
  });
}

import 'modelos.dart';

class Validacoes {
  static String somenteNumeros(String entrada) => entrada.replaceAll(RegExp(r'\D'), '');

  static bool cpfValido(String entrada) {
    final cpf = somenteNumeros(entrada);
    if (cpf.length != 11 || cpf.split('').every((c) => c == cpf[0])) {
      return false;
    }
    int digito(int quantidade) {
      var soma = 0;
      for (var i = 0; i < quantidade; i++) {
        soma += int.parse(cpf[i]) * (quantidade + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }
    return digito(9) == int.parse(cpf[9]) && digito(10) == int.parse(cpf[10]);
  }

  static bool emailValido(String entrada) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(entrada.trim());

  // Regra oficial da API. O frontend deve reproduzi-la.
  static bool senhaValida(String senha) => senha.length >= 8 && senha.length <= 128;

  static String nome(String? valor, {int maximo = 120}) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty || texto.length > maximo) {
      throw ErroApi(400, 'O nome deve ter de 1 a $maximo caracteres.', 'nome_invalido');
    }
    return texto;
  }

  static String descricao(String? valor, {int maximo = 1000}) {
    final texto = (valor ?? '').trim();
    if (texto.length > maximo) {
      throw ErroApi(400, 'A descrição deve ter até $maximo caracteres.');
    }
    return texto;
  }

  /// Descrição visível no anúncio e obrigatória para itens de alunos.
  static String descricaoAnuncio(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty || texto.length > 1000) {
      throw const ErroApi(400,
        'A descrição do anúncio é obrigatória e deve ter até 1000 caracteres.',
        'descricao_invalida');
    }
    return texto;
  }

  /// Informado voluntariamente e exibido publicamente junto ao anúncio.
  static String contato(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty || texto.length > 150) {
      throw const ErroApi(400,
        'O contato do anúncio é obrigatório e deve ter até 150 caracteres.',
        'contato_invalido');
    }
    return texto;
  }
}

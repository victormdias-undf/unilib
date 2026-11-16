
import 'dart:math';

import 'package:cryptography/cryptography.dart';

// Dados que a tela pode receber após o login.
class Usuario {
  final String cpf;
  final String email;

  const Usuario({
    required this.cpf,
    required this.email,
  });
}

// Possíveis resultados do cadastro.
enum ResultadoCadastro {
  sucesso,
  cpfInvalido,
  senhaCurta,
  emailInvalido,
  cpfJaCadastrado,
}

// Registro interno do usuário.
// Não guarda a senha original.
class _Registro {
  final Usuario usuario;
  final List<int> salt;
  final List<int> hashSenha;

  const _Registro(
    this.usuario,
    this.salt,
    this.hashSenha,
  );
}

// Serviço responsável pelo cadastro e login.
class ServicoAutenticacao {
  // SENHA MÍNIMA: 4 CARACTERES
  static const int minimoSenha = 4;

  // Armazena as contas temporariamente.
  final Map<String, _Registro> _contas = {};

  // Algoritmo para derivar o hash das senhas.
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  // Remove pontos e traços do CPF.
  static String somenteNumeros(String texto) {
    return texto.replaceAll(RegExp(r'\D'), '');
  }

  // VERIFICA SE O CPF É VÁLIDO
  static bool cpfValido(String texto) {
    final cpf = somenteNumeros(texto);

    if (cpf.length != 11) {
      return false;
    }

    // Rejeita CPFs com todos os números iguais.
    if (cpf.split('').every(
      (digito) => digito == cpf[0],
    )) {
      return false;
    }

    // Calcula os dígitos verificadores.
    int digito(int quantidade) {
      var soma = 0;

      for (var i = 0; i < quantidade; i++) {
        soma += int.parse(cpf[i]) *
            (quantidade + 1 - i);
      }

      final resultado = (soma * 10) % 11;

      return resultado == 10 ? 0 : resultado;
    }

    return digito(9) == int.parse(cpf[9]) &&
        digito(10) == int.parse(cpf[10]);
  }

  // VERIFICA O FORMATO DO E-MAIL
  static bool emailValido(String texto) {
    final email = texto.trim();

    return RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email);
  }

  // CADASTRA UM NOVO USUÁRIO
  Future<ResultadoCadastro> cadastrar({
    required String cpf,
    required String email,
    required String senha,
  }) async {
    final numero = somenteNumeros(cpf);

    // Verifica o CPF.
    if (!cpfValido(numero)) {
      return ResultadoCadastro.cpfInvalido;
    }

    // E-mail obrigatório.
    if (!emailValido(email)) {
      return ResultadoCadastro.emailInvalido;
    }

    // Senha com pelo menos 4 caracteres.
    if (senha.length < minimoSenha) {
      return ResultadoCadastro.senhaCurta;
    }

    // Impede que o CPF seja cadastrado novamente.
    if (_contas.containsKey(numero)) {
      return ResultadoCadastro.cpfJaCadastrado;
    }

    // Gera um salt aleatório.
    final gerador = Random.secure();

    final salt = List<int>.generate(
      16,
      (_) => gerador.nextInt(256),
    );

    // Gera o hash da senha.
    final chave = await _pbkdf2.deriveKeyFromPassword(
      password: senha,
      nonce: salt,
    );

    final hash = await chave.extractBytes();

    // Salva o novo usuário em memória.
    _contas[numero] = _Registro(
      Usuario(
        cpf: numero,
        email: email.trim(),
      ),
      salt,
      hash,
    );

    return ResultadoCadastro.sucesso;
  }

  // REALIZA O LOGIN
  Future<Usuario?> entrar({
    required String cpf,
    required String senha,
  }) async {
    // Procura o CPF cadastrado.
    final conta = _contas[somenteNumeros(cpf)];

    if (conta == null) {
      return null;
    }

    // Calcula o hash da senha digitada.
    final chave = await _pbkdf2.deriveKeyFromPassword(
      password: senha,
      nonce: conta.salt,
    );

    final hashDigitado = await chave.extractBytes();

    if (hashDigitado.length != conta.hashSenha.length) {
      return null;
    }

    // Compara os hashes.
    var diferenca = 0;

    for (var i = 0; i < hashDigitado.length; i++) {
      diferenca |=
          hashDigitado[i] ^ conta.hashSenha[i];
    }

    // Retorna o usuário se a senha estiver correta.
    if (diferenca == 0) {
      return conta.usuario;
    }

    return null;
  }
}

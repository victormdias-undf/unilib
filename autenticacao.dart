import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../contratos.dart';
import '../identificadores.dart';
import '../modelos.dart';
import '../validacoes.dart';

class ResultadoLogin {
  final Usuario usuario;
  final String token;
  final DateTime expiraEm;

  const ResultadoLogin({required this.usuario, required this.token, required this.expiraEm});

  Map<String, Object?> toJson() => {
        'usuario': usuario.toJson(),
        'token': token,
        'tipoToken': 'Bearer',
        'expiraEm': expiraEm.toUtc().toIso8601String(),
      };
}

class ServicoAutenticacao {
  final RepositorioUsuarios usuarios;
  final RepositorioSessoes sessoes;
  final Pbkdf2 _derivador = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  ServicoAutenticacao({required this.usuarios, required this.sessoes});

  Future<Usuario> cadastrar({
    required String cpf,
    required String email,
    required String senha,
    String? nome,
  }) =>
      _cadastrar(
        cpf: cpf,
        email: email,
        senha: senha,
        nome: nome,
        papel: PapeisUsuario.aluno,
      );

  /// Exclusivo do bootstrap local do servidor. Nunca expor esta função em rota HTTP.
  Future<Usuario> cadastrarAdminInicial({
    required String cpf,
    required String email,
    required String senha,
    String? nome,
  }) =>
      _cadastrar(
        cpf: cpf,
        email: email,
        senha: senha,
        nome: nome,
        papel: PapeisUsuario.admin,
      );

  Future<Usuario> _cadastrar({
    required String cpf,
    required String email,
    required String senha,
    required String papel,
    String? nome,
  }) async {
    final cpfNormalizado = Validacoes.somenteNumeros(cpf);
    final emailNormalizado = email.trim().toLowerCase();
    if (!Validacoes.cpfValido(cpfNormalizado)) {
      throw const ErroApi(400, 'CPF inválido.', 'cpf_invalido');
    }
    if (!Validacoes.emailValido(emailNormalizado)) {
      throw const ErroApi(400, 'E-mail inválido.', 'email_invalido');
    }
    if (!Validacoes.senhaValida(senha)) {
      throw const ErroApi(400, 'A senha deve ter entre 8 e 128 caracteres.', 'senha_invalida');
    }
    if (nome != null && nome.trim().length > 120) {
      throw const ErroApi(400, 'O nome deve ter até 120 caracteres.');
    }
    final aleatorio = Random.secure();
    final salt = List<int>.generate(16, (_) => aleatorio.nextInt(256));
    final chave = await _derivador.deriveKeyFromPassword(password: senha, nonce: salt);
    final hash = await chave.extractBytes();
    final usuario = Usuario(
      id: gerarIdentificador(),
      cpf: cpfNormalizado,
      email: emailNormalizado,
      nome: nome?.trim(),
      papel: papel,
    );
    final inserido = await usuarios.inserirSeNovo(
      RegistroUsuario(usuario: usuario, salt: salt, hashSenha: hash),
    );
    if (!inserido) {
      throw const ErroApi(409, 'CPF ou e-mail já cadastrado.', 'usuario_duplicado');
    }
    return usuario;
  }

  Future<ResultadoLogin> entrar({required String cpf, required String senha}) async {
    final normalizado = Validacoes.somenteNumeros(cpf);
    final registro = await usuarios.buscarPorCpf(normalizado);
    if (registro == null) {
      throw const ErroApi(401, 'CPF ou senha incorretos.', 'credenciais_invalidas');
    }
    final chave = await _derivador.deriveKeyFromPassword(
      password: senha,
      nonce: registro.salt,
    );
    final calculado = await chave.extractBytes();
    if (!_iguaisEmTempoConstante(calculado, registro.hashSenha)) {
      throw const ErroApi(401, 'CPF ou senha incorretos.', 'credenciais_invalidas');
    }
    final token = gerarIdentificador(comprimento: 64);
    final expiraEm = DateTime.now().toUtc().add(const Duration(hours: 2));
    await sessoes.salvar(token, Sessao(usuarioId: registro.usuario.id, expiraEm: expiraEm));
    return ResultadoLogin(usuario: registro.usuario, token: token, expiraEm: expiraEm);
  }

  Future<Usuario> usuarioPeloToken(String? token) async {
    if (token == null || token.isEmpty) {
      throw const ErroApi(401, 'Autenticação necessária.', 'token_ausente');
    }
    final sessao = await sessoes.buscar(token);
    if (sessao == null || !DateTime.now().toUtc().isBefore(sessao.expiraEm)) {
      await sessoes.remover(token);
      throw const ErroApi(401, 'Token inválido ou expirado.', 'token_invalido');
    }
    final usuario = await usuarios.buscarPorId(sessao.usuarioId);
    if (usuario == null) {
      throw const ErroApi(401, 'Usuário não encontrado.', 'usuario_inexistente');
    }
    return usuario.usuario;
  }

  Future<void> sair(String token) async {
    await usuarioPeloToken(token);
    await sessoes.remover(token);
  }

  static bool _iguaisEmTempoConstante(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diferenca = 0;
    for (var i = 0; i < a.length; i++) {
      diferenca |= a[i] ^ b[i];
    }
    return diferenca == 0;
  }
}

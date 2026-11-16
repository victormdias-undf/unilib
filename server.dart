import 'dart:async';
import 'dart:io';

import 'package:unilib_backend/unilib_backend.dart';

Future<void> main() async {
  // Trocar estes 5 repositórios pelas implementações da equipe de banco, quando prontas.
  final usuarios = UsuariosEmMemoria();
  final sessoes = SessoesEmMemoria();
  final itens = ItensEmMemoria.comExemplos();
  final favoritosRepo = FavoritosLivrosEmMemoria();
  final emprestimosRepo = EmprestimosEmMemoria();

  final auth = ServicoAutenticacao(usuarios: usuarios, sessoes: sessoes);
  final biblioteca = ServicoBiblioteca(itens, repositorioEmprestimos: emprestimosRepo);
  final emprestimos = ServicoEmprestimos(
    emprestimos: emprestimosRepo,
    biblioteca: biblioteca,
  );
  final acervo = ServicoAcervoAlunos(itens);
  final favoritos = ServicoFavoritosLivros(repositorio: favoritosRepo, biblioteca: biblioteca);

  // Admin SOMENTE por configuração do ambiente local, nunca pelo cadastro da API.
  final cpfAdmin = Platform.environment['ADMIN_CPF'];
  final emailAdmin = Platform.environment['ADMIN_EMAIL'];
  final senhaAdmin = Platform.environment['ADMIN_PASSWORD'];
  final configurouAdmin = [cpfAdmin, emailAdmin, senhaAdmin].any((x) => x != null);
  if (configurouAdmin) {
    if ([cpfAdmin, emailAdmin, senhaAdmin].any((x) => x == null || x.isEmpty)) {
      stderr.writeln('Configure ADMIN_CPF, ADMIN_EMAIL e ADMIN_PASSWORD juntos.');
      exitCode = 64;
      return;
    }
    await auth.cadastrarAdminInicial(
      cpf: cpfAdmin!, email: emailAdmin!, senha: senhaAdmin!, nome: 'Admin de desenvolvimento',
    );
    stdout.writeln('Administrador local de desenvolvimento configurado.');
  } else {
    stdout.writeln('Sem administrador: as rotas de escrita na Biblioteca Geral ficam bloqueadas.');
  }

  final porta = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final host = Platform.environment['HOST'] ?? '127.0.0.1';
  final origens = (Platform.environment['CORS_ORIGINS'] ?? '')
      .split(',')
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty)
      .toSet();
  final api = ApiUniLib(
    autenticacao: auth,
    biblioteca: biblioteca,
    acervo: acervo,
    favoritos: favoritos,
    emprestimos: emprestimos,
    origensAdicionais: origens,
  );
  final servidor = await HttpServer.bind(host, porta);
  stdout.writeln('UniLib backend: http://$host:${servidor.port}');
  stdout.writeln('Health: http://$host:${servidor.port}/api/health');
  stdout.writeln('Encerrar: Ctrl + C');

  await for (final req in servidor) {
    unawaited(api.atender(req));
  }
}

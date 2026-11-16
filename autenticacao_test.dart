import 'package:test/test.dart';
import 'package:unilib_backend/unilib_backend.dart';

void main() {
  late ServicoAutenticacao auth;

  setUp(() {
    auth = ServicoAutenticacao(
      usuarios: UsuariosEmMemoria(),
      sessoes: SessoesEmMemoria(),
    );
  });

  test('cadastro e login, consulta de token, logout', () async {
    final usuario = await auth.cadastrar(
      cpf: '529.982.247-25',
      email: 'Aluno@Exemplo.com',
      senha: 'SenhaTeste123',
      nome: 'Aluno Teste',
    );
    expect(usuario.cpf, '52998224725');
    expect(usuario.email, 'aluno@exemplo.com');
    expect(usuario.papel, 'aluno');
    final login = await auth.entrar(cpf: usuario.cpf, senha: 'SenhaTeste123');
    expect((await auth.usuarioPeloToken(login.token)).id, usuario.id);
    await auth.sair(login.token);
    await expectLater(auth.usuarioPeloToken(login.token), throwsA(isA<ErroApi>()));
  });

  test('e-mail duplicado e CPF duplicado retornam 409', () async {
    await auth.cadastrar(
      cpf: '52998224725', email: 'aluno@exemplo.com', senha: 'SenhaTeste123');
    await expectLater(
      auth.cadastrar(cpf: '52998224725', email: 'outro@exemplo.com', senha: 'SenhaTeste123'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
    await expectLater(
      auth.cadastrar(cpf: '11144477735', email: 'aluno@exemplo.com', senha: 'SenhaTeste123'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 409)),
    );
  });

  test('não entra com senha incorreta; cadastro nunca concede papel admin', () async {
    await auth.cadastrar(cpf: '52998224725', email: 'aluno@exemplo.com', senha: 'SenhaTeste123');
    await expectLater(
      auth.entrar(cpf: '52998224725', senha: 'SenhaErrada123'),
      throwsA(isA<ErroApi>().having((e) => e.status, 'status', 401)),
    );
  });

  test('admin inicial só por método interno de bootstrap', () async {
    final admin = await auth.cadastrarAdminInicial(
      cpf: '52998224725', email: 'admin@exemplo.com', senha: 'SenhaAdmin123');
    expect(admin.ehAdmin, isTrue);
  });
}

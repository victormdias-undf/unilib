
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'biblioteca_geral.dart';

import 'servico_autenticacao.dart';

void main() => runApp(const UniLibApp());

class UniLibApp extends StatelessWidget {
  const UniLibApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniLib',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 146, 97, 236),
        ),
      ),
      home: const PaginaEntrada(),
    );
  }
}

class PaginaEntrada extends StatefulWidget {
  const PaginaEntrada({super.key});

  @override
  State<PaginaEntrada> createState() =>
      _PaginaEntradaState();
}

class _PaginaEntradaState extends State<PaginaEntrada> {
  final _servico = ServicoAutenticacao();
  final _formulario = GlobalKey<FormState>();

  final _cpf = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  bool _cadastro = false;
  bool _carregando = false;
  bool _mostrarSenha = false;

  Usuario? _usuario;

  @override
  void dispose() {
    _cpf.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  // Mostra mensagens na parte inferior da tela.
  void _aviso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  // Alterna entre a tela de login e cadastro.
  void _trocarTela() {
    _formulario.currentState?.reset();

    setState(() {
      _cadastro = !_cadastro;
      _email.clear();
      _senha.clear();
      _confirmacao.clear();
      _mostrarSenha = false;
    });
  }

  // Executa o cadastro ou login.
  Future<void> _enviar() async {
    if (_carregando ||
        !_formulario.currentState!.validate()) {
      return;
    }

    setState(() => _carregando = true);

    try {
      if (_cadastro) {
        // CADASTRO
        final resultado = await _servico.cadastrar(
          cpf: _cpf.text,
          email: _email.text,
          senha: _senha.text,
        );

        if (!mounted) return;

        if (resultado == ResultadoCadastro.sucesso) {
          setState(() {
            _cadastro = false;
            _email.clear();
            _senha.clear();
            _confirmacao.clear();
          });

          _aviso(
            'Cadastro feito! Agora você pode entrar.',
          );
        } else {
          final mensagem = switch (resultado) {
            ResultadoCadastro.cpfInvalido =>
              'CPF inválido.',

            ResultadoCadastro.emailInvalido =>
              'Informe um e-mail válido.',

            ResultadoCadastro.senhaCurta =>
              'A senha deve ter 4 caracteres ou mais.',

            ResultadoCadastro.cpfJaCadastrado =>
              'Este CPF já está cadastrado.',

            ResultadoCadastro.sucesso =>
              'Cadastro realizado.',
          };

          _aviso(mensagem);
        }
      } else {
        // LOGIN
        final usuario = await _servico.entrar(
          cpf: _cpf.text,
          senha: _senha.text,
        );

        if (!mounted) return;

        if (usuario == null) {
          _aviso('CPF ou senha incorretos.');
        } else {
          setState(() {
            _usuario = usuario;
            _senha.clear();
          });
        }
      }
    } catch (_) {
      if (mounted) {
        _aviso('Ocorreu um erro. Tente novamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

if (_usuario != null) {
  return PaginaBibliotecaGeral(
    aoSair: () {
      setState(() {
        _usuario = null;
        _cpf.clear();
        _senha.clear();
      });
    },
  );
}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 380,
              ),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _usuario == null
                      ? _telaEntrada()
                      : _telaInicial(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TELA DE LOGIN E CADASTRO
  Widget _telaEntrada() {
    return Form(
      key: _formulario,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
           'imagens/logo_unilib.png',
           width: 180,
           height: 80,
           fit: BoxFit.contain,
           ),

          const SizedBox(height: 8),

          const SizedBox(height: 8),

          Text(
            _cadastro
                ? 'Criar conta'
                : 'Entrar na biblioteca',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // CPF
          TextFormField(
            controller: _cpf,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: const InputDecoration(
              labelText: 'CPF',
            ),
            validator: (texto) =>
                ServicoAutenticacao.cpfValido(
                  texto ?? '',
                )
                    ? null
                    : 'Digite um CPF válido.',
          ),

          // E-MAIL OBRIGATÓRIO NO CADASTRO
          if (_cadastro) ...[
            const SizedBox(height: 14),

            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
              ),
              validator: (texto) =>
                  ServicoAutenticacao.emailValido(
                    texto ?? '',
                  )
                      ? null
                      : 'Digite um e-mail válido.',
            ),
          ],

          const SizedBox(height: 14),

          // SENHA
          TextFormField(
            controller: _senha,
            obscureText: !_mostrarSenha,
            decoration: InputDecoration(
              labelText: 'Senha (mínimo de 4 caracteres)',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _mostrarSenha = !_mostrarSenha;
                  });
                },
                icon: Icon(
                  _mostrarSenha
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
            ),
            validator: (texto) =>
                (texto ?? '').length >=
                        ServicoAutenticacao.minimoSenha
                    ? null
                    : 'Use pelo menos 4 caracteres.',
          ),

          // CONFIRMAÇÃO DE SENHA
          if (_cadastro) ...[
            const SizedBox(height: 14),

            TextFormField(
              controller: _confirmacao,
              obscureText: !_mostrarSenha,
              decoration: const InputDecoration(
                labelText: 'Confirmar senha',
              ),
              validator: (texto) =>
                  texto == _senha.text
                      ? null
                      : 'As senhas não são iguais.',
            ),
          ],

          const SizedBox(height: 24),

          // BOTÃO ENTRAR OU CADASTRAR
          FilledButton(
            onPressed: _carregando ? null : _enviar,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _carregando
                    ? 'Aguarde...'
                    : _cadastro
                        ? 'Cadastrar'
                        : 'Entrar',
              ),
            ),
          ),

          // BOTÃO PARA TROCAR DE TELA
          TextButton(
            onPressed: _carregando ? null : _trocarTela,
            child: Text(
              _cadastro
                  ? 'Já tenho conta'
                  : 'Não tenho conta. Cadastrar',
            ),
          ),
        ],
      ),
    );
  }

  // TELA EXIBIDA APÓS O LOGIN
  Widget _telaInicial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),

        const SizedBox(height: 12),

        const Text(
          'Bem-vindo à UniLib!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'E-mail: ${_usuario!.email}',
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // BOTÃO SAIR
        FilledButton(
          onPressed: () {
            setState(() {
              _usuario = null;
              _cpf.clear();
              _senha.clear();
            });
          },
          child: const Text('Sair'),
        ),
      ],
    );
  }
}

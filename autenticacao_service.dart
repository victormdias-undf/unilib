
class ServicoDeAutenticacao {
  final Map<String, Map<String, String>> _alunos = {
    '001': {
      'nome': 'Maria Silva',
      'senha': '1234',
    },
    '002': {
      'nome': 'João Oliveira',
      'senha': '5678',
    },
  };

  // ve se a matricula ja existe
  bool matriculaExiste(String matricula) {
    return _alunos.containsKey(matricula.trim());
  }

  // cadastra um novo aluno
  bool cadastrarAluno(
    String matricula,
    String nome,
    String senha,
  ) {
    matricula = matricula.trim();
    nome = nome.trim();

    if (matricula.isEmpty ||
        nome.isEmpty ||
        senha.isEmpty) {
      return false;
    }

    if (matriculaExiste(matricula)) {
      return false;
    }

    _alunos[matricula] = {
      'nome': nome,
      'senha': senha,
    };

    return true;
  }

  // faz o login do aluno
  String? fazerLogin(String matricula, String senha) {
    final aluno = _alunos[matricula.trim()];

    if (aluno == null) {
      return null;
    }

    if (aluno['senha'] != senha) {
      return null;
    }

    return aluno['nome'];
  }
}

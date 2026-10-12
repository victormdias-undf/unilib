
class AutenticacaoService {
  final Map<String, Map<String, String>> alunos = {
    '0001': {
      'nome': 'Maria Silva',
      'senha': '1234',
    },
    '0002': {
      'nome': 'João Oliveira',
      'senha': '5678',
    },
  };

  bool matriculaExiste(String matricula) {
    return alunos.containsKey(matricula);
  }
  
String? fazerLogin(String matricula, String senha) {
  final aluno = alunos[matricula];

  if (aluno == null) {
    return null;
  }

  if (aluno['senha'] != senha) {
    return null;
  }

  return aluno['nome'];
}

}

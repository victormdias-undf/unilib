import 'dart:math';

/// Identificadores imprevisíveis sem dependência de banco de dados.
String gerarIdentificador({int comprimento = 32}) {
  const caracteres = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final aleatorio = Random.secure();
  return List.generate(
    comprimento,
    (_) => caracteres[aleatorio.nextInt(caracteres.length)],
  ).join();
}

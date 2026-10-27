import 'package:flutter/material.dart';
import  'Catalog/BibliotecaUniversidade/Catalog.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'Login.dart';
import 'Catalog/BibliotecaUniversidade/Catalog.dart';
class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});
   @override
  State<CadastroPage> createState() => _CadastroPageState();
}
class _CadastroPageState extends State<CadastroPage>{
  final cpfController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool temMaiuscula=false;
  bool temNumero = false;
  bool temLetra = false;
  bool temQuantidade = false;
  bool _showPass = false;

  void verificarSenha(String senha) {
  setState(() {
    temQuantidade = senha.length>=8;
    temMaiuscula = RegExp(r'[A-Z]').hasMatch(senha);
    temNumero = RegExp(r'[0-9]').hasMatch(senha);
    temLetra = RegExp(r'[a-z]').hasMatch(senha);
  });
}
  void RecuperarSenha(){
    print("MeuFi Aguente");
  }
  bool get camposValidos {
  final cpf = cpfController.text.replaceAll(RegExp(r'\D'), '');
  final senha = passController.text;
  final confirmaSenha = confirmPassController.text;

  return cpf.length == 11 && senha.length >= 8 && confirmaSenha == senha;
  } 
  @override
  void dispose(){
    cpfController.dispose();
    passController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    const String backgroundPath = "assets/Login/background.png";
    const String ImagePath = "assets/Login/perfil.png";
    const String title = "UniLib";
    const String titleFont = "Irish";
    final cpfFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    );
    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundPath),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 70),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: titleFont,
                    fontWeight: FontWeight(750),
                    color: Color.fromRGBO(103, 80, 164, 1),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Container(
                width: double.infinity,
                height: 600,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(234, 232, 255, 1),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Container(
                      width: 250,
                      child: Column(
                        children: [
                          Text(
                            "Cadastro",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight(700),
                              color: Color.fromRGBO(103, 80, 164, 1),
                            ),
                          ),
                          Text(
                            "É sempre bom uma novidade, cadastre-se!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: Column(
                          children: [
                            TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [cpfFormatter],
                              controller: cpfController,
                              maxLength: 14,
                              decoration: InputDecoration(
                                labelText: "CPF",
                                hintText: '000.000.000-00',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            TextField(
                              controller: passController,
                              obscureText: !_showPass,
                              onChanged: verificarSenha,
                              decoration: InputDecoration(
                                labelText: "Crie Sua Senha",
                                hintText: 'Crie Sua senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,), onPressed: (){ setState(() {
                                  _showPass = !_showPass;
                                });})
                              ),
                            ),
                            Align(alignment: Alignment.centerLeft, child: Column(
                              children: [
                              Align(alignment: Alignment.centerLeft, child:Text("Garanta que sua senha tenha:")),
                              RequisitoSenha("Tenha oito caractéres", temQuantidade),
                              RequisitoSenha("Pelo menos uma letra maiúscula", temMaiuscula),
                              RequisitoSenha("Pelo menos um número", temNumero),
                              RequisitoSenha("Pelo menos uma letra", temLetra),
                              ],
                            )),
                            SizedBox(height: 10),

                            TextField(
                              controller: confirmPassController,
                              obscureText: !_showPass,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: "confirme sua Senha",
                                hintText: 'Confirme Sua senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,), onPressed: (){ setState(() {
                                  _showPass = !_showPass;
                                });})
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height:10),
                    SizedBox(width: 250,
                    height: 50,
                    child:ElevatedButton(onPressed:(){camposValidos ? Navigator.push(context, MaterialPageRoute(builder: (context) => const BibliotecaPage(),),) : null;}, 
                    child: const Text("Criar Conta", style: TextStyle(color: Colors.white, fontWeight: FontWeight(700)),), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(103, 80, 164, 1),
                      disabledBackgroundColor: Color.fromRGBO(126, 115, 159, 1),
                      disabledForegroundColor: Colors.white,
                    ),)),
                    TextButton(onPressed:(){ Navigator.push(context,MaterialPageRoute( builder: (context) => const LoginPage(),),);}, child: Text("Já tem conta? Entre!", style: TextStyle(color: Color.fromRGBO(103, 80, 164, 1))), )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget RequisitoSenha(String texto, bool valido){
    return Row(children: [Align(alignment: Alignment.centerLeft, child:Text(texto)), const SizedBox(width: 8,), Icon(
        valido ? Icons.check_circle : Icons.cancel,
        color: valido ? Colors.green : Colors.red,
        size: 18,
      ),]);
  }
}
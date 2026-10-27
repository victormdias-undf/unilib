import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Catalog/BibliotecaUniversidade/Catalog.dart';
import 'Cadastro.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
   @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{
  final cpfController = TextEditingController();
  final passController = TextEditingController();
  bool _showPass = false;
  void PegarDados(){
    String cpf = cpfController.text;
    String pass = passController.text;
    
    print(cpf);
    print(pass);
  }
  void RecuperarSenha(){
    print("MeuFi Aguente");
  }
  bool get camposValidos {
  final cpf = cpfController.text.replaceAll(RegExp(r'\D'), '');
  final senha = passController.text;

  return cpf.length == 11 && senha.length >= 8;
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
              SizedBox(height: 70),
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
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage(ImagePath)),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                    Container(
                      width: 250,
                      child: Column(
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight(700),
                              color: Color.fromRGBO(103, 80, 164, 1),
                            ),
                          ),
                          Text(
                            "Que bom ter você por aqui. Entre para continuar.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
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
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: "Senha",
                                hintText: 'Insira Sua senha',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,), onPressed: (){ setState(() {
                                  _showPass = !_showPass;
                                });})
                              ),
                            ),
                            Align(alignment: Alignment.centerLeft,child: TextButton(onPressed: RecuperarSenha, child: Text("Esqueci Minha Senha", style: TextStyle(color: Color.fromRGBO(103, 80, 164, 1))), ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height:20),
                    SizedBox(width: 250,
                    height: 50,
                    child:ElevatedButton(onPressed:(){camposValidos ? Navigator.push(context, MaterialPageRoute(builder: (context) => const BibliotecaPage(),),) : null;}, child: const Text("Entrar", style: TextStyle(color: Colors.white, fontWeight: FontWeight(700)),), style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(103, 80, 164, 1),
                      disabledBackgroundColor: Color.fromRGBO(126, 115, 159, 1),
                      disabledForegroundColor: Colors.white,
                    ),)),
                    TextButton(onPressed:(){ Navigator.push(context,MaterialPageRoute( builder: (context) => const CadastroPage(),),);}, child: Text("Novo na Biblioteca? Cadastre-se!", style: TextStyle(color: Color.fromRGBO(103, 80, 164, 1))), )
                  ],
                ),
              ), 
            ],
          ),
        ),
      ),
    );
    
  }
   
 
}

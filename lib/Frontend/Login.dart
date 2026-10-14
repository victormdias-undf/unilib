import 'package:flutter/material.dart';
import  'Catalog/BibliotecaUniversidade/Catalog.dart';
import 'Cadastro.dart';
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xD8D6FF),
        child: Column(
          children: [
            SizedBox(
              height:150,
              child:Center(
                child:Text(
              "UniLib",
              style: const TextStyle(
                color: Color(0x6750A4FF),
                fontSize: 50,
                fontWeight:FontWeight(500)
              ),
            ),)
            ),
            Container(
              color: const Color(0xEAE8FFFF),
              width: double.infinity,
              height:650,
              padding: EdgeInsets.all(50),
              child: Column(
                children: [
                  Container(
                    width:double.infinity, 
                    height:200, 
                    child:Center(
                      child:Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                          ),
                          SizedBox(height:30),
                          Text("Bem-Vindo de volta!", style: TextStyle(fontWeight: FontWeight(500), fontSize: 20)),
                          Text("Entre de volta para continar"),
                        ],
                      )
                      )
                      ),
                    Container(
                      width: double.infinity,
                      height: 350,
                      child:Center(
                        child: Column(children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Nome Completo",
                              border:OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height:20),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Senha",
                              border:OutlineInputBorder()
                            ),
                          ),
                          ElevatedButton(onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BibliotecaPage(),));
                            }, child: const Text("Esqueceu sua senha?"), style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xEAE8FFFF),
                              foregroundColor: Color(0xFF8C6FFF),
                              elevation: 0
                            )
                          ),
                          SizedBox(height:25),
                          Container(
                            width:double.infinity,
                            height: 50,
                            child:ElevatedButton(onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BibliotecaPage(),));
                            }, child: const Text("Entrar"), style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8C6FFF),
                              foregroundColor: Colors.white
                            )
                            ),
                            ),
                            ElevatedButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>const CadastroPage()));
                            }, child: const Text("Novo? Cadastre-se!"), style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xEAE8FFFF),
                              foregroundColor: Color(0xFF8C6FFF),
                              elevation: 0
                            )
                          ), 
                          
                        ],)
                      )
                    )
                  
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
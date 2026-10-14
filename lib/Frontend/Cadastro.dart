import 'package:flutter/material.dart';
import  'Catalog/BibliotecaUniversidade/Catalog.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

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
            Expanded(
              child: Container(
              color: const Color(0xEAE8FFFF),
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                children: [
                  Container(
                    width:double.infinity, 
                    height:180, 
                    child:Center(
                      child:Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            color: Colors.black,
                          ),
                          SizedBox(height:30),
                          Text("Crie sua conta", style: TextStyle(fontWeight: FontWeight(500), fontSize: 20)),
                          Text("Encontre sua próxima leitura"),
                        ],
                      )
                      )
                      ),
                    Container(
                      width: double.infinity,
                      height: 430,
                      child:Center(
                        child: Column(children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Nome completo",
                              border:OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height:16),
                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "E-mail",
                              border:OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height:16),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              border:OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height:16),
                          TextField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Confirmar senha",
                              border:OutlineInputBorder()
                            ),
                          ),
                          SizedBox(height:24),
                          Container(
                            width:double.infinity,
                            height: 50,
                            child:ElevatedButton(onPressed: (){
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BibliotecaPage(),));
                            }, child: const Text("Criar conta"), style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8C6FFF),
                              foregroundColor: Colors.white
                            )
                            ),
                            ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Já tem uma conta? Entrar"),
                          ),
                          
                        ],)
                      )
                    )
                  
                      ],
              ),
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
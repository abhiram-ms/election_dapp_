import 'package:election/State/voter_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../services/Auth.dart';
import '../../services/IntoLogin.dart';

class VoteRegister extends StatelessWidget {
  final Web3Client? ethClient;
  final String? electionName;
  final String? electionAddress;
  final Map<String,dynamic> electionData;
  final Map<String,dynamic> voterMap;
   VoteRegister({Key? key, required this.ethClient, required this.electionName,
    required this.electionAddress, required this.voterMap, required this.electionData,}) : super(key: key);

  final user = Auth().currentuser;

  //sign out user
  Future<void>signOut()async{
    await Auth().signOut();
    Get.offAll(()=>const IntroLogin());
  }

  //text editing controllers
  final TextEditingController voterAdress = TextEditingController();
  final TextEditingController voterName = TextEditingController();
  final TextEditingController voterAge = TextEditingController();

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    VoterHomeController voterHomeController = Get.find();
    voterHomeController.initializerVoteRegister();
      return Container(
        decoration:  const BoxDecoration(gradient:
        LinearGradient(colors: [
          Color(0xFF516395),
          Color(0xFF614385 ),
        ])),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Voter Authorization/Register'),backgroundColor: Colors.transparent,),
          body: Stack(
            children: [
              SingleChildScrollView(
                child:Container(padding:const EdgeInsets.all(16),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: formkey,
                    child: Column(
                      children: [
                        const SizedBox(height: 24,),
                        Container(padding: const EdgeInsets.all(16),
                          child: const Text('* Note that your adhar number will be used to verify and '
                              'fetch your details(it was given at the time of registration)',style: TextStyle(color: Colors.white),),
                        ),
                        const SizedBox(height: 48,),
                        Center(
                          child: TextFormField(
                              validator: (value){
                                if(value == null||value.isEmpty){
                                  return 'please enter the details';
                                }
                                return null;
                              },
                              controller: voterName,
                              decoration:
                              const InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white),
                                  hintText: 'Name as in Adhar',border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8))))
                          ),
                        ),
                        const SizedBox(height: 24,),
                        Center(
                          child: TextFormField(
                              validator: (value){
                                if(value == null||value.isEmpty){
                                  return 'please enter the details';
                                }
                                return null;
                              },
                              controller: voterAge,
                              decoration:
                              const InputDecoration(
                                  hintStyle: TextStyle(color: Colors.white),
                                  hintText: 'Age as in adhar',border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8))))
                          ),
                        ),
                        const SizedBox(height: 24,),
                        Center(
                          child: TextFormField(
                            validator: (value){
                              if(value == null||value.isEmpty){
                                return 'please enter the details';
                              }
                              return null;
                            },
                            controller: voterAdress,
                            decoration:
                            const InputDecoration(
                                hintStyle: TextStyle(color: Colors.white),
                                hintText: 'Metamask Adress',border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)))),
                          ),
                        ),
                        const SizedBox(height: 48,),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                            onPressed: () async {
                              final FormState? form = formkey.currentState;
                              if(form != null){
                                if(form.validate()){
                                  await voterHomeController.registerVoterAuthorize(voterMap["adharnum"],voterAdress.text,voterName.text,
                                      voterAge.text,voterMap["email"],voterMap["state"]);
                                }else{
                                  Get.snackbar('fill details', 'fill all details first');
                                }
                              }else{
                                Get.snackbar('fill details', 'fill all details first');
                              }
                            },
                            child: const Text('Register',style: TextStyle(color: Colors.purple),))
                      ],
                    ),
                  ),
                ),
              ),
              GetBuilder<VoterHomeController>(builder: (_){
                if (voterHomeController.isFetching == true) {
                  return Container(
                    color: Colors.white.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(backgroundColor: Colors.redAccent,color: Colors.white,),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
            ],
          ),
        ),
      );
  }
}

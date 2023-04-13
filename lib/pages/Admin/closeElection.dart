import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../State/end_election_controller.dart';


class CloseElec extends StatelessWidget {

  final Web3Client ethClient;
  final String electionName;
  final String electionAdress;

  CloseElec({Key? key, required this.ethClient, required this.electionName, required this.electionAdress}) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final TextEditingController adharNumberController = TextEditingController();
  final TextEditingController electionNameController = TextEditingController();
  final TextEditingController adminMetamaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    EndController endController = Get.put(EndController(electionName,electionAdress));
    return Container(
      decoration:  const BoxDecoration(gradient:
      LinearGradient(colors: [
        Color(0xFF516395),
        Color(0xFF614385 ),
      ])),
      child: Scaffold(
        appBar:AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Election progress'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(  //Here we are getting the whole candidate details
              child: Form(
                key:formKey,
                child: Column(
                  children: [
                    Container(padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'please enter the details';
                          }
                          return null;
                        },
                        controller: electionNameController,
                        decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.white),
                            hintText: 'Enter Name of election  ',border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8)))
                        ),
                      ),
                    ),
                    Container(padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'please enter the details';
                          }
                          return null;
                        },
                        controller: adharNumberController,
                        decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.white),
                            hintText: 'Enter Admin Aadhaar number ',border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8)))
                        ),
                      ),
                    ),
                    Container(padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value){
                          if(value == null||value.isEmpty){
                            return 'please enter the details';
                          }
                          return null;
                        },
                        controller: adminMetamaskController,
                        decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.white),
                            hintText: 'Enter Admin metamask private key',border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8)))
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: ElevatedButton(style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.white)),
                          onPressed: () async {
                            if (formKey.currentState!.validate()){
                              //try and catch for functions
                              try{
                                endController.overlay();
                              }catch(e){
                                Get.snackbar('Error', 'Adhar Verification failed :( ');
                              }
                            } else {
                              Get.snackbar('Fill all ', 'fill all required details');
                            }
                       }, child: const Text('Close election',style: TextStyle(color: Colors.purple),)),
                    ),
                    const Divider(color: Colors.white,),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(8),
                      child: const Text('* closing  election forcefully will lead to inaccurate election results the election '
                          'will be automatically closed after a certain period of time',
                        style: TextStyle(color: Colors.white,fontSize: 16),),
                    )
                  ],
                ),
              ),
            ),
            GetBuilder<EndController>(builder: (_){
              if (endController.isOverlay == true) {
                return Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.bottomCenter,
                    color: Colors.white,
                    child: Column(
                      children: [
                        Center(
                          child: Container(padding: const EdgeInsets.all(12),
                            child: const CircleAvatar(backgroundColor: Colors.redAccent,radius:50,
                              backgroundImage: AssetImage('assets/undraw/iconwarning_.png'),)
                          ),
                        ),
                        Container(padding: const EdgeInsets.all(12),
                          child: const Text("caution : do not forcefully end election unless there is a valid reason",
                            style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold) ,),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width/2,
                              child: ElevatedButton(style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
                                  onPressed:(){
                                   endController.overlayOff();
                                  }, child:const Text('close',style: TextStyle(color: Colors.white),)),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              width: MediaQuery.of(context).size.width/2,
                              child: ElevatedButton(style: const ButtonStyle(backgroundColor:
                              MaterialStatePropertyAll(Colors.redAccent)),
                                  onPressed:(){
                                endController.toCloseElection(electionName, adharNumberController.text,
                                    adminMetamaskController.text, electionAdress);
                                  }, child:const Text('Proceed',style: TextStyle(color: Colors.white),)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
            GetBuilder<EndController>(builder: (_){
              if (endController.isFetching == true) {
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

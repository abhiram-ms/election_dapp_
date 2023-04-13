import 'package:election/State/vote_controller.dart';
import 'package:election/utils/Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../Models/Firebase/firebase_file.dart';
import '../../services/Auth.dart';
import '../../services/functions.dart';

class VoterVote extends StatelessWidget {
  final String? electionName;
  final String? electionAddress;
  final Map<String,dynamic> electionData;
  final Map<String,dynamic>?  votermap;
   VoterVote({Key? key, required this.electionName,
    required this.electionAddress, required this.votermap, required this.electionData,}) : super(key: key);

  final User? user = Auth().currentuser;
//fi// rebase auth current user initialization
  TextEditingController privateKeyController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    VoteController voteController = Get.put(VoteController(electionName, electionAddress, electionData, votermap));
      return Container(
        decoration:  const BoxDecoration(gradient:
        LinearGradient(colors: [
          Color(0xFF516395),
          Color(0xFF614385 ),
        ])),
        child: Scaffold(
          appBar:AppBar(
            backgroundColor: Colors.transparent,
            title:const Text('Vote'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key:formkey,
                  child: Column(
                    children: [
                      const Center(
                          child: SelectableText("Vote",style: TextStyle(color: Colors.white),)
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 24,bottom: 24),
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value){
                              if(value == null||value.isEmpty){
                                return 'please enter the details';
                              }else if(value.length != 64){
                                return 'enter correct key';
                              }
                              return null;
                            },
                            controller: privateKeyController,
                            decoration:
                            const InputDecoration(
                                hintStyle: TextStyle(color: Colors.white),
                                hintText: 'Private key for voting',border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8))))),
                      ),
                      FutureBuilder<List<FirebaseFile>>(
                        future: voteController.futureFiles,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return const Center(child: CircularProgressIndicator());
                            default:
                              if (snapshot.hasError) {
                                return const Center(child: Text('Some error occurred!'));
                              } else {
                                final files = snapshot.data!;

                                return SizedBox(height: 150,width: 400,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: files.length,
                                          itemBuilder: (context, index) {
                                            final file = files[index];
                                            return buildFile(context, file);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                          }
                        },
                      ),
                      GetBuilder<VoteController>(builder: (_){
                        if(voteController.isAuth==true && voteController.isVoted ==false){
                          return VotingMachiene(ethClient: voteController.ethclient,electionAddress: electionAddress,
                            voteController: voteController, privateKey:privateKeyController.text.toString(), formkey: formkey,);
                        }else if(voteController.isAuth == true && voteController.isVoted == true){
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(12),
                            // height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Card(
                              elevation: 4,
                              borderOnForeground: true,
                              child:Center(child: Text("You are already voted"),),
                            ),
                          );
                        }else{
                          return Container(
                            height: 200,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(12),
                            // height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: const Card(
                                elevation: 4,
                                borderOnForeground: true,
                                child:Center(child: Text("You are not Authorized"),),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
              GetBuilder<VoteController>(builder: (_){
                if (voteController.isFetching == true) {
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

Widget buildFile(BuildContext context, FirebaseFile file) => SizedBox(
  height: 150,width: 150,
  child: Column(
    children: [
      ClipOval(
        child: Image.network(
          file.url,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      ),
      Text(
        file.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    ],
  ),
);

class VotingMachiene extends StatelessWidget {
  const VotingMachiene({
    Key? key,
    required this.ethClient,
    required this.electionAddress,
    required this.voteController,
    required this.privateKey,
    required this.formkey,
  }) : super(key: key);

  final Web3Client? ethClient;
  final String? electionAddress;
  final VoteController voteController;
  final String privateKey;
  final GlobalKey<FormState> formkey;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List>(stream: getCandidatesInfoList(
        ethClient!, electionAddress!).asStream(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          Get.snackbar('Error ','cannot fetch data at the moment');
          return const Center(child: Text('Error : Cannot fetch data at the moment',style: TextStyle(color: Colors.white),));
        } else if(snapshot.hasData){
          if(snapshot.data!.isEmpty){
            return const Center(child: Text('There is no election at the moment',style: TextStyle(color: Colors.white),));
          }else{
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: ListView.builder(
                  itemCount: snapshot.data![0].length,
                  itemBuilder: (context,index){
                    if (kDebugMode) {
                      print('....1 ${snapshot.data![0]}');
                    }
                    if (kDebugMode) {
                      print('....2 ${snapshot.data![0][0]}');
                    }
                    if (kDebugMode) {
                      print('....3 ${snapshot.data![0][0][0]}');
                    }
                    return Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Color(0xFF7F5A83),
                              offset: Offset(-11.9, -11.9),
                              blurRadius: 39,
                              spreadRadius: 0.0,
                            ),
                            BoxShadow(color: Color(0xFF7F5A83),
                              offset: Offset(11.9, 11.9),
                              blurRadius: 39,
                              spreadRadius: 0.0,
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          gradient: LinearGradient(colors: [
                            Color(0xFF74F2CE),
                            Color(0xFF7CFFCB),
                          ])),
                      child: ListTile(
                        tileColor: Colors.transparent,
                        title: Text('${snapshot.data![0][index][0]}',
                          style: const TextStyle(color: Colors.purple,fontSize: 16),),
                        subtitle:  Text('candidate $index',
                          style: const TextStyle(color: Colors.purple),),
                        leading: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 90,
                            minWidth: 90,
                            maxHeight: 100,
                            maxWidth: 100,
                          ),
                          child:const Image(image: AssetImage('assets/undraw/electionday.png')),
                        ),
                        trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                            onPressed: ()async {
                              final FormState? form = formkey.currentState;
                              if(form != null){
                                if(form.validate()){
                                  voteController.voteBigFunction(index, privateKey);
                                }else{Get.snackbar('fill details', 'fill all details first');}
                              }else{Get.snackbar('fill details', 'fill all details first');}
                            }, child: const Text('Vote',style: TextStyle(color: Colors.purple),)),
                      ),
                    );
                  }),
            );
          }
        }else{
          Get.snackbar('Error ','cannot fetch data at the moment');
          return  const Center(child: Text('Cannot fetch data at the moment',style: TextStyle(color: Colors.white),));
        }
      },
    );
  }
}

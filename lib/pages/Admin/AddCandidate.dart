
import 'package:election/State/dashBoard_controller.dart';
import 'package:election/pages/Admin/DashBoard.dart';
import 'package:election/utils/Constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import 'package:list_picker/list_picker.dart';

import '../../services/Auth.dart';
import '../../services/functions.dart';
import '../../services/IntoLogin.dart';

class AddCandidate extends StatelessWidget {
  final Web3Client ethClient;
  final String electionName;
  final String electionAdress;
   AddCandidate({Key? key, required this.ethClient, required this.electionName, required this.electionAdress}) : super(key: key);

   final List<String> allParties = ["NO Party election","Individual",'Bharatiya Janata Party(BJP)','Indian National Congress(INC)',
     'Communist Party of India (Marxist)(CPIM)','Communist Party of India','Bahujan Samaj Party','Nationalist Congress Party',
     'All India Trinamool Congress','National Peoples Party', 'Aam Aadmi Party (AAP)',
     'All India Anna Dravida Munnetra Kazhagam (AIADMK)','All India Forward Bloc',
     'All India Majlis-e-Ittehadul Muslimeen','All India N.R. Congress','All India United Democratic Front',
     'All Jharkhand Students Union','Asom Gana Parishad','Biju Janata Dal','Jammu & Kashmir National Conference'];

  final List<String> party = ['BJP','BSP','CPI','CPM','INC','NPC','Individual','no party election'];

//firebase auth instance initialization
  final User? user = Auth().currentuser;

 //fi// rebase auth current user initialization
  Future<void> signOut() async {
    await Auth().signOut();
    Get.offAll(()=>const IntroLogin());
  }

  final formKey = GlobalKey<FormState>();

  final TextEditingController candidateNameController = TextEditingController();
  final TextEditingController candidateAdharController = TextEditingController();
  final TextEditingController adminmtmskController = TextEditingController();
  final TextEditingController selectpartycontroller = TextEditingController();

  //to refresh to see added details
  @override
  Widget build(BuildContext context) {
    DashBoardController dashBoardController = Get.find();
      return Container(
        decoration:  const BoxDecoration(gradient:
        LinearGradient(colors: [
          Color(0xFF516395),
          Color(0xFF614385 ),
        ])),
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Add Candidate',style: TextStyle(color: Colors.white),),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(padding: const EdgeInsets.all(24),
                        child: Form(key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 24,),
                              GetBuilder<DashBoardController>(builder: (_)=>InkWell(
                                onTap: () async {
                                  dashBoardController.pickCandidatePhoto();
                                },
                                child: SizedBox(height:100 ,width: 100,
                                  child: ClipRRect(borderRadius:BorderRadius.circular(100),
                                    child:Image(image:dashBoardController.isselected?Image.file(dashBoardController.filetodisplay!).image:
                                    const AssetImage('assets/undraw/electionday.png'),fit:BoxFit.fill,),),
                                ),
                              ),),
                              const SizedBox(height: 8,),
                              const Text('Picture of candidate',style: TextStyle(fontSize:16,color: Colors.white),),
                              const SizedBox(height: 8,),
                              Container(padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null||value.isEmpty){
                                      return 'please enter the details';
                                    }
                                    return null;
                                  },
                                  controller: candidateNameController,
                                  decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      hintText: 'Enter Candidate Name',border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(8)))
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4,),
                              Container(padding: const EdgeInsets.all(8),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null||value.isEmpty){
                                      return 'please enter the details';
                                    }
                                    return null;
                                  },
                                  controller: candidateAdharController,
                                  decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      hintText: 'Enter Candidate Adhar Num',border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(8)))
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4,),
                              const SizedBox(height: 8,),
                              ListPickerField(label:'party of candidate',
                                items:allParties,controller:selectpartycontroller,),
                              const SizedBox(height: 8,),
                              Container(padding: const EdgeInsets.all(16),
                                child: TextFormField(
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  validator: (value){
                                    if(value == null||value.isEmpty){
                                      return 'please enter the details';
                                    }
                                    return null;
                                  },
                                  controller: adminmtmskController,
                                  decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      hintText: 'Enter admins metamask private key',border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)))
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24,),
                              const SizedBox(height: 4,),
                              ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()&&dashBoardController.filetodisplay!=null){
                                      //try and catch for functions
                                      try{

                                        // getting adhar verified and adding candidate data
                                        await dashBoardController.getAdharVerifiedCandidate(candidateAdharController.text);
                                        if (dashBoardController.adharAge >= 18 && dashBoardController.name.toLowerCase() == candidateNameController.text.toLowerCase()) {
                                          toAddCandidate(dashBoardController);
                                          gotoHome();
                                        } else {
                                          Get.snackbar('Error', 'Age or Name doesnt match with adhar');
                                        }
                                      }catch(e){
                                        Get.snackbar('Error', 'Adhar Verification failed :( ');
                                      }
                                    } else {
                                      Get.snackbar('Fill all details ', 'add picture and data of candidate');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                  child: const Text('Add Candidate',style: TextStyle(color: Colors.purple),))
                            ],
                          ),
                        ),
                      ),
                      const Divider(thickness: 2,color: Colors.purple,),
                      Container(margin: const EdgeInsets.only(bottom: 56,left:8,),
                        child: SingleChildScrollView(
                          child: StreamBuilder<List>(stream: getCandidatesInfoList(
                              ethClient, electionAdress).asStream(),
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
                                  return ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data![0].length,
                                      itemBuilder: (context,index){
                                        if (kDebugMode) {
                                          print('....index: ${snapshot.data}');
                                        }
                                        if (kDebugMode) {
                                          print('....index: $index}');
                                        }

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
                                          padding: const EdgeInsets.all(12),
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
                                            title: Text('${snapshot.data![0][index][0]}', style: const TextStyle(fontSize:16,fontWeight:FontWeight.bold),),
                                            subtitle: Text('candidate  $index'),
                                            trailing: const Icon(Icons.poll_outlined),
                                          ),
                                        );
                                      });
                                }
                              }else{
                                Get.snackbar('Error ','cannot fetch data at the moment');
                                return  const Center(child: Text('Cannot fetch data at the moment',style: TextStyle(color: Colors.white),));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<DashBoardController>(builder: (_){
                  if (dashBoardController.isloading == true) {
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
                GetBuilder<DashBoardController>(builder: (_){
                  if (dashBoardController.isaAdharVerifying == true) {
                    return Container(
                      color: Colors.grey.withOpacity(0.5),
                      child:  Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height/2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.asset('assets/undraw/profilepicture.png'),
                                ),
                                const Expanded(child: Text('verifying aadhaar',style: TextStyle(color: Colors.deepPurple),),),
                                const CircularProgressIndicator(),
                              ],
                            ),
                          )
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              ],
            )
        ),
      );
  }

  void gotoHome(){
    Get.offAll(()=>DashBoard(ethClient:ethClient, electionName:electionName, electionAddress:electionAdress));
  }

  void toAddCandidate(DashBoardController dashBoardController) {
    Map<String,dynamic> candidateData = {
      "Name":candidateNameController.text.toString(),"Age":dashBoardController.adharAge,"adharnum":candidateAdharController.text.toString(),
      "party":selectpartycontroller.text.toString(),"email":dashBoardController.email,
      "phonenum":dashBoardController.mobile,"district":dashBoardController.district,"state":dashBoardController.state,
      "address":dashBoardController.address,"dob":dashBoardController.dob,
    };

    try{
      if (kDebugMode) {
        print(candidateData);
      }
      if(dashBoardController.filetodisplay != null){
        dashBoardController.addCandidateAndUpload(candidateData, electionName, electionAdress,adminmtmskController.text);
      }else{
        Get.snackbar("candidate photo needed ", "add a photo of candidate");
      }
    }catch(e){
      Get.snackbar('error','failed to do the action');
      if (kDebugMode) {
        print("this is toAddCandidate error $e");
      }
    }

  }
}


import 'package:election/State/dashBoard_controller.dart';
import 'package:election/services/Electioninfo.dart';
import 'package:election/services/IntoLogin.dart';
import 'package:election/pages/Voter/Vote.dart';
import 'package:election/pages/Voter/VoteRegister.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';
import '../../State/voter_home_controller.dart';
import '../../services/Auth.dart';
import '../../services/VerifyEmail.dart';
import '../../services/modelConduct.dart';
import 'Votercard.dart';

class VoterHome extends StatelessWidget {
  //getting required parameters to pass on to vote and authorize
  final Web3Client? ethClient;
  final String? electionName;
  final String? electionAddress;
  final Map<String,dynamic> electionData;
   VoterHome({Key? key, required this.ethClient, required this.electionName, required this.electionAddress, required this.electionData}) : super(key: key);

//sign out user
  final User? user = Auth().currentuser;

  Future<void>signOut()async{
    await Auth().signOut();
    Get.offAll(()=>const IntroLogin());
  }

  @override
  Widget build(BuildContext context) {
    VoterHomeController voterHomeController = Get.put(VoterHomeController());
    voterHomeController.initializer(electionName!,electionAddress!,electionData);

    if(user!.emailVerified){   //if the email is verified for the user
      return Container(
        decoration:  const BoxDecoration(gradient:
        LinearGradient(colors: [
          Color(0xFF516395),
          Color(0xFF614385 ),
        ])),
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(onPressed: () { signOut(); }, icon: const Icon(Icons.logout),),
              title: const Text('Voter DASHBOARD'),backgroundColor: Colors.transparent,),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      //mode of conduct
                      Container(
                        decoration: const BoxDecoration(),
                        padding: const EdgeInsets.only(left: 24,right: 24,bottom: 8,top: 8),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ModeOfConduct()));
                          },
                          child: Card(borderOnForeground: true,elevation: 4,
                            child: Column(
                              children: [
                                Container(height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                            image: AssetImage('assets/undraw/voting.png')))),
                                Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                  child: const Center(
                                    child: Text('Model Code of conduct',style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      //register to vote container
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            if (kDebugMode) {print(electionData);}
                            String now = DateTime.now().millisecondsSinceEpoch.toString().substring(0,10);
                            //checking if election is still valid
                            if(electionData["endedElection"] == false){
                              if(int.parse(electionData["startDate"])<int.parse(now)&& int.parse(electionData["endDate"])>int.parse(now)){
                                  Get.to(()=>VoteRegister(electionName:electionName!,
                                    ethClient: ethClient!, electionAddress:electionAddress!,
                                    voterMap:voterHomeController.voterData!,electionData: electionData,));
                              }else{Get.snackbar("election is not running","the election is not running at the moment");}
                            }else{Get.snackbar("election ended","this election is ended");}
                          },
                          child: Card(borderOnForeground: true,elevation: 4,
                            child: Column(
                              children: [
                                Container(height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                            image: AssetImage('assets/undraw/electionday.png')))),
                                Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                  child: const Center(
                                    child: Text('Register to Vote',style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      //voterCard container
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            if (kDebugMode) {print(electionData);}
                            String now = DateTime.now().millisecondsSinceEpoch.toString().substring(0,10);
                            //election check validity
                            if(electionData["endedElection"]== false){
                              if(int.parse(electionData["startDate"])<int.parse(now)&& int.parse(electionData["endDate"])>int.parse(now)){
                                Get.to(()=>Votercard(electionName:electionName!,
                                  ethClient: ethClient!, electionaddress:electionAddress!,
                                  votermap: voterHomeController.voterData,));
                              }else{Get.snackbar("election is not running","the election is not running at the moment");}
                            }else{Get.snackbar("election ended","this election is ended");}
                          },
                          child: Card(borderOnForeground: true,elevation: 4,
                            child: Column(
                              children: [
                                Container(height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                            image: AssetImage('assets/undraw/appreciation.png')))),
                                Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                  child: const Center(
                                    child: Text('Votercard ',style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      //vote container
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            String now = DateTime.now().millisecondsSinceEpoch.toString().substring(0,10);
                            if(electionData["endedElection"] == false){
                              if(int.parse(electionData["startDate"])<int.parse(now)&& int.parse(electionData["endDate"])>int.parse(now)){
                                Get.to(()=>VoterVote(electionName:electionName!,electionAddress:electionAddress!,
                                  votermap:voterHomeController.voterData, electionData:electionData,));
                              }else {Get.snackbar("election is not running","the election is not running at the moment");}
                            }else {Get.snackbar("election ended","this election is ended");}
                          },
                          child: Card(borderOnForeground: true,elevation: 4,
                            child: Column(
                              children: [
                                Container(height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                            image: AssetImage('assets/undraw/noted.png')))),
                                Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                  child: const Center(
                                    child: Text('Vote',style: TextStyle(fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      //close election container
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            Get.lazyPut(() => DashBoardController());
                            Get.to(()=>ElectionInfo(ethClient:voterHomeController.ethclient!,electionName:electionName!,
                              electionAddress: electionAddress!, electionData: electionData,));
                          },
                          child: Card(borderOnForeground: true,elevation: 4,
                            child: Column(
                              children: [
                                Container(height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: const DecorationImage(
                                            image: AssetImage('assets/undraw/electionday.png')))),
                                Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                  child: const Center(
                                    child: Text('Election details',style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
            )
        ),
      );
    }else{
      return Container(
        decoration:  const BoxDecoration(gradient:
        LinearGradient(colors: [
          Color(0xFF516395),
          Color(0xFF614385 ),
        ])),
        child: Scaffold(
          appBar:AppBar( ///app bar
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: () {
                signOut();
              },
              icon: const Icon(Icons.logout_sharp),
            ),
            title: const Text('Verify Voter email'),
          ),
          body: Container(margin: const EdgeInsets.only(top: 56),
            child: Center(
              child: Column(
                children: [
                  Center(child: Text('Your Email ${user?.email} is not verified')),
                  const SizedBox(height: 24,),
                  ElevatedButton(
                      onPressed: () {
                        Get.offAll(()=>const VerifyEmail());
                      },
                      child: const Text('Verify Email'))
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}


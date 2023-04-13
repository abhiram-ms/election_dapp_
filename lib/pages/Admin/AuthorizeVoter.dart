import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:election/State/voterauthadmin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../services/Auth.dart';
import '../../services/IntoLogin.dart';

class AuthorizeVoter extends StatelessWidget {
  final Web3Client ethClient;
  final String electionName;
  final String electionAddress;
  Map<String,dynamic> electionData;
   AuthorizeVoter({Key? key, required this.ethClient,required this.electionName,
     required this.electionAddress,required this.electionData}):super(key: key);

  //firebase auth instance initialization
  final User? user = Auth().currentuser;
 //firebase auth current user initialization
  Future<void> signOut() async {
    await Auth().signOut();
    Get.offAll(()=>const IntroLogin());
  }
  //text editing controller
  final TextEditingController voterAdressController = TextEditingController();
  final TextEditingController voterAdharController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthVoterController authVoterController = Get.put(AuthVoterController());
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFF516395),
        Color(0xFF614385),
      ])),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Authorize Voter', style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Election').doc(electionName).collection('voterAuth')
                  .where("isAuth",isEqualTo: false).where("state",isEqualTo: electionData["state"]).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                //if snapshot has no data we will show no data :
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text('Voters Not Registered yet', style: TextStyle(color: Colors.white)),
                  );
                }else if(snapshot.hasError){
                  Get.snackbar("error","error fetching data");
                  return const Text('Error 404', style: TextStyle(color: Colors.white));
                }else if(snapshot.data!.docs.isEmpty){
                  return const Center(child: Text('currently no registered voters at the moment', style: TextStyle(color: Colors.white)));
                } else {
                    return ListView.builder(
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {

                          var data = Map<String, dynamic>.from(snapshot.data?.docs[index].data() as Map);
                          Map<String,dynamic> voterdetails = {
                            "adhar": data["adharnum"],"voterAddress":data["voterAddress"],"voterAge":int.parse(data["voterAge"].toString()),
                            "email":data["email"],"isAuth":data["isAuth"],"isVoted":data["isVoted"],"voterName":data["voterName"],
                          };

                          //print
                          if (kDebugMode) {print(data);}
                          if (kDebugMode) {print(data["voterAge"]);}
                          if (kDebugMode) {print('adhaaaarrrrrrrrrrrrrrrr ===== ${voterdetails["adhar"]}');}
                          //print end

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12, top: 12),
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Container(
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
                                title: Text(data["voterName"], style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.purple),),
                                subtitle: Text('age : ${data["voterAge"]}',style: const TextStyle(fontSize: 14, color: Colors.purple),),
                                leading: Text(index.toString(), style: const TextStyle(color: Colors.purple)),
                                trailing: ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      //icon inside button
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Icon(voterdetails["voterAge"] >= 18 ? Icons.check : Icons.warning_amber,
                                          color: voterdetails["voterAge"] >= 18 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      //text inside button
                                      const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Text("Authorize", style: TextStyle(color: Colors.purple,fontWeight: FontWeight.bold,),),
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    if (voterdetails["voterAddress"] != null && voterdetails["voterAge"] >= 18) {
                                        await authVoterController.bigAuthorize(authVoterController,electionName,
                                            voterdetails["voterAddress"], voterdetails["adhar"],ethClient,electionAddress);
                                    } else {
                                      Get.snackbar("no match", "adhar data has no match or enter voter address ");
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        });
                }
              },
            ),
            GetBuilder<AuthVoterController>(builder: (_){
              if (authVoterController.isloading == true) {
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

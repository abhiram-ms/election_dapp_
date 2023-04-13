import 'package:election/State/dashBoard_controller.dart';
import 'package:election/pages/Admin/AddCandidate.dart';
import 'package:election/pages/Admin/AuthorizeVoter.dart';
import 'package:election/pages/Admin/closeElection.dart';
import 'package:election/services/Electioninfo.dart';
import 'package:election/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../services/modelConduct.dart';


class DashBoard extends StatelessWidget {
  final Web3Client ethClient;
  final String electionName;
  final String electionAddress;
  const DashBoard(
      {Key? key, required this.ethClient, required this.electionName, required this.electionAddress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashBoardController dashBoardController = Get.put(DashBoardController());
    dashBoardController.initializeDashBoard(electionName, electionAddress);
    return Container(
      decoration:  const BoxDecoration(gradient:
      LinearGradient(colors: [
        Color(0xFF516395),
        Color(0xFF614385 ),
      ])),
      child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 5,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title:Text('Election : ${elecdata.read('elecData')['electionName']}'),
            leading: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // drawer
                dashBoardController.signOut();
              },
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
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
                    Container(
                      decoration: const BoxDecoration(),
                      padding: const EdgeInsets.only(left: 24,right: 24,bottom: 8,top: 8),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddCandidate(
                                      ethClient: ethClient,
                                      electionName: electionName, electionAdress:electionAddress,)));
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
                                  child: Text('Add Candidate',style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Color(0xFF8693AB),
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
                      ),
                      padding: const EdgeInsets.only(left: 24,right: 24,bottom: 8,top: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthorizeVoter(ethClient:ethClient,electionName:electionName,
                                    electionAddress:electionAddress, electionData:dashBoardController.electionDataAdmin,)));
                        },
                        child: Card(borderOnForeground: true,elevation: 4,
                          child: Column(
                            children: [
                              Container(height: 200,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      image: const DecorationImage(
                                          image: AssetImage('assets/undraw/upvote.png')))),
                              Container(decoration: const BoxDecoration(color: Colors.purple),width: double.infinity,
                                child: const Center(
                                  child: Text('Authorize Voter',style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(color: Color(0xFF8693AB),
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
                      ),
                      padding: const EdgeInsets.only(left: 24,right: 24,bottom: 8,top: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ElectionInfo(ethClient:ethClient,electionName:electionName,
                                electionAddress:electionAddress, electionData:dashBoardController.electionDataAdmin,)));
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
                                  child: Text('Election Info',style: TextStyle(
                                      fontWeight: FontWeight.bold,fontSize:16,color: Colors.white),),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(),
                      padding: const EdgeInsets.only(right: 24,left: 24,bottom: 8,top: 4),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CloseElec(ethClient:ethClient,
                                      electionName: electionName, electionAdress: electionAddress)));
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
                                  child: Text('End election Get Results',style: TextStyle(
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
            ],
          )),
    );
  }
}

import 'package:election/services/functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web3dart/web3dart.dart';
import '../Models/Firebase/firebase_file.dart';
import '../Models/candidates_model.dart';
import '../State/dashBoard_controller.dart';
import '../State/homeController.dart';

class ElectionInfo extends StatelessWidget {
  final Web3Client ethClient;
  final String electionName;
  final String electionAddress;
  final Map<String,dynamic> electionData;
   const ElectionInfo(
      {Key? key,
      required this.ethClient,
      required this.electionName,
      required this.electionAddress,required this.electionData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DashBoardController dashBoardController = Get.find();
    dashBoardController.initialize(electionName);
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
        body: SingleChildScrollView(  //Here we are getting the whole candidate details
          child: Column(
            children: [
              Column(
                children: [
                  cardBuild(context, electionData),
                  cardBuildWinner(context, electionData,dashBoardController),
                ],
              ),
              const SizedBox(height: 24,),
              FutureBuilder<List<FirebaseFile>>(
                future: dashBoardController.futureFiles,
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
              Container(margin: const EdgeInsets.only(bottom: 56),
                child: StreamBuilder<List>(stream: getCandidatesInfoList(ethClient, electionAddress).asStream(),
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
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data![0].length,
                              shrinkWrap: true,
                              itemBuilder: (context,index){

                                Candidates candidates = Candidates(
                                    name:snapshot.data![0][index][0],
                                    votes:snapshot.data![0][index][1].toInt());

                                // print(candidatesnapshot.data);
                                if (kDebugMode) {
                                  print('....1 ${snapshot.data![0]}');
                                }
                                if (kDebugMode) {
                                  print('....2 ${snapshot.data![0][0]}');
                                }
                                if (kDebugMode) {
                                  print('....3 ${snapshot.data![0][0][0]}');
                                }

                                //calculating leader
                                dashBoardController.calculateLeader(candidates,snapshot.data![0].length);
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
                                    onTap: () {
                                      // Get.offAll(()=>DashBoard(
                                      //     ethClient:homeController.ethclient!,
                                      //     electionName: snapshot.data![0][index][0],
                                      //     electionaddress: snapshot.data![0][index][1].toString()));
                                    },
                                    title: Text('${snapshot.data![0][index][0]}', style: const TextStyle(fontSize:16,fontWeight:FontWeight.bold),),
                                    subtitle: Text('votes  ${snapshot.data![0][index][1]}'),
                                    trailing: const Icon(Icons.poll_outlined),
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
                ),
              ),
              const SizedBox(height: 12,),
              Container(padding: const EdgeInsets.all(16),
                child: GetBuilder<DashBoardController>(builder:(_)=>
                    Text('The leading candidate of the election is :\n \n ${dashBoardController.winner} \n \n with votes ${dashBoardController.winnervotes}',
                        style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,)),),
              ),
              const SizedBox(height: 16,),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GetBuilder<DashBoardController>(builder: (_)=>Text(
                        dashBoardController.candidatesNum.toString(),
                        style: const TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold,color: Colors.white),
                      ),),
                      const Text('Total Candidates',style: TextStyle(color: Colors.white))
                    ],
                  ),
                  const SizedBox(height: 24,),
                  Column(
                    children: [
                      FutureBuilder<List>(
                          future: getTotalVotes(
                              ethClient, electionAddress),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Text(
                              snapshot.data![0].toString(),
                              style: const TextStyle(
                                  fontSize: 50, fontWeight: FontWeight.bold,color: Colors.white),
                            );
                          }),
                      const Text('Total Votes',style: TextStyle(color: Colors.white))
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    GetBuilder<DashBoardController>(builder: (_)=>SfCircularChart(
                      title: ChartTitle(text: 'Voters with votes'),
                      legend:Legend(isVisible: true,overflowMode:LegendItemOverflowMode.wrap) ,
                      series: <CircularSeries>[
                        PieSeries<Candidates,String>(
                            dataSource: dashBoardController.candidateset.toList(),
                            xValueMapper:(Candidates data,_)=>data.name,
                            yValueMapper: (Candidates data,_)=>data.votes,
                            dataLabelSettings: const DataLabelSettings(isVisible: true)
                        )
                      ],
                    ),)
                  ],
                ),
              ),
              const SizedBox(height: 16,)
            ],
          ),
        ),
      ),
    );
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

}

Widget cardBuild(BuildContext context, Map<String,dynamic> electionData){
  var dateEnd = DateTime.fromMillisecondsSinceEpoch(int.parse(electionData["endDate"]) * 1000);
  var dateStart = DateTime.fromMillisecondsSinceEpoch(int.parse(electionData["startDate"]) * 1000);
  return Container(
    padding: const EdgeInsets.only(bottom: 24,top: 24),
    margin: const EdgeInsets.only(bottom: 24,top: 24),
    width: MediaQuery.of(context).size.width-20,
    child:   Card(
      elevation: 4,
      child:Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
              child:  Text("Election Details :${electionData["electionName"]} ", style: const TextStyle(
                  color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 16),)),
          const Divider(color: Colors.deepPurple,),
          Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
            child: Text('Name :${electionData["electionName"]} ',style: const TextStyle(
                fontWeight: FontWeight.bold,fontSize:16,color: Colors.deepPurple)),
          ),
          Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
            child: Text('State :${electionData["state"]}',style: const TextStyle(
                fontWeight: FontWeight.bold,fontSize:16,color: Colors.deepPurple)),
          ),
          Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
            child: Text('district : ${electionData["district"]} ',style: const TextStyle(
                fontWeight: FontWeight.bold,fontSize:16,color: Colors.deepPurple)),
          ),
          Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
            child: Text('election Start Date  : $dateStart ',style: const TextStyle(
                fontWeight: FontWeight.bold,fontSize:16,color: Colors.deepPurple)),
          ),
          Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
            child: Text('election end date : $dateEnd ',style: const TextStyle(
                fontWeight: FontWeight.bold,fontSize:16,color: Colors.deepPurple)),
          ),
        ],
      ),
    ),
  );
}

Widget cardBuildWinner(BuildContext context, Map<String,dynamic> electionData,DashBoardController dashBoardController){
  var dateEnd = DateTime.fromMillisecondsSinceEpoch(int.parse(electionData["endDate"]) * 1000);
  var dateStart = DateTime.fromMillisecondsSinceEpoch(int.parse(electionData["startDate"]) * 1000);

  if(electionData["endedElection"] == true){
    return Container(
      height: 150,
      padding: const EdgeInsets.only(bottom: 24,top: 24),
      margin: const EdgeInsets.only(bottom: 24,top: 24),
      width: MediaQuery.of(context).size.width-20,
      child:   Card(
        color: Colors.deepPurple,
        elevation: 4,
        child:Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<DashBoardController>(builder:(_)=>Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
              child: Text('Winner : ${dashBoardController.winner} ',style: const TextStyle(
                  fontWeight: FontWeight.bold,fontSize:16,color: Colors.white)),),),
            GetBuilder<DashBoardController>(builder:(_)=>Container(padding:const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
                 child: Text('Votes : ${dashBoardController.winnervotes} ',style: const TextStyle(
                  fontWeight: FontWeight.bold,fontSize:16,color: Colors.white)),),)
          ],
        ),
      ),
    );
  }else{
    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 24,top:16),
      margin: const EdgeInsets.only(bottom: 24,top: 5),
      width: MediaQuery.of(context).size.width-20,
      child:   Card(
        color: Colors.deepPurple,
        elevation: 4,
        child:Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8),margin: const EdgeInsets.all(4),
                child:  const Text("Winner : Election is still in Progress ", style: TextStyle(
                    color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),)),
          ],
        ),
      ),
    );
  }
}
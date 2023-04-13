import 'package:election/utils/Constants.dart';
import 'package:flutter/material.dart';

class ModeOfConduct extends StatelessWidget {
  const ModeOfConduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      backgroundColor: Colors.deepPurple,
      body: SingleChildScrollView(
        child: Column(
          children:  [
            Container(
                padding: const EdgeInsets.all(16),
                child: const Text("MODEL CODE OF CONDUCT",style: TextStyle(color: Colors.white),)
            ),
            Container(
              padding: const EdgeInsets.all(16),
                child: Text(codeOfConduct,style: const TextStyle(color: Colors.white),)
            ),
          ],
        ),
      ),
    );
  }
}

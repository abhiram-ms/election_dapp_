
import 'package:get_storage/get_storage.dart';

String infura_url = "https://goerli.infura.io/v3/3e448350bebc4059b528c9db597ae43a";
String owner_private_key = "f6468ec22fe10152849e4301db68f056933c5367832fa4dcd97e1e5a808834f3";
String voter_private_key = "d776f6a25865caf6e86335204ea98b8cd4ad810e67c0f4004b7ef3efd93dd5df";
String voter_key2 = "c048c73b5d73183eb12e1206be61afc2d35428b348190f77b2aa0f4f136f99bf";
String voter_key3 = "2713a415e1c4288cf248a6bc348fe41ed0b092297b3ee1d06e6f0274d12f118a";

String gnacheurl = "HTTP://127.0.0.1:7545";

String voter_adress = "0xc4d9eE2d363b465443D751F7D553919281D1bd0a";
String voter_adress2 = "0x2f8434dA7347C7c5266eDcCf9C36D33aa7D59dD4";
String voter_adress3 = "0x6435Fdf5B2888A81C08c6dF5e4AF3F2580744e0F";
String contractAdressConst = "0x841D7265aF2F5A4d4346d8A07aE5D91f1a440c4e";
String contractAdressElection = "";

final elecbox = GetStorage();
final elecdata = GetStorage();

var codeOfConduct = '''1. No political party or candidate can secure votes on the basis of caste and religion. That is the reason that temples, mosques, churches, and other religious places shall not be used for election propaganda/campaigning.

2. No political party or candidate shall be involved in any such activity so that there is an atmosphere of hatred and tension among the people of different castes and religions.

3. Political Parties and candidates will have the right to criticize the policies and programs, past records, and work of their opposition parties. Parties and candidates shall refrain from commenting on the personal life or family of any candidate.

4. Threatening voters, giving bribes, campaigning in the periphery of 100 meters from polling booths, organizing a public meeting within 48 hours of polling, and arranging transport “to and from” the polling booths is also prohibited.

5. No political parties or candidates shall permit their followers to use the land, building, compound, wall, a vehicle without the permission of the property owner for pasting pamphlets, banners, displaying party flags, writing slogans, etc.

6. Political parties or candidates shall ensure that their supporters neither obstruct the meeting and rally of the opposition parties or candidates nor distribute pamphlets in the meeting organised by the opposition parties.

7. Political parties or the candidates shall have to seek prior permission from the police or concerned authorities of the area before organizing the meeting at any place so that traffic and other necessary arrangements can be made.

8. If a Political party or a candidate is about to organize the procession, then ‘it or he’ has to inform; (about its time, the path of procession, place of starting of the procession and the place where the procession will end) to the concerned authorities.


9. Political parties or candidates shall ensure that the identity slip given to the voters on the day of polling shall be printed on plain (white) paper.  The Slip shall not have a name/symbol of any political party or the candidate.

voter slip

10. The Voters should not be served alcohol, etc. on the day of polling and 24 hours prior to polling.

workers drinking liqour

11. The ruling party's ministers shall not use government machinery like government employees, vehicles, government buildings during elections campaigning.

12. The ruling party shall not have a monopoly over public places, helipads, and aircraft, the candidates of other parties will also be able to use them with the same conditions as the ruling party is following.

13. No advertisement will be published or displayed at the cost of the public exchequer through newspapers & other media during the election. Other media will also not be used to disseminate the achievements of the government.

14. The ministers and other authorities shall not sanction grants/payments out of discretionary funds from the date elections are announced by the commission.

15. Since the elections dates are announced by the Election Commission, the ministers and other officials shall not do the following tasks;

a. Announce any financial grant or any new scheme or promise thereof.

b. Make any promise of construction of roads, provision of drinking water facilities, etc.

c. Lay foundation stones etc. of project or scheme of any kind (except civil servants).

d. Make any ad-hoc appointments in government, public undertakings, etc.  ''';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:woodeco/app/token_manager.dart' as woodeco_token_manager;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  DateTime selectedDate = DateTime.now();
  bool isMale = true;

  List<bool> isSelected = [
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  final List<List<String>> preferenceNames = [
    ["조용함", "활기참"],
    ["가성비", "가심비"],
    ["실내", "실외"],
    ["실용적", "창의적"],
    ["단순함", "화려함"],
    ["전통적", "현대적"],
    ["내성적", "외향적"]
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitData() async {
    String? userId = woodeco_token_manager.TokenManager.instance.accessToken;
    if (userId == null){
      print("No access token available");
      return;
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    var url = Uri.parse('http://49.247.34.221:8000/signup/');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'birth': formattedDate,
        'sex': isMale,
        'tastes': isSelected,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushNamed(context, '/main');
    } else {
      // Handle error
      print('Failed to create user');
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy. MM. dd').format(selectedDate);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "생년월일",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: ListTile(
                title: Text(formattedDate),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "성별",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ToggleButtons(
                fillColor: const Color.fromRGBO(255, 180, 180, 0.3),
                borderColor: Colors.black54,
                selectedBorderColor: Colors.black54,
                selectedColor: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                isSelected: [isMale, !isMale],
                onPressed: (int index) {
                  setState(() {
                    isMale = index == 0;
                  });
                },
                constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width / 2 - 20),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '남',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: isMale ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '여',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: isMale ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "취향",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...List<Widget>.generate(7, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ToggleButtons(
                  fillColor: const Color.fromRGBO(255, 180, 180, 0.3),
                  borderColor: Colors.black54,
                  selectedBorderColor: Colors.black54,
                  selectedColor: Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  isSelected: [isSelected[index], !isSelected[index]],
                  onPressed: (int idx) {
                    setState(() {
                      isSelected[index] = idx == 0;
                    });
                  },
                  constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width / 2 - 20),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        preferenceNames[index][0],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: isSelected[index] ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        preferenceNames[index][1],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: isSelected[index] ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(  // shape 속성을 추가
                    borderRadius: BorderRadius.circular(10),  // BorderRadius를 10으로 설정
                  ),
                ),
                onPressed: _submitData,
                child: const Text('완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

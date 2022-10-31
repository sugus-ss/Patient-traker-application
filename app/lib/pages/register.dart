import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var fname=TextEditingController();
  var lname=TextEditingController(); 
  var dateController=TextEditingController(); 
  var email=TextEditingController(); 
  var username=TextEditingController();
  var password=TextEditingController();
  String result='';
  String? _radioValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Page'), backgroundColor: Colors.indigo[400]),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: ListView(
          children: [
            Center(child: Text('Registration Form')),
            SizedBox(height: 10),
            TextField(
              controller: fname,
              decoration: InputDecoration(hintText: 'first name'),
            ),
            SizedBox(height: 30),
            TextField(
              controller: lname,
              decoration: InputDecoration(hintText: 'last name'),
            ),
            SizedBox(height: 30),
            Text('Select your gender:'),
            genderRadio(),
            SizedBox(height: 15),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                icon: Icon(Icons.calendar_today),
                labelText: 'Enter Birth Date'
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), //get today's date
                  firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
                  lastDate: DateTime(2101)
                );
                if(pickedDate!=null ){
                      print(pickedDate);  //get the picked date in the format => 2022-07-04 00:00:00.000
                      String formattedDate=DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                      print(formattedDate); //formatted date output using intl package =>  2022-07-04
                        //You can format date as per your need

                      setState(() {
                         dateController.text=formattedDate; //set foratted date to TextField value. 
                      });
                  }
                else{
                  print("Date is not selected");
                }
              }
            ),
            SizedBox(height: 30),
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: 'email'),
            ),
            SizedBox(height: 30),
            TextField(
              controller: username,
              decoration: InputDecoration(hintText: 'username'),
            ),
            SizedBox(height: 30),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(hintText: 'password'),
            ),
            SizedBox(height: 30),
            ElevatedButton(onPressed: () {
              print(dateController);
              register_newuser();
            }, child: Text('Register')),
            SizedBox(height: 30),
            Center(child: Text(result, style: TextStyle(color: Colors.indigo, fontSize: 20)))
          ],
        )),
      ),
    );
  }

  Widget genderRadio() {
    return Row(
      children: [
        Radio(value: 'MALE', groupValue: _radioValue, onChanged: (String? value) {
          setState(() {
            _radioValue=value;
          });
        }),
        Text('Male', style: TextStyle(fontSize: 14)),
        Radio(value: 'FEMALE', groupValue: _radioValue, onChanged: (String? value) {
          setState(() {
            _radioValue=value;
          });
        }),
        Text('Female', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Future register_newuser() async {
    //var url=Uri.https('', '/api/newuser);
    var url=Uri.http('192.168.1.52:8000','/api/newuser');
    Map<String, String> header={"Content-type":"application/json"};

    String v1='"username":"${username.text}"';
    String v2='"password":"${password.text}"';
    String v3='"email":"${email.text}"';
    String v4='"first_name":"${fname.text}"';
    String v5='"last_name":"${lname.text}"';
    String v6='"gender":"$_radioValue"';
    String v7='"birthday":"${dateController.text}"';

    String jsondata='{$v1, $v2, $v3, $v4, $v5, $v6, $v7}';
    var response=await http.post(url, headers: header, body: jsondata);
    print('---register newuser---');
    print(response.body);  // view.py return token

    var resulttext=utf8.decode(response.bodyBytes);
    var result_json=json.decode(resulttext);
    String status=result_json['status'];

    if(status=='account-created') {
      String setresult='Congratulations, ${result_json['first_name']} ${result_json['last_name']}\nYou are already a new member.';
      String token=result_json['token'];
      setToken(token);  // เมื่อได้รับ token แล้ว ให้ทำการบันทึกลงไปในระบบ
      setState(() {
        result=setresult;
      });
    }
    else if(status=='user-exist') {
      setState(() {
        result='Already has this user in our system, please try a new one!';
      });
    }
    else {
      setState(() {
        result='Incorrect information, please check again!';
      });
    }
  }

  Future<void> setToken(token) async {
    final SharedPreferences pref=await SharedPreferences.getInstance();
    pref.setString('token', token);
  }
}
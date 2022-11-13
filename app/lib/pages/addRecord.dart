import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({Key? key}) : super(key: key);

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  String result='Note field can be empty';
  String? patientId, medId;
  bool success = false;
  //final patientIdController = TextEditingController();
  //final medicineIdController = TextEditingController();
  final diseaseController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  var caretakerid;

  // list of patient
  List rawpatient = [];
  var patientList = ['No Patient'];

  // list of medicine
  List rawmed = [];
  var medList = ['No Medicine'];

  @override
  void initState() {
    super.initState();
    
    //patientIdController.addListener(() => setState(() {}));
    //medicineIdController.addListener(() => setState(() {}));
    diseaseController.addListener(() => setState(() {}));
    getMyPatient();
    getMedicine();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(12, 16, 12, 12),
        children: [
          buildPatientId(),
          const SizedBox(height: 16,),
          buildMedicineId(),
          const SizedBox(height: 16,),
          buildDisease(),
          const SizedBox(height: 16,),
          buildStartDate(),
          const SizedBox(height: 16,),
          buildEndDate(),
          const SizedBox(height: 16,),
          buildAmount(),
          const SizedBox(height: 16,),
          buildNote(),
          const SizedBox(height: 16,),
          ElevatedButton(onPressed: () {

            if(patientId == null || medList == null || diseaseController.text.isEmpty ||
                startDateController.text.isEmpty || endDateController.text.isEmpty || amountController.text.isEmpty) {
              setState(() {
                result='Please input all information!';
              });
            }
            else {
              DateTime timeStart = DateTime.parse(startDateController.text);
              DateTime timeEnd = DateTime.parse(endDateController.text);
              if(timeStart.isAfter(timeEnd)) {
                setState(() {
                  result='End medicine intake date must be after Start date!';
                });
              }
              else {
                createRecord();
                setState(() {
                  result='Create a record successfully!';
                  success = true;
                  patientId=null;
                  medId=null;
                  diseaseController.clear();
                  startDateController.clear();
                  endDateController.clear();
                  amountController.clear();
                  noteController.clear();
                });
              }
            }
            final snackBar = SnackBar(
              content: Text(
                result,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
                backgroundColor: !success ? Colors.red[900]: Colors.green[900]
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            success = false;
          },
          child: const Text(
            'Create a record',
            style: TextStyle(
              fontSize: 16,
            ),
          )),

        ],
      ),
    );
  }
  Widget buildPatientId() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(48, 2, 12, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey,),
          ),
          child: DropdownButton<String>(
            // controller: patientIdController,
            hint: Text('Patient ID'),
            value: patientId,
            isExpanded: true,
            items: patientList.map(buildPatient).toList(),
            onChanged: (patientId) => setState(() => this.patientId = patientId),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 14.0, left: 12.0),
          child: Icon(
            Icons.person,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  DropdownMenuItem<String> buildPatient(String patient) {
    return DropdownMenuItem(
      value: patient,
      child: Text(
        patient,
      ),
    );
  }

  Widget buildMedicineId() {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(48, 2, 12, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey,),
          ),
          child: DropdownButton<String>(
            hint: Text('Medicine ID'),
            value: medId,
            isExpanded: true,
            items: medList.map(buildPatient).toList(),
            onChanged: (medId) => setState(() => this.medId = medId),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 14.0, left: 12.0),
          child: Icon(
            Icons.medication,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  Widget buildDisease() {
    return TextField(
      controller: diseaseController,
      decoration: InputDecoration(
        labelText: 'Disease',
        prefixIcon: Icon(Icons.medical_information),
        suffixIcon: diseaseController.text.isEmpty
            ? Container(width: 0)
            : IconButton(
          icon: Icon(Icons.close),
          onPressed: () => diseaseController.clear(),
        ),
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.done,
    );
  }
  Widget buildStartDate() {
    return TextField(
      controller: startDateController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
        labelText: 'Start medicine intake Date',
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
            startDateController.text=formattedDate; //set foratted date to TextField value.
          });
        }
        else{
          print("Date is not selected");
        }
      }
    );
  }
  Widget buildEndDate() {
    return TextField(
      controller: endDateController,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_month),
        labelText: 'End medicine intake Date',
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(), //get today's date
          firstDate: DateTime(1900), //DateTime.now() - not to allow to choose before today.
          lastDate: DateTime(2101),
        );
        if(pickedDate!=null ){
          print(pickedDate);  //get the picked date in the format => 2022-07-04 00:00:00.000
          String formattedDate=DateFormat('yyyy-MM-dd').format(pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
          print(formattedDate); //formatted date output using intl package =>  2022-07-04
          //You can format date as per your need

          setState(() {
            endDateController.text=formattedDate; //set foratted date to TextField value.
          });
        }
        else{
          print("Date is not selected");
        }
      }
    );
  }
  Widget buildAmount() {
    return TextField(
      controller: amountController,
      decoration: InputDecoration(
        labelText: 'Amount of medicine',
        border: OutlineInputBorder(),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
      ],
      keyboardType: TextInputType.number,
    );
  }
  Widget buildNote() {
    return TextFormField(
      controller: noteController,
      minLines: 3,
      maxLines: 5,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Note (optional)',
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> getCaretakerID() async {
    final SharedPreferences pref=await SharedPreferences.getInstance();
    var id=pref.getInt('id');
    var url=Uri.https('weatherreporto.pythonanywhere.com', '/api/ask-caretakerid/$id');
    var response=await http.get(url);
    var result=utf8.decode(response.bodyBytes);
    print('get my careataker id');
    print(result);
    setState(() {
      caretakerid=result;
    });
  }

  Future<void> getMyPatient() async {
    await getCaretakerID();
    var url=Uri.https('weatherreporto.pythonanywhere.com', '/api/get-mypatient/$caretakerid');
    var response=await http.get(url);
    var result=utf8.decode(response.bodyBytes);
    print(url);
    print('Get my patient');
    print(result);
    setState(() {
      rawpatient=jsonDecode(result);
      if(rawpatient.length>0) {
        patientList=[];
        for(int i=0; i<rawpatient.length; ++i) {
          patientList.add(rawpatient[i]['name']);
        }
      }
    });
  }

  Future<void> getMedicine() async {
    var url=Uri.https('weatherreporto.pythonanywhere.com', '/api/all-medicine');
    var response=await http.get(url);
    var result=utf8.decode(response.bodyBytes);
    setState(() {
      rawmed=jsonDecode(result);
      if(rawmed.length>0) {
        medList=[];
        for(int i=0; i<rawmed.length; ++i) {
          medList.add("M"+"${rawmed[i]['id']}"+": "+rawmed[i]['Medicine_name']);
        }
      }
    });
  }

  Future<void> createRecord() async {
    var url = Uri.https('weatherreporto.pythonanywhere.com', '/api/post-record');
    Map<String, String> header = {"Content-type": "application/json"};

    String temp_string_pid='', temp_string_mid='';
    int temp_int_pid=0, temp_int_mid=0;
    if(patientId!=null) {
      temp_string_pid=patientId!;
      int i=1;
      while(temp_string_pid[i]!=':') {
        ++i;
      }
      temp_string_pid=temp_string_pid.substring(1, i);
      temp_int_pid=int.parse(temp_string_pid);
    }
    if(medId!=null) {
      temp_string_mid=medId!;
      int i=1;
      while(temp_string_mid[i]!=':') {
        ++i;
      }
      temp_string_mid=temp_string_mid.substring(1, i);
      temp_int_mid=int.parse(temp_string_mid);
    }
    
    String v1='"patient":$temp_int_pid';
    String v2='"medicine":$temp_int_mid';
    String v3='"Record_disease":"${diseaseController.text}"';
    String v4='"Record_amount":${amountController.text}';
    String v5='"Record_start":"${startDateController.text}"';
    String v6='"Record_end":"${endDateController.text}"';
    String v7='"Record_info":"${noteController.text}"';
    String v8='"Record_isComplete":"false"';
    String jsondata = '{$v1, $v2, $v3, $v4, $v5, $v6, $v7, $v8}';
    //print(jsondata);

    var response = await http.post(url, headers: header, body: jsondata);
    var uft8result=utf8.decode(response.bodyBytes);
    print('ADD RECORD!');
    print(uft8result);
  }
}

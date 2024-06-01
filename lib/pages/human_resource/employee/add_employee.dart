import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';
import 'package:path/path.dart' as path;

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../model/Single.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';


class AddEmployee extends StatefulWidget {

  
  Navbools nn;
  AddEmployee({required  this.nn});
  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  String
      _imgtext = "No File Chosen";
  bool img = false;
  int _sts = 1;
  late Uint8List pickedImage;
  final _conemplfname = TextEditingController(),
      _conempllname = TextEditingController(),
      _conemplphone = TextEditingController(),
      _conemplsalary = TextEditingController(),
      _conemplemail = TextEditingController(),
      _conemplblood = TextEditingController(),
      _conempladdress1 = TextEditingController(),
      _conempladdress2 = TextEditingController(),
      _conemplcountry = TextEditingController(),
      _conemplcity = TextEditingController(),
      _conemplzip = TextEditingController();

  var designation = [], sdesignation = [], ratetype = ["Hourly", "Salary"];
  FirebaseStorage storage = FirebaseStorage.instance;
  var _selecteddesignation, _selectedratetype;
  var _selecteddesignationid;

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Designation')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["status"]) {
          designation.add(new Single(id: element.id, name: element["Name"]));
          sdesignation.add(element["Name"]);
          setState(() {});
        }
      });
    });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  _addEmployee(BuildContext context) async {
    String address2 = "";
    String fname = _conemplfname.text;
    String lname = _conempllname.text;
    String phone = _conemplphone.text;
    String salary = _conemplsalary.text;
    String email = _conemplemail.text;
    String blood = _conemplblood.text;
    String address1 = _conempladdress1.text;
    address2 = _conempladdress2.text;
    String country = _conemplcountry.text;
    String city = _conemplcity.text;
    String zip = _conemplzip.text;
    bool cstats = true;
    if(_sts == 2){
      cstats = false;
    }
    if (fname.isEmpty || lname.isEmpty ||
        phone.isEmpty || address1.isEmpty || country.isEmpty || zip.isEmpty || city.isEmpty ||
        salary.isEmpty ||
        email.isEmpty ||
        blood.isEmpty ||
        _selecteddesignationid == null|| _selectedratetype == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
            "First Name, Last Name, Phone, Address Line 1, Salary, Email, Blood, Country, Zip is Required!!"),
      ));
    } else {
      if (img) {
        final photoRef = storage.ref(
            "Employee/" + fname + phone + _selecteddesignationid.name + ".jpeg");
        UploadTask uploadTask = photoRef.putData(
            pickedImage,
            SettableMetadata(
              contentType: "image/jpeg",
            ));
        String url = await (await uploadTask).ref.getDownloadURL();
        FirebaseFirestore.instance.collection('Employee').add({
          'First Name': fname,
          'Last Price': lname,
          'Phone': phone,'User':AuthService.to.user?.name,
          'Email':email,
          'Address Line 1': address1,
          'Address Line 2': address2,
          'Image': true,
          'ImageURL': url,
          'Salary': salary,
          'Country': country,
          'City': city,
          'Zip': zip,
          'status':cstats,
          'Blood Group': blood,
          'Designation Name': _selecteddesignationid.name,
          'Designation ID': _selecteddesignationid.id,
          'Rate': _selectedratetype,
        }).then((value) async {
          widget.nn.setnavbool();
          widget.nn.human_resource =true;
          widget.nn.human_resource_employee = true;
          widget.nn.hr_employee_employee_list = true;
          Get.offNamed(employeelistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Employee Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      } else {
        FirebaseFirestore.instance.collection('Employee').add({
          'First Name': fname,
          'Last Name': lname,
          'Phone': phone,
          'Email':email,
          'Address Line 1': address1,
          'Address Line 2': address2,'User':AuthService.to.user?.name,
          'Image': false,
          'ImageURL': "null",
          'Salary': salary,
          'Country': country,
          'City': city,
          'Zip': zip,
          'status':cstats,
          'Blood Group': blood,
          'Designation Name': _selecteddesignationid.name,
          'Designation ID': _selecteddesignationid.id,
          'Rate': _selectedratetype,
        }).then((value) async {


          widget.nn.setnavbool();
          widget.nn.human_resource =true;
          widget.nn.human_resource_employee = true;
          widget.nn.hr_employee_employee_list = true;
          Get.offNamed(employeelistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Employee Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      }
    }
  }

  Future<void> _selectImage() async {
    final fromPicker = await ImagePickerWeb.getImageAsBytes();
    if (fromPicker != null) {
      setState(() {
        pickedImage = fromPicker;
        _imgtext = "File Chosen";
        img = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

 
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn,),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: _height / 8, left: 30),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      margin: EdgeInsets.only(right: _width / 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                              text: "Add Employee", size: 32, weight: FontWeight.bold),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "First Name",
                                    size: 16,
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Last Name",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conemplfname,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "First Name",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conempllname,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Last Name",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Designation",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Phone",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      hint: Text('Select Designation'),
                                      value: _selecteddesignation,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selecteddesignationid =
                                          designation[sdesignation.indexOf(newValue)];
                                          _selecteddesignation = newValue.toString();
                                        });
                                      },
                                      items: designation.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(location.name),
                                          value: location.name,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conemplphone,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Phone",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Rate Type",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Hour Rate/Salary",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      hint: Text('Select Rate Type'),
                                      value: _selectedratetype,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedratetype = newValue.toString();
                                        });
                                      },
                                      items: ratetype.map((location) {
                                        return DropdownMenuItem(
                                          child: new Text(location),
                                          value: location,
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conemplsalary,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Hour Rate/Salary",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Email",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Blood Group",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conemplemail,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Email",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      textCapitalization: TextCapitalization.sentences,
                                      controller: _conemplblood,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Blood Group",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Address Line 1",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Address Line 2",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conempladdress1,keyboardType: TextInputType.multiline,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Address Line 1",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),

                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conempladdress2,keyboardType: TextInputType.multiline,
                                      minLines: 3,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Address Line 2",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Country",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Image",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    width: _height/6,
                                    child: TextFormField(
                                      controller: _conemplcountry,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Country",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: Container(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.grey.shade200,
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _selectImage();
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              margin: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[350],
                                                border: Border.all(width: 1, color: dark),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: CustomText(
                                                text: "Choose File",
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: CustomText(
                                              text: _imgtext,
                                              size: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "City",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Zip",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [

                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    width: _height/6,
                                    child: TextFormField(
                                      controller: _conemplcity,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "City",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conemplzip,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(5.0)),
                                          borderSide: BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Zip",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Status",
                                      size: 16,
                                    )),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Preview",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    child: Column(
                                      children: [
                                        RadioListTile(
                                          title: Text("Active"),
                                          value: 1,
                                          groupValue: _sts,
                                          onChanged: (value) {
                                            setState(() {
                                              _sts = int.parse(value.toString());;
                                            });
                                          },
                                        ),
                                        RadioListTile(
                                          title: Text("Deactivate"),
                                          value: 2,
                                          groupValue: _sts,
                                          onChanged: (value) {
                                            setState(() {
                                              _sts = int.parse(value.toString());;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      height: MediaQuery.of(context).size.height / 6,
                                      width: MediaQuery.of(context).size.width / 3,
                                      margin: EdgeInsets.only(right: 20, top: 10),
                                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                                      child: img
                                          ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 5, color: Colors.grey.shade200)),
                                        padding: EdgeInsets.all(5),
                                        child: Image.memory(
                                          pickedImage,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                                width: 5, color: Colors.grey.shade200)),
                                        padding: EdgeInsets.all(5),
                                        child: Image.asset(
                                            "assets/images/def_employee.jpg"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: _height / 30, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _addEmployee(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonbg,
                                        elevation: 20,
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                      ),
                                      child: CustomText(
                                        text: "Submit",
                                        weight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: _height / 5,
                                  ),
                                  flex: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        )));
  }
}

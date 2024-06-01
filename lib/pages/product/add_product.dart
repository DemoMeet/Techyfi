import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/Single.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddProduct extends StatefulWidget {
  Navbools nn;
  AddProduct({required this.nn});
  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  String _imgtext = "No File Chosen";
  bool img = false, processing = false;
  int _sts = 1;
  late Uint8List pickedImage;
  final _conprocode = TextEditingController(),
      _conproname = TextEditingController(),
      _conprodetails = TextEditingController(),
      _conproprice = TextEditingController(),
      _conprobodyrate = TextEditingController(),
      _conprostrength = TextEditingController(),
      _conpromenuprice = TextEditingController();

  var brand = [],
      unit = [],
      category = [],
      sbrand = [],
      sunit = [],
      scategory = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  var _selectedbrand, _selectedunit, _selectedcategory;
  var _selectedbrandid, _selectedunitid, _selectedcategoryid;

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Brand')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        brand.add(Single(id: element.id, name: element["Name"]));
        sbrand.add(element["Name"].toString());
        setState(() {});
      });
    });

    await FirebaseFirestore.instance
        .collection('Unit')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["status"]) {
          unit.add(Single(id: element.id, name: element["Name"]));
          sunit.add(element["Name"].toString());
          setState(() {});
        }
      });
    });

    await FirebaseFirestore.instance
        .collection('Category')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["status"]) {
          category.add(Single(id: element.id, name: element["Name"]));
          scategory.add(element["Name"].toString());
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

  _addProduct(BuildContext context) async {
    setState(() {
      processing = true;
    });
    String barcode = _conprocode.text;
    String name = _conproname.text;
    String strength = _conprostrength.text;
    String details = _conprodetails.text;
    String perprice = _conproprice.text;
    String bodyrate = _conprobodyrate.text;
    String menuperprice = _conpromenuprice.text;
    bool cstats = true;
    if (_sts == 2) {
      cstats = false;
    }
    if (barcode.isEmpty ||
        name.isEmpty ||
        strength.isEmpty ||
        perprice.isEmpty ||
        menuperprice.isEmpty ||
        _selectedcategoryid == null ||
        _selectedunitid == null ||
        _selectedbrandid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
            "Bar Code, Product Name, Strength, Price, Category, Unit & Purchase Price is Required!!"),
      ));
    } else {
      if (img) {
        final photoRef = storage.ref(
            "${"Products/$name$perprice" + _selectedcategoryid.name}.jpeg");
        UploadTask uploadTask = photoRef.putData(
            pickedImage,
            SettableMetadata(
              contentType: "image/jpeg",
            ));
        String url = await (await uploadTask).ref.getDownloadURL();
        FirebaseFirestore.instance.collection('Products').doc(barcode).set({
          'Product Name': name,
          'Product Price': double.parse(perprice),
          'Code': barcode,
          'Strength': strength,
          'Image': true,
          'ImageURL': url,
          'Body Rate': bodyrate,
          'User': AuthService.to.user?.name,
          'Product Details': details,
          'Unit ID': _selectedunitid.id,
          'Unit Name': _selectedunitid.name,
          'status': cstats,
          'Purchase Price': double.parse(menuperprice),
          'Brand ID': _selectedbrandid.id,
          'Brand Name': _selectedbrandid.name,
          'Category ID': _selectedcategoryid.id,
          'Category Name': _selectedcategoryid.name,
        }).then((value) async {
          widget.nn.setnavbool();
          widget.nn.product = true;
          widget.nn.product_list = true;
          Get.offNamed(productlistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Product Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      } else {
        FirebaseFirestore.instance.collection('Products').doc(barcode).set({
          'Product Name': name,
          'Product Price': double.parse(perprice),
          'Code': barcode,
          'Strength': strength,
          'Image': false,
          'ImageURL': '',
          'User': AuthService.to.user?.name,
          'Product Details': details,
          'Unit ID': _selectedunitid.id,
          'Unit Name': _selectedunitid.name,
          'status': cstats,
          'Body Rate': bodyrate,
          'Purchase Price': double.parse(menuperprice),
          'Brand ID': _selectedbrandid.id,
          'Brand Name': _selectedbrandid.name,
          'Category ID': _selectedcategoryid.id,
          'Category Name': _selectedcategoryid.name,
        }).then((value) async {
          widget.nn.setnavbool();
          widget.nn.product = true;
          widget.nn.product_list = true;
          Get.offNamed(productlistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Product Added Successfully!"),
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
        appBar: MyAppBar(
          height: _height,
          width: _width,
        ),
        body: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.screenSize.value
                    ? SideMenuBig(widget.nn)
                    : SideMenuSmall(
                        widget.nn,
                      ),
                Expanded(
                    child: Container(
                  margin: EdgeInsets.only(top: _height / 8, left: 30),
                  alignment: Alignment.center,
                  child: processing
                      ? const CircularProgressIndicator()
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            margin: EdgeInsets.only(right: _width / 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                    text: "Add Product",
                                    size: 32,
                                    weight: FontWeight.bold),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: CustomText(
                                            text: "Bar Code/ QR Code",
                                            size: 16,
                                          )),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: CustomText(
                                          text: "Product Name",
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conprocode,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Bar Code/ QR Code",
                                              fillColor: Colors.grey.shade200,
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 1,
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conproname,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Product Name",
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
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: CustomText(
                                            text: "Brand",
                                            size: 16,
                                          )),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: CustomText(
                                          text: "Category",
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            hint: Text('Select Brand'),
                                            value: _selectedbrand,
                                            onChanged: (Value) {
                                              setState(() {
                                                _selectedbrandid = brand[
                                                    sbrand.indexOf(Value)];
                                                _selectedbrand =
                                                    Value.toString();
                                              });
                                            },
                                            items: brand.map((location) {
                                              return DropdownMenuItem(
                                                child: Text(location.name),
                                                value: location.name,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: DropdownButton(
                                            underline: SizedBox(),
                                            isExpanded: true,
                                            hint: Text('Select Category'),
                                            value: _selectedcategory,
                                            onChanged: (Value) {
                                              setState(() {
                                                _selectedcategoryid = category[
                                                    scategory.indexOf(Value)];
                                                _selectedcategory =
                                                    Value.toString();
                                              });
                                            },
                                            items: category.map((location) {
                                              return DropdownMenuItem(
                                                child: Text(location.name),
                                                value: location.name,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: CustomText(
                                            text: "Strength",
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
                                          text: "Unit",
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conprostrength,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Product Size",
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
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: DropdownButton(
                                              underline: SizedBox(),
                                              isExpanded: true,
                                              hint: const Text('Select Unit'),
                                              value: _selectedunit,
                                              onChanged: (Value) {
                                                setState(() {
                                                  _selectedunitid = unit[
                                                      sunit.indexOf(Value)];
                                                  _selectedunit =
                                                      Value.toString();
                                                });
                                              },
                                              items: unit.map((location) {
                                                return DropdownMenuItem(
                                                  child: Text(location.name),
                                                  value: location.name,
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: CustomText(
                                          text: "Product Price",
                                          size: 16,
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: CustomText(
                                          text: "Purchase Price",
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conproprice,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'(^\d*\.?\d*)'))
                                            ],
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Price",
                                              fillColor: Colors.grey.shade200,
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conpromenuprice,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'(^\d*\.?\d*)'))
                                            ],
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Buying Price",
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
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: CustomText(
                                            text: "Body Rate",
                                            size: 16,
                                          )),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: CustomText(
                                          text: "Product Details",
                                          size: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conprobodyrate,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'(^\d*\.?\d*)'))
                                            ],
                                            decoration: InputDecoration(
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Body Rate",
                                              fillColor: Colors.grey.shade200,
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          child: TextFormField(
                                            controller: _conprodetails,
                                            decoration: InputDecoration(
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.transparent),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.blue),
                                              ),
                                              hintText: "Product Details",
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
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          flex: 10,
                                          child: CustomText(
                                            text: "Image",
                                            size: 16,
                                          )),
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      Expanded(flex: 10, child: SizedBox())
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                                    border: Border.all(
                                                        width: 1,
                                                        color: dark),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                      const Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                      ),
                                      const Expanded(
                                          flex: 10, child: SizedBox()),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                  margin: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          child: Column(
                                            children: [
                                              RadioListTile(
                                                title: Text("Active"),
                                                value: 1,
                                                groupValue: _sts,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _sts = int.parse(
                                                        value.toString());
                                                  });
                                                },
                                              ),
                                              RadioListTile(
                                                title: Text("Deactivate"),
                                                value: 2,
                                                groupValue: _sts,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _sts = int.parse(
                                                        value.toString());
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            height: _height / 6,
                                            width: _width / 3,
                                            margin: EdgeInsets.only(
                                                right: 20, top: 10),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: img
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            width: 5,
                                                            color: Colors.grey
                                                                .shade200)),
                                                    padding: EdgeInsets.all(5),
                                                    child: Image.memory(
                                                      pickedImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        border: Border.all(
                                                            width: 5,
                                                            color: Colors.grey
                                                                .shade200)),
                                                    padding: EdgeInsets.all(5),
                                                    child: Image.asset(
                                                        "assets/images/def_product.jpg"),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: _height / 25, left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _addProduct(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: buttonbg,
                                            elevation: 20,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20),
                                          ),
                                          child: CustomText(
                                            text: "Submit",
                                            weight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                          height: _height / 5,
                                        ),
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

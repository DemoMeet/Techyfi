import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/pages/roles/widgets/users_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/User.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

import '../../widgets/custom_text.dart';

class UserList extends StatefulWidget {
  
  
  Navbools nn;
  UserList(
      { required this.nn});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  late FocusNode myFocusNode;
  String dropdownvalue = 'Search By Name';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _nametop = false,
      _namebot = false,
  _lointop = false,
  _loinbot = false,
  _louttop = false,
  _loutbot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<User> allUsers = [];
  List<User> foundUserss = [];
  TextEditingController search_Users = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.management = true;
      widget.nn.management_user_list= true;
      controller.onChange(false);
      _first = true;
    }
  }
  void _fetchDocuments() async {
    await FirebaseFirestore.instance
        .collection('User')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        allUsers.add(User(
            id: element["ID"],
            sts: element["Admin"],
            name: element["Name"],
            details: element["Details"],user: element['User'],
            uid: element["UID"],lastlogin:  element["Last Login"].toDate(),lastlogout:  element["Last Logout"].toDate(),
            pass: element["Password"],
            phone: element["Phone"],
            asset: element["Assets"],
        ));
      });
    });
    foundUserss = allUsers;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundUserss.length; i += _items) {
      chunks.add(foundUserss.sublist(i,
          i + _items > foundUserss.length ? foundUserss.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundUserss.length / _items).floor() + 1;
    });
  }

  void _onEditManufact(User cst) {
    // Navigator.of(context).push( MaterialPageRoute(builder: (context) => EditUsers(cst,_refreshdata),),);
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    myFocusNode = FocusNode();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<User> results = [];
    if (enteredKeyword.isEmpty) {
      results = allUsers;
    } else {
      results = allUsers
          .where((user) => user.name
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundUserss = results;
    });
    makechunks();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    void changeVal(String i) {
      setState(() {
        _click[val] = false;
        _click[int.parse(i)] = true;
        val = int.parse(i);
      });
    }

    Future<List<User>> getCust() async {
      List<User> Userss = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Userss.add(chunks[_currentpagenum - 1][ss]);
      }
      return Userss;
    }

 

    return Scaffold(
        extendBodyBehindAppBar: true,
        
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: _height / 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: _width / 45.6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              text: "User List",
                              size: 22,
                              weight: FontWeight.bold,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              child: InkWell(
                                child: Image.asset(
                                  "assets/icons/download_csv.png",
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, top: 5),
                              child: InkWell(
                                child: Image.asset(
                                  "assets/icons/download_pdf.png",
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: _width / 5,
                          margin: EdgeInsets.only(
                              top: 10, bottom: 10, right: _width / 25),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextField(
                            focusNode: myFocusNode,
                            controller: search_Users,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              prefixIcon: Icon(Icons.search),
                              hintText: dropdownvalue,
                              fillColor: Colors.white,
                              filled: true,
                            ),
                            onChanged: (value) => _runFilter(value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        children: [
                          Container(
                            color: Colors.grey.shade200,
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 30),
                                      child: Text(
                                        "SL",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: tabletitle,
                                            fontFamily: 'inter'),
                                      ),
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 7,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Name",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (!_nametop) {
                                              _nametop = true;
                                              _namebot = false;
                                              _loinbot = false;
                                              _lointop = false;
                                              _loutbot = false;
                                              _louttop = false;
                                              allUsers.sort((a, b) => a.name
                                                  .compareTo(b.name));
                                              makechunks();
                                            } else {
                                              _nametop = false;
                                              _namebot = true;
                                              _loinbot = false;
                                              _lointop = false;
                                              _loutbot = false;
                                              _louttop = false;
                                              allUsers.sort((b, a) => a.name
                                                  .compareTo(b.name));
                                              makechunks();
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              transform:
                                                  Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_up,
                                                color: _nametop
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                            Container(
                                              transform:
                                                  Matrix4.translationValues(
                                                      0.0, -8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: _namebot
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "User ID",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tabletitle,
                                          fontFamily: 'inter'),
                                    ),
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 6,

                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Last Login",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (!_lointop) {
                                              _lointop = true;
                                              _namebot = false;
                                              _loinbot = false;
                                              _nametop = false;
                                              _loutbot = false;
                                              _louttop = false;
                                              allUsers.sort((a, b) => a.lastlogin
                                                  .compareTo(b.lastlogin));
                                              makechunks();
                                            } else {
                                              _nametop = false;
                                              _loutbot = true;
                                              _namebot = false;
                                              _lointop = false;
                                              _loutbot = false;
                                              _louttop = false;
                                              allUsers.sort((b, a) => a.lastlogin
                                                  .compareTo(b.lastlogin));
                                              makechunks();
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              transform:
                                              Matrix4.translationValues(
                                                  0.0, 8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_up,
                                                color: _lointop
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                            Container(
                                              transform:
                                              Matrix4.translationValues(
                                                  0.0, -8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: _loinbot
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 6,

                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Last Logout",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (!_louttop) {
                                              _louttop = true;
                                              _namebot = false;
                                              _loinbot = false;
                                              _nametop = false;
                                              _loutbot = false;
                                              _lointop = false;
                                              allUsers.sort((a, b) => a.lastlogout
                                                  .compareTo(b.lastlogout));
                                              makechunks();
                                            } else {
                                              _nametop = false;
                                              _loutbot = false;
                                              _namebot = false;
                                              _lointop = false;
                                              _loutbot = true;
                                              _louttop = false;
                                              allUsers.sort((b, a) => a.lastlogout
                                                  .compareTo(b.lastlogout));
                                              makechunks();
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              transform:
                                              Matrix4.translationValues(
                                                  0.0, 8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_up,
                                                color: _louttop
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                            Container(
                                              transform:
                                              Matrix4.translationValues(
                                                  0.0, -8.0, 0.0),
                                              child: Icon(
                                                Icons.arrow_drop_down,
                                                color: _loutbot
                                                    ? Colors.black
                                                    : Colors.black45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Role",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tabletitle,
                                          fontFamily: 'inter'),
                                    ),
                                  ),
                                ),
                                Text("|"),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "ACTION",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tabletitle,
                                          fontFamily: 'inter'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: _height / 1.60,
                            child: FutureBuilder(
                              builder: (ctx, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text(
                                          "No Roles Data Available.."),
                                    );
                                  } else if (snapshot.hasData) {
                                    return MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        // physics: NeverScrollableScrollPhysics(),
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          _click.add(false);
                                          return UsersListItem(
                                            index: index,
                                            cst: snapshot.data[index],
                                            click: _click[index],
                                            changeVal: changeVal,
                                            fetchDocuments: _fetchDocuments,
                                            onEditManufact: _onEditManufact,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              future: getCust(),
                            ),
                          ),
                          _width > 600
                              ? Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 45),
                                        child: Row(
                                          children: [
                                            CustomText(
                                              text: "Show entries",
                                              size: 12,
                                              color: tabletitle,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: DropdownButton<int>(
                                                value: _items,
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),
                                                items: items.map((int items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: CustomText(
                                                      text: items.toString(),
                                                      size: 12,
                                                      color: tabletitle,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    _items = newValue!;
                                                    makechunks();
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 10,
                                      ),
                                      Container(
                                        width: _width / 3,
                                        child: NumberPaginator(
                                          controller: _controller,
                                          numberPages: _totalpagenum,
                                          onPageChange: (int index) {
                                            setState(() {
                                              _currentpagenum = index + 1;
                                              _click = [];
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 15,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        )));
  }
}

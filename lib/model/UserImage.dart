class Users {
  List<useritem> items = [];

  inituser() {
    items.add(
        useritem(status: true, asset: "assets/icons/user_icon/icn (1).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (2).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (3).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (4).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (5).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (6).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (7).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (8).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (9).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (10).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (11).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (12).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (13).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (14).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (15).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (16).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (17).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (18).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (19).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (20).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (21).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (22).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (23).png"));
    items.add(
        useritem(status: false, asset: "assets/icons/user_icon/icn (24).png"));
  }

  useritem getActiveItems() {
    return items.firstWhere((item) => item.status);
  }
  setallfalse(int index) {
    for (int i = 0; i < items.length; i++) {
      useritem item = items[i];
      item.status = false;
      if (i == index) {
        item.status = true;
      }
    }
  }
}

class useritem {
  String asset;
  bool status;
  useritem({required this.status, required this.asset});
}

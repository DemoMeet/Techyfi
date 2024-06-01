class Single {
  late String name,id, details;
  late bool selected;

  Single.withdetails({required this.name, required this.id, required this.details});


  Single.withSelected({ required this.name, required this.id, required this.details, required this.selected});

  Single({ required this.name, required this.id});

}

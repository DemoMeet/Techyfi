class General {
  String name, status, id;
  int sl;

  late String details;

  General(
      {required this.name,
        required this.status,
        required this.id,
        required this.sl});

  General.withDetails(this.name, this.details, this.status, this.id, this.sl);
  Map toJson() => {
    'Name': name,
    'Status': status,
    'ID': id,
    'sl': sl
  };
  factory General.fromJson(dynamic json) {
    return General(
        name: json['Name'] as String,
        status: json['Status'] as String,
        id: json['ID'] as String,
        sl: json['sl'] as int);
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:work_time_recorder/db_provider.dart';

class Record {
  var id;
  var title;
  var time_in;
  var latitude_in;
  var longitude_in;
  var address_in;
  var address_in_detail;
  var time_out;
  var latitude_out;
  var longitude_out;
  var address_out;
  var address_out_detail;
  var create_date;
  var update_date;

  Record(
      {this.id, this.title, this.time_in, this.latitude_in, this.longitude_in, this.address_in, this.address_in_detail,
        this.time_out, this.latitude_out, this.longitude_out, this.address_out, this.address_out_detail, this.create_date, this.update_date,});

  Record.newRecord(){
    title = "";
    time_in = "";
    latitude_in = "";
    longitude_in = "";
    address_in = "";
    address_in_detail = "";
    time_out = "";
    latitude_out = "";
    longitude_out = "";
    address_out = "";
    address_out_detail = "";
    create_date = "";
    update_date = "";
  }

  assignUUID() {
    id = Uuid().v4();
  }

  factory Record.fromMap(Map<String, dynamic> json) =>
      Record(
          id: json["id"],
          title: json["title"],
          time_in: json["time_in"],
          latitude_in: json["latitude_in"],
          longitude_in: json["longitude_in"],
          address_in: json["address_in"],
          address_in_detail: json["address_in_detail"],
          time_out: json["time_out"],
          latitude_out: json["latitude_out"],
          longitude_out: json["longitude_out"],
          address_out: json["address_out"],
          address_out_detail: json["address_out_detail"],
          create_date: json["create_date"],
          update_date: json["update_date"]
      );

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "title": title,
        "time_in": time_in,
        "latitude_in": latitude_in,
        "longitude_in": longitude_in,
        "address_in": address_in,
        "address_in_detail": address_in_detail,
        "time_out": time_out,
        "latitude_out": latitude_out,
        "longitude_out": longitude_out,
        "address_out": address_out,
        "address_out_detail": address_out_detail,
        "create_date": create_date,
        "update_date": update_date
      };
}


final recordListProvider = AsyncNotifierProvider<RecordListNotifier, RecordList>(RecordListNotifier.new);

@immutable
class RecordList{
  final List<Record> recordList;
  final Record lastRecord;
  final Record selectedRecord;
  const RecordList({
    required this.recordList,
    required this.lastRecord,
    required this.selectedRecord,
  });
  RecordList copyWith({List<Record>? recordList, Record? lastRecord, Record? selectedRecord,}){
    return RecordList(recordList: recordList ?? this.recordList, lastRecord: lastRecord ?? this.lastRecord, selectedRecord: selectedRecord ?? this.selectedRecord,);
  }
}

class RecordListNotifier extends AsyncNotifier<RecordList> {
  @override
  Future<RecordList> build() {
    return createRecordList();
  }
  Future<RecordList> createRecordList() async {
    print("createRecordList()");
    final List<Record> _list = await DBProvider.db.getAllRecord();
    _list.sort((a,b) => b.create_date.compareTo(a.create_date));// 新しい順
    final _lastRec = _list.isEmpty ? Record() : _list[0];// 一番新しいレコード,無ければ空のレコードを渡す
    return RecordList(recordList: _list, lastRecord: _lastRec, selectedRecord: _lastRec);
  }
  Future updateState(RecordList _list) async {// stateの更新
    print("updateState()");
    await update((data){
      final newState = _list;
      return newState;
    });
  }
  Future reloadRecordList() async {
    print("reloadRecordList()");
    final List<Record> _list = await DBProvider.db.getAllRecord();
    _list.sort((a,b) => b.create_date.compareTo(a.create_date));// 新しい順
    final _lastRec = _list.isEmpty ? Record() : _list[0];// 一番新しいレコード,無ければ空のレコードを渡す
    final _newList = state.value!.copyWith(recordList: _list, lastRecord: _lastRec);
    // final _newList = RecordList(recordList: _list, lastRecord: _lastRec, selectedRecord: _lastRec);
    updateState(_newList);
  }
  selectRecord(Record _selectedRec){
    print("selectRecord()");
    final _newList = state.value!.copyWith(selectedRecord: _selectedRec);
    updateState(_newList);
  }
}
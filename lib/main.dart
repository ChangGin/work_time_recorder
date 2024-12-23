import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_time_recorder/app_localizations.dart';
import 'package:work_time_recorder/db_provider.dart';
import 'package:work_time_recorder/geo.dart';
import 'package:work_time_recorder/list.dart';
import 'package:work_time_recorder/permission_handler.dart';
import 'package:work_time_recorder/record.dart';


final versionTextProvider = AsyncNotifierProvider<VersionTextNotifier, String>(VersionTextNotifier.new);
class VersionTextNotifier extends AsyncNotifier<String>{
  @override
  Future<String> build() {
    return getAppVersion();
  }
  Future<String> getAppVersion() async {
    print("getAppVersion");
    var packageInfo = await PackageInfo.fromPlatform();
    var appVersion = packageInfo.version;
    return appVersion;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //MobileAds.instance.initialize();
  runApp(
    ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Working time rec',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(color: Colors.brown[100],elevation: 3.0),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(selectedItemColor: Colors.lightBlueAccent[200],elevation: 10.0),
        primarySwatch: Colors.blue,
        primaryColor: Colors.brown[200],
      ),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en"),
        const Locale("ja"),
        const Locale("ko"),
      ],
      home: MainPage(),
    );
  }
}

class MainPage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _geoProvider = ref.read(geoProvider);
    _checkPermission(context, ref);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).appTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.list),
              onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListPage()));},
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child){
                  final _recordListProvider = ref.watch(recordListProvider);
                  return _recordListProvider.when(
                    error: (e,stack) => Text("error$e/$stack"),
                    loading: () => CircularProgressIndicator(),
                    data: (data){
                      if(data.recordList.isEmpty){
                        return Text("レコードがありません");
                      }
                      if(data.lastRecord.time_out == null){
                        return Text("時刻:${data.lastRecord.time_in}\n場所:${data.lastRecord.address_in}\nステータス:出勤済み");
                      }else{
                        return Text("時刻:${data.lastRecord.time_out}\n場所:${data.lastRecord.address_out}\nステータス:退勤済み");
                      }
                    }
                  );
                },
              ),
              OutlinedButton(
                child: Text("出勤する"),
                onPressed: (){
                  final _recordList = ref.read(recordListProvider).hasValue ? ref.read(recordListProvider).value!.recordList : [];
                  final _lastRecord = ref.read(recordListProvider).hasValue ? ref.read(recordListProvider).value!.lastRecord : Record();
                  if(_recordList.isNotEmpty && _lastRecord.time_out == null){// リストが空でない、かつ、前回の退勤記録がない時は確認する
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          title: Text("退勤記録がありません"),
                          content: Text("前回の退勤が記録されていません。新規出勤を記録しますか？"),
                          actions: [
                            TextButton(
                              child: Text("キャンセル"),
                              onPressed: (){Navigator.pop(context);},
                            ),
                            TextButton(
                              child: Text("はい"),
                              onPressed: (){
                                _recordWorkIn(ref);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }else{// 記録リストが空、または、前回の退勤がある時はそのまま出勤記録する
                    _recordWorkIn(ref);
                  }
                },
              ),
              OutlinedButton(
                child: Text("退勤する"),
                onPressed: () {
                  final _recordList = ref.read(recordListProvider).hasValue ? ref.read(recordListProvider).value!.recordList : [];
                  final _lastRecord = ref.read(recordListProvider).hasValue ? ref.read(recordListProvider).value!.lastRecord : Record();
                  if(_recordList.isNotEmpty && _lastRecord.time_out == null){// 記録リストが空でない、かつ、前回の退勤記録がない時はそのまま退勤記録する
                    _recordWorkOut(ref, false);// レコード更新
                  }else{
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("出勤記録がありません"),
                          content: Text("前回の出勤が記録されていません。退勤のみを記録しますか？"),
                          actions: [
                            TextButton(
                              child: Text("キャンセル"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text("はい"),
                              onPressed: () {
                                _recordWorkOut(ref, true);// 新規レコード作成フラグ
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _recordWorkIn(WidgetRef ref) async {
    print("_recordWorkIn()");
    final _geoProvider = ref.read(geoProvider);
    await ref.read(geoProvider.notifier).getGeoPosition();
    if(_geoProvider.hasValue){
      var data = _geoProvider.value!;
      print("${data.place.country}/"// 日本
          "${data.place.administrativeArea}/"// 都道府県
          "${data.place.locality}/"// 市
          "${data.place.thoroughfare}/"// 無し
          "${data.place.subAdministrativeArea}/"// 無し
          "${data.place.subLocality}/"// 区
          "${data.place.subThoroughfare}/"// 無し
          "${data.place.street}/"// 全部
          "${data.place.name}");// 建物

      var now = DateTime.now();
      var timeFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
      final _record = Record(
        id: null,
        title: timeFormatter.format(now).toString(),
        time_in: timeFormatter.format(now).toString(),
        latitude_in: data.position.latitude.toString(),
        longitude_in: data.position.longitude.toString(),
        address_in: "${data.place.administrativeArea}${data.place.locality}${data.place.subLocality}",
        address_in_detail: "${data.place.street}",
        create_date: timeFormatter.format(now).toString(),
        update_date: timeFormatter.format(now).toString(),
      );
      _record.assignUUID();// ID作成
      final res = DBProvider.db.createRecord(_record);
      ref.read(recordListProvider.notifier).reloadRecordList();
    };
  }
  _recordWorkOut(WidgetRef ref, bool isNewFlag) async {
    print("_recordWorkOut()");
    final _geoProvider = ref.read(geoProvider);
    final _recordListProvider = ref.read(recordListProvider);
    await ref.read(geoProvider.notifier).getGeoPosition();
    if(_geoProvider.hasValue){
      var data = _geoProvider.value!;
      var now = DateTime.now();
      var timeFormatter = DateFormat("yyyy-MM-dd HH:mm:ss");
      final _lastRecord = _recordListProvider.value!.lastRecord;
      final _updatedRecord = Record(
        id: isNewFlag ? null : _lastRecord.id,
        title: isNewFlag ? timeFormatter.format(now).toString() : _lastRecord.title,
        time_in: isNewFlag ? null : _lastRecord.time_in,
        latitude_in: isNewFlag ? null : _lastRecord.latitude_in,
        longitude_in: isNewFlag ? null : _lastRecord.longitude_in,
        address_in: isNewFlag ? null : _lastRecord.address_in,
        address_in_detail: isNewFlag ? null : _lastRecord.address_in_detail,
        time_out: timeFormatter.format(now).toString(),
        latitude_out: data.position.latitude.toString(),
        longitude_out: data.position.longitude.toString(),
        address_out: "${data.place.administrativeArea}${data.place.locality}${data.place.subLocality}",
        address_out_detail: "${data.place.street}",
        create_date: isNewFlag ? timeFormatter.format(now).toString() : _lastRecord.create_date,
        update_date: timeFormatter.format(now).toString(),
      );
      if(isNewFlag){
        _updatedRecord.assignUUID();// ID作成
        final res = DBProvider.db.createRecord(_updatedRecord);
      }else{
        final res = DBProvider.db.updateRecord(_updatedRecord);
      }
      ref.read(recordListProvider.notifier).reloadRecordList();
    };
  }

  _checkPermission(BuildContext context, WidgetRef ref) async {
    final hasPermission = await LocationPermissionsHandler().checkPermission();
    print("hasPermission:$hasPermission");
    if(hasPermission){// 権限があればそのまま。無ければリクエストダイアログを表示。
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return AlertDialog(
          title: Text("パーミッション設定"),
          content: Text("位置情報へのアクセスが許可されていません。設定変更後アプリを再起動してください。"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: (){LocationPermissionsHandler().requestPermission();},
            ),
            TextButton(
              child: Text("設定画面へ"),
              onPressed: (){openAppSettings();},
            ),
          ],
        );
      },
    );
  }
}
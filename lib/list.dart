import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_time_recorder/app_localizations.dart';
import 'package:work_time_recorder/record.dart';

class ListPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).appTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_month),
              onPressed: (){},
            )
          ],
        ),
        body: Consumer(
          builder: (context, ref, child,){
            final _recordListProvider = ref.watch(recordListProvider);
            final _recordList = _recordListProvider.hasValue ? ref.read(recordListProvider).value!.recordList : [];
            return ListView.builder(
              itemCount: _recordList.length,
              itemBuilder: (context, index){
                return _buildListItem(ref, _recordList[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListItem(WidgetRef ref, Record _record){
    return Card(
      child: Column(
        children: [
          ListTile(// 出勤記録
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue),
              ),
              child: Text("出"),
            ),
            title: _record.time_in != null ? Text("${_record.time_in}") : Text("未打刻"),
            subtitle: _record.time_in != null ? Text("${_record.address_in}") : Text("未打刻"),
          ),
          ListTile(// 退勤記録
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: Text("退"),
            ),
            title: _record.time_out != null ? Text("${_record.time_out}") : Text("未打刻"),
            subtitle: _record.time_out != null ? Text("${_record.address_out}") : Text("未打刻"),
          ),
          Container(
            alignment: Alignment.bottomRight,
            child: TextButton(
              child: Text("詳細"),
              onPressed: (){ref.read(recordListProvider.notifier).selectRecord(_record);},
            ),
          ),
        ],
      ),
    );
  }
}
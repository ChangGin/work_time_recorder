import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:work_time_recorder/app_localizations.dart';
import 'package:work_time_recorder/record.dart';

class ShowRecordDetail extends ConsumerWidget{
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
            return Column(
              children: [
                Card(
                  child: Column(
                    children: [

                    ],
                  ),
                ),
                Card(

                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
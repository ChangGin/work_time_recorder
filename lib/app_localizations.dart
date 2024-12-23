import 'package:flutter/material.dart';

class AppLocalizations{

  final Messages messages;
  AppLocalizations(Locale locale): this.messages = Messages.of(locale);
  static Messages of(BuildContext context)
  {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!.messages;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>//サポートしている言語かどうかを返す
    {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ["en", "ja", "ko",].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class Messages{
  Messages({
    required this.appTitle,
    required this.setting,


    /////////////Setting///////////////
    required this.help,
    required this.inquiry,
    required this.privacyPolicy,

    /////////////Hint///////////////
    required this.originTextHint,
    required this.translatedTextHint,

    /////////////Dialog///////////////
    required this.deleteHistoryDialog,
    required this.deleteHistoryDialogTitle,
    required this.deleteAllHistoriesDialog,
    required this.deleteAllHistoriesDialogTitle,

    /////////////msg///////////////

  });

  final String appTitle;
  final String setting;


  /////////////Setting///////////////
  final String help;
  final String inquiry;
  final String privacyPolicy;

  /////////////Hint///////////////
  final String originTextHint;
  final String translatedTextHint;

  /////////////Dialog///////////////
  final String deleteHistoryDialogTitle;
  final String deleteHistoryDialog;
  final String deleteAllHistoriesDialogTitle;
  final String deleteAllHistoriesDialog;

  /////////////msg///////////////



  factory Messages.of(Locale locale)
  {
    switch (locale.languageCode) {
      case "en":
        return Messages.en();
      case "ja":
        return Messages.ja();
      case "ko":
        return Messages.ko();
      default:
        return Messages.en();
    }
  }

  factory Messages.ja() => Messages(
    appTitle: "労働時間レコーダー",
    setting: "設定",

    help: "ヘルプ",
    inquiry: "お問い合わせ",
    privacyPolicy: "プライバシーポリシー",

    /////////////Hint///////////////
    originTextHint: "翻訳したい文章を入力してください",
    translatedTextHint: "翻訳後のテキストが表示されます",

    /////////////Dialog///////////////
    deleteHistoryDialogTitle: "翻訳履歴消去",
    deleteHistoryDialog: "以下の翻訳履歴を消去しますか？" ,
    deleteAllHistoriesDialogTitle: "全翻訳履歴消去",
    deleteAllHistoriesDialog: "全ての翻訳履歴を消去しますか？",

    /////////////msg///////////////


  );

  factory Messages.en() => Messages(
    appTitle: "Working time recorder",
    setting: "設定",

    help: "ヘルプ",
    inquiry: "お問い合わせ",
    privacyPolicy: "プライバシーポリシー",


    /////////////Hint///////////////
    originTextHint: "翻訳したい文章を入力",
    translatedTextHint: "翻訳後のテキストが表示されます",



    /////////////Dialog///////////////
    deleteHistoryDialogTitle: "翻訳履歴消去",
    deleteHistoryDialog: "以下の翻訳履歴を消去しますか？" ,
    deleteAllHistoriesDialogTitle: "全翻訳履歴消去",
    deleteAllHistoriesDialog: "全ての翻訳履歴を消去しますか？",

    /////////////msg///////////////


  );

  factory Messages.ko() => Messages(
    appTitle: "労働時間レコーダー",
    setting: "設定",

    help: "ヘルプ",
    inquiry: "お問い合わせ",
    privacyPolicy: "プライバシーポリシー",

    /////////////Hint///////////////
    originTextHint: "翻訳したい文章を入力",
    translatedTextHint: "翻訳後のテキストが表示されます",


    /////////////Dialog///////////////
    deleteHistoryDialogTitle: "翻訳履歴消去",
    deleteHistoryDialog: "以下の翻訳履歴を消去しますか？" ,
    deleteAllHistoriesDialogTitle: "全翻訳履歴消去",
    deleteAllHistoriesDialog: "全ての翻訳履歴を消去しますか？",

    /////////////msg///////////////


  );

}
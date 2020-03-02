import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/service/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class AccountManage extends StatelessWidget {
  AccountManage(this.api, this.store);

  final Api api;
  final AccountStore store;

  final TextEditingController _passCtrl = new TextEditingController();

  void _onDeleteAccount(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;
    final Map<String, String> accDic = I18n.of(context).account;

    Future<void> onOk() async {
      var res = await api.checkAccountPassword(_passCtrl.text);
      if (res == null) {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(dic['pass.error']),
              content: Text(dic['pass.error.txt']),
              actions: <Widget>[
                CupertinoButton(
                  child: Text(I18n.of(context).home['ok']),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      } else {
        store.removeAccount(store.currentAccount);
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(dic['delete.confirm']),
          content: Padding(
            padding: EdgeInsets.only(top: 16),
            child: CupertinoTextField(
              placeholder: dic['pass.old'],
              controller: _passCtrl,
              onChanged: (v) {
                return Fmt.checkPassword(v.trim())
                    ? null
                    : accDic['create.password.error'];
              },
              obscureText: true,
            ),
          ),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['cancel']),
              onPressed: () {
                Navigator.of(context).pop();
                _passCtrl.clear();
              },
            ),
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: onOk,
            ),
          ],
        );
      },
    );
  }

  void _onExportKeystore(BuildContext context) {
    var dic = I18n.of(context).profile;
    Clipboard.setData(ClipboardData(
      text: jsonEncode(AccountData.toJson(store.currentAccount)),
    ));
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(dic['export']),
          content: Text(dic['export.ok']),
          actions: <Widget>[
            CupertinoButton(
              child: Text(I18n.of(context).home['ok']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> dic = I18n.of(context).profile;

    return Observer(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(dic['account']),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Colors.pink,
                    padding: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: Container(
                        width: 72,
                        height: 72,
                        child: Image.asset(
                            'assets/images/assets/Assets_nav_0.png'),
                      ),
                      title: Text(store.currentAccount.name ?? 'name',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      subtitle: Text(
                        Fmt.address(store.currentAddress) ?? '',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ),
                  ),
                  Container(padding: EdgeInsets.only(top: 16)),
                  ListTile(
                    title: Text(dic['name.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.pushNamed(context, '/profile/name'),
                  ),
                  ListTile(
                    title: Text(dic['pass.change']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () =>
                        Navigator.pushNamed(context, '/profile/password'),
                  ),
                  ListTile(
                    title: Text(dic['export']),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => _onExportKeystore(context),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    textColor: Colors.pink,
                    child: Text(dic['delete']),
                    onPressed: () => _onDeleteAccount(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

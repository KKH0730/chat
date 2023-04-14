import 'package:chat/AppColors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController idTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    idTextController.text = 'test_id1';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          '로그인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),
            _idTextFiredWidget(idTextController),
            const SizedBox(height: 20),
            _passwordTextFiredWidget(passwordTextController),
            const SizedBox(height: 50),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  color: AppColors.color_79ECE9E9,
                  borderRadius: BorderRadius.circular(50.0),
                  border: Border.all(color: AppColors.color_A3E5E5E8)
              ),
              child: CupertinoButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    String id = idTextController.text.trim();
                    String password = passwordTextController.text.trim();
                    if (id.isNotEmpty) {
                      if ((id == 'test_id1' && password == '1234') ||
                          (id == 'test_id2' && password == '1234') ||
                          (id == 'test_id3' && password == '1234')   ) {
                        prefs.then((prefs) {
                          if (id == 'test_id1') {
                            prefs.setString('myName', '마리집사');
                            prefs.setString('myProfileUri',
                                'https://search.pstatic.net/common/?src=http%3A%2F%2Fblogfiles.naver.net%2FMjAyMjEyMjZfNjQg%2FMDAxNjcyMDYwODAyMjY3.r03IsCV9Lph9oh2Qk7-t9PoHjWLIAku0d5ByIApqYrgg.PPTwT3TnXlUDsA6no7kVFD4hlpQZaKQK09niW8lkonog.JPEG.alrud4430%2F1672060717954.jpg&type=a340');
                            prefs.setString('myUid', 'sIBodRy6FjMnEdTF3pz8Xs9Q7Th2');
                          } else if(id == 'test_id2') {
                            prefs.setString('myName', '예티집사');
                            prefs.setString('myProfileUri',
                                'https://search.pstatic.net/sunny/?src=https%3A%2F%2Fi.pinimg.com%2Foriginals%2F21%2Ff9%2F83%2F21f98377d0d9f9efc27dfc19323d2c95.jpg&type=sc960_832');
                            prefs.setString('myUid', 'kQ81x3QrrHQOToARYRcXmMFxVYy1');
                          } else if(id == 'test_id3') {
                            prefs.setString('myName', '길냥이');
                            prefs.setString('myProfileUri',
                                'https://t1.daumcdn.net/cfile/tistory/991011345DA7108009');
                            prefs.setString('myUid', '3oC5Sq8BmLeWa1FqAjOqQriWUKq1');
                          } else  {
                            prefs.setString('myName', '');
                            prefs.setString('myProfileUri', '');
                            prefs.setString('myUid', '');
                          }

                          Navigator.pushNamed(context, '/HomeScreen', arguments: idTextController.text);
                        });
                      }
                    }
                  },
                  child: const Text(
                    '로그인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                  )
              ),
            ),
            Expanded(child: Container(height: 0)),
          ],
        ),
      )
    );
  }

  Widget _idTextFiredWidget(TextEditingController textEditingController) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: CupertinoTextField(
          cursorColor: AppColors.color_FF4A58E8,
          controller: textEditingController,
          placeholder: '아이디',
          padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 50),
          style: const TextStyle(fontSize: 14),
          decoration: BoxDecoration(
              color: AppColors.color_79ECE9E9,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: AppColors.color_5FE5E5E5)
          ),
          onChanged: (value) {
            setState(() {
              textEditingController.selection =
                  TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
            });
          },
          onSubmitted: (value) {}
      ),
    );
  }

  Widget _passwordTextFiredWidget(TextEditingController textEditingController) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: CupertinoTextField(
          cursorColor: AppColors.color_FF4A58E8,
          controller: textEditingController,
          placeholder: '패스워드',
          padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 50),
          style: const TextStyle(fontSize: 14),
          obscureText: true,
          decoration: BoxDecoration(
              color: AppColors.color_79ECE9E9,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: AppColors.color_5FE5E5E5)),
          onChanged: (value) {
            setState(() {
              textEditingController.selection =
                  TextSelection.fromPosition(TextPosition(offset: textEditingController.text.length));
            });
          },
          onSubmitted: (value) {}
      ),
    );
  }
}
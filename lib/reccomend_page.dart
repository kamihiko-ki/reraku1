import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intern_task_recommend_app/question_page.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage(
      {Key? key, required this.painPart, required this.tiredPoint})
      : super(key: key);
  final String painPart;
  final double tiredPoint;

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  // snackBar関数
  void snackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('エラーが発生しました。もう一度お試しください。'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<Map?> coureseDate() async {
    try {
      Response response = await Dio().post(
        'https://17q704uif3.execute-api.ap-northeast-1.amazonaws.com/recommend_course/recommend_courese',
        data: {
          "painPart": widget.painPart,
          "tiredPoint": widget.tiredPoint.toInt(),
        },
        options: Options(
          headers: {
            "x-api-key": "2FVBf65ZKe8SlAVuMsYQT7FI2CE8KYiN4ldJ6OA4",
          },
        ),
      );
      print(response.data['statusCode']);
      if (response.data['statusCode'] == 200) {
        Map<String, dynamic> mapData = jsonDecode(response.data['body']);
        print(mapData);
        return mapData['course'];
      } else if (response.data['statusCode'] == 500) {
        snackBar();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuestionPage()),
        );
      }
    } on DioError catch (e) {
      snackBar();
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuestionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オススメのコース'),
        centerTitle: false,
      ),
      body: FutureBuilder<Map?>(
          future: coureseDate(),
          builder: (BuildContext context, AsyncSnapshot<Map?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: const CircularProgressIndicator(
                  color: Colors.green,
                ),
              );
            } else if (snapshot.hasError) {
              const Text('エラーが発生しました。もう一度お試しください。');
            } else if (!snapshot.hasData) {
              const Text('エラーが発生しました。もう一度お試しください。');
            }
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    '${snapshot.data!['name']}',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${snapshot.data!['courseExplanation']}',
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                  Center(
                    child: Image.network(
                      '${snapshot.data!['imageUrl']}',
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://reraku.jp/course ',
                        );
                        if (await canLaunchUrl(url)) {
                          launchUrl(url);
                        }
                      },
                      child: const Text('予約する', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            );
          }),
    );
  }
}

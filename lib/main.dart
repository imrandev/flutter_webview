import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );
  await Permission.storage.request();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  InAppWebViewController webView;

  final String url = "https://corporate3.bdjobs.com/AttachedCVDownload_api.asp?Name=Tasnim Haque&CVFormat=.pdf&ViewInfo=0&EncrpID=a3c4c2[2`8`4b45&DownloadType=vresume&jobid=964778&applyid=208240611&comid=35450";
  // final String url = "https://file-examples-com.github.io/uploads/2017/10/file-sample_150kB.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: _buttonView(),
      ),
    );
  }

  Widget _buttonView() => Center(
    child: ElevatedButton.icon(
      label: Text(
        "Download CV",
      ),
      icon: Icon(
        Icons.download_outlined,
      ),
      onPressed: () async {
        if (await ChromeSafariBrowser.isAvailable()){
          ChromeSafariBrowser().open(
            headersFallback: {
              "HTTP_X_REQUESTED_WITH" : "com.bdjobs.recruiter",
            },
            url: url,
          );
        } else {
          InAppBrowser.openWithSystemBrowser(url: url,);
        }
      },
    ),
  );

  Widget _inAppWebView() => InAppWebView(
    initialUrl: url,
    initialOptions: InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        debuggingEnabled: true,
        useOnDownloadStart: true,
      ),
    ),
    initialHeaders: {
      "HTTP_X_REQUESTED_WITH" : "com.bdjobs.recruiter",
    },
    onDownloadStart: (controller, url) async {
      print("onDownloadStart $url");
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: "${await getFilePath()}",
        showNotification: true,
        openFileFromNotification: true,
      );
    },
  );

  Future<String> getFilePath() async {
    Directory directory;
    if(Platform.isIOS){
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getExternalStorageDirectory();
    }
    final String dirPath = '${directory.path}/FlutterDocs';
    await new Directory(dirPath).create(recursive: true);
    return dirPath;
  }

  Map<String, dynamic> _getHeaders(String companyCode, String companyId, String apiAuth, String companyCreation, String loginId) {
    return {
      HttpHeaders.contentTypeHeader: NetworkConfiguration.HEADER_KEY_CONTENT_TYPE,
      NetworkConfiguration.HEADER_KEY_X_API_COMPANY_CODE: companyCode,
      NetworkConfiguration.HEADER_KEY_X_API_COMPANY_ID: companyId,
      NetworkConfiguration.HEADER_KEY_X_API_AUTH: apiAuth,
      NetworkConfiguration.HEADER_KEY_X_API_COMPANY_CREATION: companyCreation,
      NetworkConfiguration.HEADER_KEY_X_API_LOGIN_ID: loginId,
    };
  }
}

class NetworkConfiguration {
  static const String HEADER_KEY_CONTENT_TYPE = "application/x-www-form-urlencoded";
  static const String HEADER_KEY_X_API_AUTH = "X_API_AUTH";
  static const String HEADER_KEY_X_API_COMPANY_ID = "X_API_COMPANY_ID";
  static const String HEADER_KEY_X_API_COMPANY_CREATION = "X_API_COMPANY_CREATION";
  static const String HEADER_KEY_X_API_LOGIN_ID = "X_API_LOGIN_ID";
  static const String HEADER_KEY_X_API_COMPANY_CODE = "X_API_COMPANY_CODE";
}

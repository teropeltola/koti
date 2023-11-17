import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../look_and_feel.dart';
import '../ouman_device.dart';

const String networkServiceProblemInfo = 'Emme saa yhteyttä oumaniin, joten tätä palvelua ei voi käyttää.';

const oumanUrl = 'http://192.168.72.99';

class OumanExplorer extends StatelessWidget {
  const OumanExplorer({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
            onWebResourceError: (WebResourceError error) async {
              await informMatterToUser(context, networkServiceProblemInfo,
                  'Voit muuten käyttää appia!');
              Navigator.of(context).pop();
            }
        ),
      )
      ..loadRequest(Uri.parse(oumanUrl));
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ouman'),
      ),// new line
      body: WebViewWidget( controller: controller ),
    );
  }
}

class OumanView extends StatelessWidget {
  const OumanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MyOumanApp extends StatelessWidget {
  const MyOumanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? scrapedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML Page Scraper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Scraped Data:'),
            Text(
              scrapedData ?? 'No data available',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: () async {
                const url = oumanUrl;
                final data1 = await loginOuman(url);
                final data2 = await scrapeHtmlContent(url);
                setState(() {
                  scrapedData = data2;
                });
              },
              child: const Text('Scrape HTML Page'),
            ),
          ],
        ),
      ),
    );
  }
}


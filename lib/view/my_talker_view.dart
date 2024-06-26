
import 'package:flutter/material.dart';

import 'package:talker_flutter/talker_flutter.dart';

import '../look_and_feel.dart';

TalkerScreenTheme _myTalkerScreenTheme = const TalkerScreenTheme(
  backgroundColor: Colors.grey,
  textColor: Colors.blue,
  cardColor: Colors.white
);

class MyTalkerView extends StatefulWidget {
  const MyTalkerView({
    Key? key,
    required this.talker,
  }) : super(key: key);

  final Talker talker;

  @override
  State<MyTalkerView> createState() => _MyTalkerViewState();
}

class _MyTalkerViewState extends State<MyTalkerView> {
  @override
  void initState() {
    final talker = widget.talker;
    /*
    talker.info('Renew token from expire date');
    _handleException();
    talker.warning('Cache images working slowly on this platform');
    talker.log('Server exception', logLevel: LogLevel.critical);
    talker.debug('Exception data sent for your analytics server');
    talker.verbose(
      'Start reloading config after critical server exception',
    );
    talker.info('3.............');
    talker.info('2.......');
    talker.info('1');
    talker.good('Now you can check all Talkler power ⚡');

     */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talker Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
            icon: const Icon(Icons.arrow_back),
        tooltip: 'Palaa takaisin',
        onPressed: () {
          Navigator.pop(context);
        }),
        title: appTitle('Loki')
          ),
          body: TalkerScreen(
              talker: widget.talker,
              theme: _myTalkerScreenTheme,
              appBarTitle: 'loki',
              appBarLeading: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'Palaa takaisin',
                  onPressed: ()  {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  }),
          ),
        );
      }),
    );
  }
}
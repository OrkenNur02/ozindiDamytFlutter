import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ozindi_damyt/drawer/drawer.dart';
import 'package:ozindi_damyt/screens/podcast/podcast_card.dart';
import 'package:ozindi_damyt/screens/podcast/podcastdb.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/widgets.dart';

class PodcastPage extends StatefulWidget {
  final String dbName;

  const PodcastPage({Key key, this.dbName}) : super(key: key);
  @override
  _PodcastPageState createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  final podcasts = <PodcastDb>[];
  List<PodcastDb> _podcastListNew;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  StreamSubscription<Event> _onPodcastAddedSubscription;
  StreamSubscription<Event> _onPodcastChangedSubscription;
  Query _podcastQuery;

  @override
  void initState() {
    super.initState();

    _podcastListNew = new List();
    _podcastQuery = _database.reference().child("podcasts");

    _onPodcastAddedSubscription =
        _podcastQuery.onChildAdded.listen(onEntryAdded);
    _onPodcastChangedSubscription =
        _podcastQuery.onChildChanged.listen(onEntryChanged);
  }

  onEntryAdded(Event event) {
    setState(() {
      _podcastListNew.add(PodcastDb.fromSnapshot(event.snapshot));
    });
  }

  onEntryChanged(Event event) {
    print('onEntryChanged');

    var oldEntry = _podcastListNew.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _podcastListNew[_podcastListNew.indexOf(oldEntry)] =
          PodcastDb.fromSnapshot(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      drawer: DrawerMenu(),
      appBar: AppBar(
        title: Text("Подкаст"),
        actions: [
          /*
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              tooltip: 'search',
              onPressed: () {}),
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {},
            tooltip: 'tune Icon',
          )
          */
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 15, bottom: 10, left: 20, right: 20),
            child:
            PodcastCard(),
          ),
          Expanded(
            child: Container(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: MediaQuery.of(context).size.height / 1200,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 3),
                  // shrinkWrap: true,
                  // scrollDirection: Axis.vertical,
                  itemCount: _podcastListNew.length,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                  itemBuilder: (context, i) {
                    return podcastItem(context, _podcastListNew[i]);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  Widget podcastItem(BuildContext context, PodcastDb podcastDb) {
    return GestureDetector(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 12,
              ),
            ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                podcastDb.photo,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 8,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: 02),
              child: Text(
                podcastDb.topic,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              podcastDb.title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ),
        ],
      ),
      onTap: () async {
        final url = podcastDb.link;
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
    );
  }
}

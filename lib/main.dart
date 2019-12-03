import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gridview_ex/image_detail.dart';
import 'package:gridview_ex/providers/pixabay_photos.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (_) => PixabayPhotos(),
      child: MaterialApp(
        title: 'GridView Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // bool _isInit = true;
  int page = 1;
  List<PixabayPhotoItem> photos = [];
  var pixabayProvider;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      pixabayProvider = Provider.of<PixabayPhotos>(context);
      await pixabayProvider.getPixabayPhotos(page, 20);
      photos = pixabayProvider.photos;
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'Fail to fetch images from pixabay, check your url or try later!'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() => _loading = true);

  //     Provider.of<PixabayPhotos>(
  //       context,
  //       listen: false,
  //     ).getPixabayPhotos(page, 30).then((_) async {
  //       setState(() => _loading = false);
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text('GridView Demo'),
      ),
      body: SafeArea(
        child: pixabayProvider == null
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      pixabayProvider.toggleView(photos[index].id);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) {
                          return ImageDetail(photos[index]);
                        }),
                      );
                    },
                    child: GridTile(
                      child: FadeInImage(
                        placeholder:
                            AssetImage('assets/images/placeholder.png'),
                        image: NetworkImage(photos[index].webformatURL),
                        fit: BoxFit.cover,
                      ),
                      footer: GridTileBar(
                        backgroundColor: photos[index].viewed
                            ? Colors.blue[300]
                            : Colors.black54,
                        title: Text(photos[index].user),
                        subtitle: Text(
                          'views: ${photos[index].views}, favs: ${photos[index].favorites}',
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          page++;

          pixabayProvider = Provider.of<PixabayPhotos>(context);
          await pixabayProvider.getPixabayPhotos(page, 20);
          photos = pixabayProvider.photos;
        },
        tooltip: 'Get more images',
        child: Icon(Icons.add),
      ),
    );
  }
}

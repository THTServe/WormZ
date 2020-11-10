import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:wormz/utilities/constants.dart';

class PolicyDialog extends StatelessWidget {
  final Key key;
  final String mdFileName;
  final double radius;
  PolicyDialog({@required this.mdFileName, this.key, this.radius = 18.0})
      : assert(mdFileName.contains('.md')),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
              child: Container(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 150)).then((value) {
                return rootBundle.loadString('assets/$mdFileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                width: 100.0,
                height: 25.0,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'CLOSE',
                      style: TextStyle(
                        color: kTextWht,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}

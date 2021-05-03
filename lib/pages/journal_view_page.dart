import 'package:flutter/material.dart';
import 'package:timelist_journal/model/journal.dart';
import '../utils/date_helper.dart';
import 'package:intl/intl.dart';

// Journal View Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class JournalView extends StatefulWidget {
  final Journal journal;

  JournalView({Key key, @required this.journal});

  @override
  _JournalViewState createState() => _JournalViewState(journal: this.journal);
}

class _JournalViewState extends State<JournalView> {

  final Journal journal;
  List<TextEditingController> _controllers = [];

  _JournalViewState({@required this.journal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal for ' + DateFormat('M/d/yyyy').format(journal.date)),
        actions: [],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text("View Journal", style: Theme.of(context).textTheme.headline4,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(journal.date) +
                    " (" + journal.date.toWeekdayString() + ")",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Record what happened today to remember it later",
            style: Theme.of(context).textTheme.bodyText1,
            textAlign: TextAlign.center,
          ),
          Text(
            "(Even the little things matter!)",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: journal.items.length,
                itemBuilder: (_, index) {
                  // Load item text
                  _controllers.add(new TextEditingController());
                  _controllers[index].text = journal.items[index].text;
                  // Create item entry in the list
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(25.0, 0.0, 25.0, 0.0),
                    child: Row(
                      children: [
                        Text('\u2022'), // Bullet-point!
                        Expanded(
                          child: TextField(
                            controller: _controllers[index],
                            minLines: 1,
                            maxLines: 4,
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 0),
                              hintText: "Enter a memory here..."
                            ),
                          )
                        ),
                      ],
                    ),
                  );
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0),
            child: Row(
              children: [
                RaisedButton(
                  child: Text("Save Changes", style: Theme.of(context).accentTextTheme.button),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    updateItems();
                    // Go back to home page to save the updated Journal
                    Navigator.of(context).pop(journal);
                  },
                ),
                Expanded(child: Text("")), // Empty horizontal spacer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: UniqueKey(),
                      child: Icon(Icons.remove),
                      mini: true,
                      backgroundColor: Theme.of(context).accentColor,
                      onPressed: () {
                        if (journal.items.length > 0)
                          setState(() {
                            journal.items.removeLast();
                            _controllers.removeLast();
                            updateItems();
                          });
                      },
                    ),
                    FloatingActionButton(
                      heroTag: UniqueKey(),
                      child: Icon(Icons.add),
                      mini: true,
                      backgroundColor: Theme.of(context).accentColor,
                      onPressed: () {
                        setState(() {
                          updateItems();
                          journal.items.add(new Item(text: ""));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateItems() {
    // Update the local Journal's Item list
    journal.items = _controllers.map((controller) {
      return new Item(text: controller.text);
    }).toList();
    // Reset the controller list (regenerated automatically)
    _controllers = [];
  }
}

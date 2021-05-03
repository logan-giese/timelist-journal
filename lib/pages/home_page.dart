import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timelist_journal/pages/export_page.dart';
import 'package:timelist_journal/pages/rewind_page.dart';
import '../utils/date_helper.dart';
import '../model/journal.dart';
import '../services/service_controller.dart';
import 'journal_view_page.dart';
import 'opening_page.dart';

// Home Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Journal> journals = [];
  Journal todayJournal;

  @override
  void initState() {
    super.initState();
    _getJournals();
  }

  // Initialize the database connection and get the stored journals for the last month
  Future<void> _getJournals() async {
    DateTime now = DateTime.now();
    ServiceController.getJournals(DateTime.now().subtract(new Duration(days: 31)), now).then((value) {
      if (value.length > 0)
        setState(() {
          // Save retrieved list of journals
          journals = value;
          // Find today's journal if it exists
          todayJournal = journals.firstWhere((e) => e.date.isSameDate(now), orElse: () => null);
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Text("Timelist Journal", style: Theme.of(context).textTheme.headline3),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text('View Today', style: TextStyle(
                    color: Theme.of(context).accentTextTheme.button.color,
                    fontSize: 19.0,
                  )),
                  onPressed: () async {
                    // Create a journal for today if it doesn't exist
                    if (todayJournal == null) {
                      await ServiceController.addJournal(DateTime.now())
                        .then((newJournal) {
                          // Save the new journal in the app
                          setState(() {
                            todayJournal = newJournal;
                            journals.add(newJournal);
                          });
                        });
                    }
                    viewJournal(todayJournal, context);
                  },
                  color: Theme.of(context).accentColor,
                ),
                SizedBox(width: 20),
                RaisedButton(
                  child: Text('Rewind', style: TextStyle(
                    color: Theme.of(context).accentTextTheme.button.color,
                    fontSize: 19.0,
                  )),
                  onPressed: () {
                    // Go to the rewind page
                    Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => RewindPage()))
                      .then((result) {
                        // If we got a list of Journals back, update the local copy where they overlap
                        if (result != null && result.length > 0) {
                          journals = journals.map((e) {
                            Journal match = result.firstWhere((r) => r.id == e.id, orElse: () => null);
                            return match ?? e;
                          }).toList();
                        }
                      });
                  },
                  color: Theme.of(context).accentColor,
                ),
              ],
            ),
            SizedBox(height: 15),
            Divider(key: UniqueKey(), thickness: 1, indent: 20, endIndent: 20,),
            SizedBox(height: 15),
            Text('Recent Journals:', style: TextStyle(
              color: Theme.of(context).textTheme.headline5.color,
              fontSize: Theme.of(context).textTheme.headline5.fontSize,
              fontStyle: FontStyle.italic
            )),
            Expanded(
              child: ListView.builder(
                itemCount: journals.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text(
                      DateFormat('M/d/yyyy').format(journals[journals.length-1-index].date) +
                          " (" + journals[journals.length-1-index].date.toWeekdayString() + ")",
                      style: Theme.of(context).textTheme.bodyText2
                    ),
                    trailing: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text("View", style: Theme.of(context).accentTextTheme.button),
                      onPressed: () {
                        // Open the view page for the journal
                        viewJournal(journals[journals.length-1-index], context);
                      },
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),

      appBar: AppBar(
        title: Text('Home'),
        actions: [],
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 15),
              Text("Options:"),
              SizedBox(height: 8),
              Divider(key: UniqueKey(), thickness: 1, indent: 15, endIndent: 15,),
              ListTile(
                title: Text('Log out', style: Theme.of(context).textTheme.subtitle1),
                trailing: Icon(Icons.lock_outline, color: Theme.of(context).textTheme.subtitle1.color,),
                onTap: () async {
                  await ServiceController.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => OpeningPage()),
                      (route) => false);
                },
              ),
              ListTile(
                title: Text('Export data', style: Theme.of(context).textTheme.subtitle1),
                trailing: Icon(Icons.download_outlined, color: Theme.of(context).textTheme.subtitle1.color,),
                onTap: () {
                  Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => ExportPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // View a particular journal in the JournalView page (context is only for snackbars)
  void viewJournal(Journal journal, BuildContext context) {
    // Make a backup copy of the journal's items
    List<Item> backupList = journal.items.map((e) => e).toList();

    // Go to the journal view page
    Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) =>
        JournalView(
          journal: journal
        )))
        .then((result) {
          // If we got a Journal back, update it in the DB
          if (result != null)
            updateJournal(result, context);
          // Otherwise, return the Journal to its previous state
          else
            journal.items = backupList;
        });
  }

  // Update the journal in the DB after receiving it back from another page (context is for snackbar)
  void updateJournal(Journal journal, BuildContext context) async {
    // Clean the items list to remove empty entries
    journal.items.removeWhere((e) => e.text == "");

    await ServiceController.updateJournal(journal).then((_) {
      setState(() {
        // Update the local list of journals
        int index = journals.indexWhere((e) => e.id == journal.id);
        journals.removeAt(index);
        journals.insert(index, journal);
      });
      // Show a snackbar notification
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Journal updated')));
    });
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:timelist_journal/services/service_controller.dart';
import '../utils/date_helper.dart';
import 'package:timelist_journal/model/journal.dart';
import 'journal_view_page.dart';

// Rewind (Search) Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class RewindPage extends StatefulWidget {
  @override
  _RewindPageState createState() => _RewindPageState();
}

class _RewindPageState extends State<RewindPage> {

  DateTime searchDate;
  List<Journal> searchJournals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rewind / Search'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          // Send back the local journal list (which may have been modified vs. home's list)
          onPressed: () => Navigator.of(context).pop(searchJournals),
        ),
        actions: [],
      ),

      body: Builder(
        builder: (BuildContext context) => Column(
          children: [
            SizedBox(height: 15.0),
            Container(
              width: 300.0,
              child: Text(
                "Return to a previous time and see what happened:",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              )
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: Text(
                    searchDate == null ? "Select Month" : DateFormat.yMMMM().format(searchDate),
                    style: TextStyle(
                      color: Theme.of(context).accentTextTheme.button.color,
                      fontSize: 20.0
                    )
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () => showMonthPicker(context)
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(key: UniqueKey(), thickness: 1, indent: 15, endIndent: 15,),
            SizedBox(height: 8.0),
            Text('Journals from chosen month:', style: TextStyle(
                color: Theme.of(context).textTheme.headline6.color,
                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                fontStyle: FontStyle.italic
            )),
            Expanded(
              child: ListView.builder(
                  itemCount: searchJournals.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text(
                          DateFormat('M/d/yyyy').format(searchJournals[index].date) +
                              " (" + searchJournals[index].date.toWeekdayString() + ")",
                          style: Theme.of(context).textTheme.bodyText2
                      ),
                      trailing: RaisedButton(
                        color: Theme.of(context).accentColor,
                        child: Text("View", style: Theme.of(context).accentTextTheme.button),
                        onPressed: () {
                          // Open the view page for the journal
                          viewJournal(searchJournals[index], context);
                        },
                      ),
                    );
                  }
              ),
            ),
            Divider(key: UniqueKey(), thickness: 1, indent: 15, endIndent: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Return to a specific day: "),
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text("Select Day", style: Theme.of(context).accentTextTheme.button),
                  onPressed: () => showDayPicker(context),
                )
              ],
            ),
            SizedBox(height: 5.0)
          ],
        ),
      ),
    );
  }

  void showMonthPicker(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
          type: 11,
          yearBegin: 2000,
          yearEnd: DateTime.now().year,
          value: searchDate ?? null
        ),
        hideHeader: true,
        title: Text("Rewind to this month:", style: TextStyle(color: Theme.of(context).accentColor)),
        selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
        cancelTextStyle: TextStyle(color: Theme.of(context).accentColor),
        confirmTextStyle: TextStyle(color: Theme.of(context).accentColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            searchDate = new DateTime(2000 + value[0], value[1] + 1); // Year, Month, Day

            // Retrieve the journals for the chosen month
            ServiceController.getJournals(searchDate, searchDate.add(Duration(days: 31))).then((value) {
              if (value.length > 0)
                setState(() {
                  // Save retrieved list of journals
                  searchJournals = value;
                  // Remove accidental entries from another month (happens if search month has less than 31 days)
                  searchJournals.removeWhere((e) => e.date.month != searchDate.month);
                });
              else
                setState(() {
                  // Reset the search list if nothing was found for the chosen month
                  searchJournals = [];
                });
            });
          });
        }
    ).showDialog(context);
  }

  void showDayPicker(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
            type: 0,
            yearBegin: 2000,
            yearEnd: DateTime.now().year
        ),
        hideHeader: true,
        title: Text("Rewind to this day:", style: TextStyle(color: Theme.of(context).accentColor)),
        selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
        cancelTextStyle: TextStyle(color: Theme.of(context).accentColor),
        confirmTextStyle: TextStyle(color: Theme.of(context).accentColor),
        onConfirm: (Picker picker, List value) async {
          // Get chosen day as a DateTime
          DateTime day = new DateTime(2000 + value[2], value[0] + 1, value[1] + 1); // Year, Month, Day

          // Attempt to get the chosen day
          await ServiceController.getJournals(DateTime(day.year, day.month, day.day), DateTime(day.year, day.month, day.day+1)).then((value) async {
            Journal selectedJournal;

            // Create a journal for the chosen day if it doesn't exist
            if (value.length < 1)
              await ServiceController.addJournal(day).then((newJournal) {
                selectedJournal = newJournal;
              });
            else
              selectedJournal = value[0];

            // Add the selected journal to the local search list (if applicable)
            if (selectedJournal.date.month == searchDate?.month) // In search month?
              if (!searchJournals.any((j) => j.id == selectedJournal.id)) // Not already in search list?
                setState(() {
                  searchJournals.add(selectedJournal);
                  searchJournals.sort((a, b) => a.date.compareTo(b.date));
                });

            // View the selected journal
            viewJournal(selectedJournal, context);
          });
        }
    ).showDialog(context);
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
        int index = searchJournals.indexWhere((e) => e.id == journal.id);
        if (index >= 0) {
          searchJournals.removeAt(index);
          searchJournals.insert(index, journal);
        }
      });
      // Show a snackbar notification
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Journal updated')));
    });
  }
}

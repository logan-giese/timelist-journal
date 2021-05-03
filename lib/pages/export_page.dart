import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import '../services/file_services.dart';
import '../utils/date_helper.dart';
import '../model/journal.dart';
import '../services/service_controller.dart';

// Data Export Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {

  DateTime startDate;
  DateTime endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Export'),
        actions: [],
      ),

      body: Builder(
        builder: (BuildContext context) => Column(
          children: [
            SizedBox(height: 50.0),
            Container(
              width: 250.0,
              child: Text(
                "Choose the time range you want to save:",
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              )
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    child: Text(
                        startDate == null ? "Start Date" : DateFormat.yMMMd().format(startDate),
                        style: TextStyle(
                            color: Theme.of(context).accentTextTheme.button.color,
                            fontSize: 19.0
                        )
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () => showStartPicker(context)
                ),
                SizedBox(width: 15.0),
                Text("to", style: Theme.of(context).textTheme.headline5,),
                SizedBox(width: 15.0),
                RaisedButton(
                    child: Text(
                        endDate == null ? "End Date" : DateFormat.yMMMd().format(endDate),
                        style: TextStyle(
                            color: Theme.of(context).accentTextTheme.button.color,
                            fontSize: 19.0
                        )
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: () => showEndPicker(context)
                )
              ],
            ),
            SizedBox(height: 15.0),
            Divider(key: UniqueKey(), thickness: 1, indent: 45, endIndent: 45,),
            SizedBox(height: 15.0),
            RaisedButton(
              child: Text(
                  "Export Journals",
                  style: TextStyle(
                      color: Theme.of(context).accentTextTheme.button.color,
                      fontSize: 20.0
                  )
              ),
              color: Theme.of(context).accentColor,
              onPressed: () => exportJournals(context)
            ),
          ],
        ),
      ),
    );
  }

  void showStartPicker(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
            yearBegin: 2000,
            yearEnd: DateTime.now().year,
            value: startDate ?? null
        ),
        hideHeader: true,
        title: Text("Select Start Date", style: TextStyle(color: Theme.of(context).accentColor)),
        selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
        cancelTextStyle: TextStyle(color: Theme.of(context).accentColor),
        confirmTextStyle: TextStyle(color: Theme.of(context).accentColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            startDate = new DateTime(2000 + value[2], value[0] + 1, value[1] + 1); // Year, Month, Day
          });
        }
    ).showDialog(context);
  }

  void showEndPicker(BuildContext context) {
    Picker(
        adapter: DateTimePickerAdapter(
            yearBegin: 2000,
            yearEnd: DateTime.now().year,
            minValue: startDate ?? null,
            value: endDate ?? (startDate ?? null)
        ),
        hideHeader: true,
        title: Text("Select End Date", style: TextStyle(color: Theme.of(context).accentColor)),
        selectedTextStyle: TextStyle(color: Theme.of(context).accentColor),
        cancelTextStyle: TextStyle(color: Theme.of(context).accentColor),
        confirmTextStyle: TextStyle(color: Theme.of(context).accentColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            endDate = new DateTime((startDate?.year ?? 2000) + value[2], value[0] + 1, value[1] + 1); // Year, Month, Day
          });
        }
    ).showDialog(context);
  }

  // Retrieve data for the selected date range and generate a shareable text file
  void exportJournals(context) async {
    if (startDate == null)
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Error: No start date selected")));
    else {
      // Default to ending at today
      if (endDate == null)
        setState(() {
          endDate = DateTime.now();
        });

      // Get the journal data
      List<Journal> data;
      await ServiceController.getJournals(startDate, endDate.add(Duration(days: 1))).then((value) {
        data = value;
      });

      // Stringify the data
      String dataText = "== Exported Journals from "+
          DateFormat("M-d-yyyy").format(startDate)+
          " to "+
          DateFormat("M-d-yyyy").format(endDate)+
          " ==\n\n";
      data.forEach((journal) {
        // Header
        dataText += DateFormat("M/d/yyyy").format(journal.date) +
            " (" +
            journal.date.toWeekdayString() +
            ")\n";
        // Items
        journal.items.forEach((item) {
          dataText += " - " + item.text + "\n";
        });
        dataText += "\n";
      });

      // Generate a text file for the data
      String fileLocation = "/Exported Journals ("+
          DateFormat("M-d-yyyy").format(startDate)+
          " to "+
          DateFormat("M-d-yyyy").format(endDate)+
          ").txt";
      await FileServices.deleteFile(fileLocation); // Clear any existing file
      await FileServices.writeString(fileLocation, dataText); // Write the data

      // Open a share dialog for the generated file
      Share.shareFiles([(await FileServices.getFile(fileLocation)).path]);

      // Show a snackbar notification
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Journals exported")));
    }
  }
}

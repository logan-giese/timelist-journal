import 'package:flutter/foundation.dart';

// Journal Object
// Part of TIMELIST JOURNAL (by Logan Giese)

// Journal object containing favorite info, date, and a list of Items
class Journal implements Comparable {
  final String id;
  bool isFavorite;
  DateTime _date;
  List<Item> items;

  DateTime get date => _date;

  Journal({
    @required this.id,
    this.isFavorite = false,
    date,
    this.items
  }) {
    // If date is null, assign it the value of now
    _date = date ?? DateTime.now();
  }

  @override
  int compareTo(other) {
    // Compare by date
    if (other is Journal) {
      return date.compareTo(other.date);
    }
    return -1;
  }

  // Convert the items in this journal into a mapped list
  List<Map> getMappedItems() {
    List<Map> mappedItems = [];
    items.forEach((item) {
      mappedItems.add({
        'text': item.text
      });
    });
    return mappedItems;
  }

  // Convert a mapped list into a list of items
  static List<Item> convertItemMap(List mappedItems) {
    List<Item> itemList = [];
    mappedItems.forEach((value) {
      itemList.add(new Item(
          text: value['text'] ?? ""
      ));
    });
    return itemList;
  }
}

// Item object containing text for a single bullet-point in a Journal
class Item {
  String text;

  Item({
    this.text = ''
  });
}

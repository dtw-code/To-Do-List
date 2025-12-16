import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; //for uuid
import 'package:intl/intl.dart'; //for date formatting'
final uuid=Uuid();
final formatter = DateFormat('dd/MM/yy');
enum Category{food,travel,leisure,work}
const categoryicons={  //like a map (key:value) pairs used for icon selection
  Category.food:Icons.lunch_dining,
  Category.travel:Icons.flight_takeoff,
  Category.leisure:Icons.movie,
  Category.work:Icons.work
};

class Expense{
  Expense(
  {required this.title,
  required this.amount,
  required this.date,
  required this.category,
    required this.id
   })  ;    //:id=uuid.v4(); attaching this will give automatic uid


  final String title;
  final double amount;
  final DateTime date;
  final String id;
  final Category category;

  String get formattedDate{  //get method is used for functions which dont take any input but return a value
      return formatter.format(date);
  }
}

class ExpenseBucket{
  ExpenseBucket({required this.category,required this.expenses});
  ExpenseBucket.forCategory(List<Expense> allExpenses,this.category)
     :expenses=allExpenses.where((expense) => expense.category==category).toList();


  final Category category;
  final List<Expense> expenses;
  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
    }
  }



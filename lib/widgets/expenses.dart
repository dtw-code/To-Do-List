import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';

class Expenses extends StatefulWidget{
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}


class _ExpensesState extends State<Expenses>{

  //creating dummy data
  final List<Expense> _registeredExpense=[
    Expense(title: 'Flutter Course', amount: 19.99, date: DateTime.now(),category: Category.work),
    Expense(title: 'Cinema', amount: 15.69, date: DateTime.now(),category: Category.leisure),
  ];

  void _openAddExpenseOverlay(){
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
        builder:(ctx)=>NewExpense(addExpense:addExpense),
    );
  }

  void addExpense(Expense expence){
    setState(() {
      _registeredExpense.add(expence);
    });
  }

  void removeExpense(Expense expense){        //used to remove expense from registered expense while sliding
    final expenseIndex=_registeredExpense.indexOf(expense);
    setState(() {
      _registeredExpense.remove(expense);
    });


    ScaffoldMessenger.of(context).showSnackBar(    //used to display undo popup in the lower side of the screen
        SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text('Expense Deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: (){    //this works when the label ('undo') is pressed
              setState(() {
                _registeredExpense.insert(expenseIndex, expense);   //brings back the 'expense' which was deleted from the list to the index from which it was deleted
              });
            },
          )
         ),);

  }

  @override
  Widget build(BuildContext context) {

    final width=MediaQuery.of(context).size.width;    //this is used to get the width of the screen by using the metadatas from 'context'.We are using this to make our app responsive


    Widget maincontent=const Center(child: Text('No Expense Found..Start adding some'),);

    if(_registeredExpense.isNotEmpty){
      maincontent=ExpenseList(expenses:_registeredExpense,removeExpense:removeExpense);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Expense Tracker'),
        centerTitle: true,
        actions: [
          IconButton(  //used to add a clickable + icon to the app bar
              onPressed:_openAddExpenseOverlay,   //() are not being used
              icon:const Icon(Icons.add),
          )
        ],
      ),
      body:
      width<600?   //ternary operator to check the height and make the screen responsive
      Column(
        children: [
          Chart(expenses:_registeredExpense),
          const SizedBox(height: 20),
          Expanded(child: maincontent), //Expanded gived ListView.builder a finite scrollable place inside the column widget.By default it wants infinite length to scroll which is why expanded allows it to use full length of column
        ],
      ):
       Row(
        children: [
          Expanded(child: Chart(expenses:_registeredExpense)),
          Expanded(child: maincontent),
        ],
       )
    );
  }
}

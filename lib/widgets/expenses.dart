import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_list.dart';
import 'package:expense_tracker/new_expense.dart';
import 'package:expense_tracker/widgets/chart/chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Expenses extends StatefulWidget{
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}


class _ExpensesState extends State<Expenses>{

  //creating dummy data
  final List<Expense> _registeredExpense=[];
  var isloading=true;
   double _total=0;

  Future<void> _openAddExpenseOverlay() async{
    final created=await showModalBottomSheet<Expense>(
      isScrollControlled: true,
      context: context,
        builder:(ctx)=>NewExpense(),
    );
    if(created==null){
      return;
    }
    if (!mounted) return;
    setState(() {
      _registeredExpense.add(created);
      _registeredExpense.sort((a, b) => a.date.compareTo(b.date));  // newest first
      _total=_registeredExpense.fold(0, (sum, item) => sum + item.amount);
    });
  }
void initState(){
    super.initState();
    _loadExpenses();
}

  Future<void> _loadExpenses() async {
    final url = Uri.https(
      'flutter-proj-5756e-default-rtdb.europe-west1.firebasedatabase.app',
      'expense-tracker.json',
    );
    final response = await http.get(url);
    if(response.body=='null'){
      if (!mounted) return;
      setState(() {
        isloading=false;
      });
      return;
    }
    final Map<String, dynamic> expenseData = json.decode(response.body);
    final List<Expense> _loadedExpenses = [];
    for(final expense in expenseData.entries){
      _loadedExpenses.add(Expense(
        id: expense.key,
        title: expense.value['title'],
        amount: expense.value['amount'],
        date: DateTime.parse(expense.value['date']),
        category: Category.values.firstWhere((category) => category.name == expense.value['category']),

      ));
    }
    setState(() {
      _registeredExpense.addAll(_loadedExpenses);
      _registeredExpense.sort((a, b) => a.date.compareTo(b.date));  // newest first
      _total=_registeredExpense.fold(0, (sum, item) => sum + item.amount);
      isloading=false;
    });

  }



  void removeExpense(Expense expense) async{        //used to remove expense from registered expense while sliding
    final expenseIndex=_registeredExpense.indexOf(expense);
    final url = Uri.https(
      'flutter-proj-5756e-default-rtdb.europe-west1.firebasedatabase.app',
      'expense-tracker/${expense.id}.json',    //this helps in deleting the particular id
    );
    final response =await http.delete(url);
    setState(() {
      _registeredExpense.remove(expense);
      _total=_registeredExpense.fold(0, (sum, item) => sum - item.amount);
    });
    if(response.statusCode>=400){
      setState(() {
        _registeredExpense.insert(expenseIndex, expense);
      });
    }


    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(    //used to display undo popup in the lower side of the screen
        SnackBar(
          duration: const Duration(seconds: 3),
          content: const Text('Expense Deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async{    //this works when the label ('undo') is pressed
              setState(() {
                _registeredExpense.insert(expenseIndex, expense);   //brings back the 'expense' which was deleted from the list to the index from which it was deleted
                _total=_registeredExpense.fold(0, (sum, item) => sum + item.amount);
              });
              final putUrl = Uri.https(
                'flutter-proj-5756e-default-rtdb.europe-west1.firebasedatabase.app',
                'expense-tracker/${expense.id}.json',
              );
              try {
                await http.put(
                  putUrl,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'title': expense.title,
                    'amount': expense.amount,
                    'date': expense.date.toIso8601String(),
                    'category': expense.category.name,
                  }),
                );
              } catch (_) {
                // If PUT fails, we keep local state; you can show a toast if you like.
              }
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

    if(isloading){
      return const Center(child: CircularProgressIndicator());
    }

    Widget totalexpense(){
      return Container(
        margin: const EdgeInsets.fromLTRB(16,2,16,16),
        padding: const EdgeInsets.fromLTRB(16,12,16,12),
        alignment: Alignment.center,
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Theme.of(context).colorScheme.background.withOpacity(0.4),
            Theme.of(context).colorScheme.background.withOpacity(0.9),
          ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
          ),
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Final Expense:${_total.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color:Theme.of(context).colorScheme.onBackground ,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
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
              //total expense is displayed on top

          Chart(expenses:_registeredExpense),

          // const SizedBox(height:2),
          // const SizedBox(height: 10),
          Expanded(child: maincontent), //Expanded gived ListView.builder a finite scrollable place inside the column widget.By default it wants infinite length to scroll which is why expanded allows it to use full length of column
          totalexpense(),

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

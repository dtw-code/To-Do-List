//used to create a scrollable list of expenses
import 'package:flutter/material.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/widgets/expenses_item.dart';

class ExpenseList extends StatelessWidget{
  ExpenseList({super.key,required this.expenses,required this.removeExpense});

  final List<Expense> expenses;
  final void Function(Expense expense) removeExpense;


  @override
  Widget build(BuildContext context) {

    return ListView.builder(  //list view builder is a widget that is used to build a scrollable list of widgets( all of them dont get triggered at once)
      itemCount: expenses.length, //listview.builder has two paramtereS(currently):item.count tells how many items are to be displayed in the list eventually
      itemBuilder: (ctx,index){   //returns the item (it iterates over every item in the list)
        return Dismissible(   //this will help in swipe to delete
          key:ValueKey(expenses[index].id),//unique identifieer to delete elements, here we are using indx of each expense

          background: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.60),
            margin: EdgeInsets.fromLTRB(16, 8, 16, 6),
          ),

          onDismissed:(direction){
            removeExpense(expenses[index]);   //we cant directly use removeExpense because here direction of wipe is also playing a role
        },

          child: ExpenseItem(expenses[index]),
        );

      }
    );
  }
}
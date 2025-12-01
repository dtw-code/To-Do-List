//used to create a card for each expense and return it to the expense_list
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class ExpenseItem extends StatelessWidget{
  const ExpenseItem(this.expense,{super.key});
  final Expense expense;
  @override
  Widget build(BuildContext context) {
    return Card(child:Padding(  //padding was added so that there is a padding between text and the card
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 16),  //adds padding to left & right as well as top and bottom
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text(expense.title),
            const SizedBox(height: 4),
            Row(
              children:[
                Text('Rs ${expense.amount.toStringAsFixed(2)}'),  //toStringAsFixed rounds off the decimal to two places and converts it to string
                Spacer(), //this widget takes up all the remaining space between the two children of the row/column and hence the row (next widget) will show up at the extreme end of the outer row
                Row(    //we want to display date and category together as a row, present in the same row as amount but spaced
                  children:[
                    Icon(categoryicons[expense.category]), //categoryicons is a map(key-value pair) which is defined in expense.dart/model. to access each element of the icon we refer to it as name ex. categoryicons[travel], categoryicons[food]
                    SizedBox(width: 8),
                    Text(expense.formattedDate)  // () are not used in formattedDate becz it is not a function but rather a getter method( used more like a variable but works like a function)
                  ]
                )
              ]
            )
          ]
        )
    )
    );

  }
}
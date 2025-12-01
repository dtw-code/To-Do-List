
//overlay section for adding new expenses
import 'dart:io';   //to check for platform
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget{
  const NewExpense({super.key,required this.addExpense});
  final void Function(Expense expense) addExpense;
  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }

}

class _NewExpenseState extends State<NewExpense>{
  final _titlecontroller=TextEditingController(); //helps us take in text input,read any changes in text input etc
  final _amountcontroller=TextEditingController();
  DateTime? _selectedDate;  //initially set to null which is why '?' sign is used
  Category _selectedcategory=Category.leisure;

  void _presentdatepicker() async{   //used to manage date from calendar icon
    final now=DateTime.now();
    final _pickdate=await showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(now.year-1,now.month,now.day),   //creates a DateTime Object for 1 year before the current date
        lastDate: DateTime.now()
    );
    setState(() {
        _selectedDate=_pickdate;
    });
  }

  void dispose(){//it is always essenial to dispose of the controller when it is no longer needed also dispose() can only be used in stateful widget
    _titlecontroller.dispose();
    _amountcontroller.dispose();
    super.dispose();
  }

  void _showDialog(){
    if(Platform.isIOS) {   //error popup for ios(optional, we can use the same popup for both ios and android)
      showCupertinoDialog(context: context, builder: (ctx) =>
          CupertinoAlertDialog( //error dialog for ios devices
            content: Text(
                'Please make sure a valid title,amount,date and category was entered'),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(ctx);
              },
                  child: Text('Okay')
              )
            ],
          ));
    }
    else {
      showDialog(context: context, builder: (ctx) =>
          AlertDialog(
            title: Text('Invalid Input'),
            content: Text(
                'Please make sure a valid title,amount,date and category was entered'),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(ctx);
              },
                  child: Text('Okay')
              )
            ],
          ),);
    }//it is like a popup
  }

  void _submitExpenseData() {
    final enteredAmount=double.tryParse(_amountcontroller.text);  //tryparse('hello')=>null or tryparse('123')=>123
    final amountIsInvalid=enteredAmount==null || enteredAmount<=0;
    if(_titlecontroller.text.trim().isEmpty || amountIsInvalid || _selectedDate==null) { //.trim is used to remove and leading or trailing spaces
    _showDialog();
    return;
    }
      //else condition
      widget.addExpense(Expense(
      title: _titlecontroller.text,
      amount: enteredAmount,
      date: _selectedDate!,
      category: _selectedcategory
  ));
  Navigator.pop(context);  //removes the overlay
  }


  @override
  Widget build(BuildContext context) {

    final keyboardSpace=MediaQuery.of(context).viewInsets.bottom;   //viewInsets is used to check the amount of ui space which is getting overlapped from the bottom  (here to check ui eleemnts getting overlapped by the keyboard)

    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(      //this makes it scrollable and helps in situation such as landscape mode
        child: Padding(
          padding: EdgeInsets.fromLTRB(16,48,16,keyboardSpace+16),
          child: Column(
            children: [
              TextField(
                controller: _titlecontroller,
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Title'),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountcontroller,
                      maxLength: 5,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rs ',
                        label: Text('Amount'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.end, //pushing the contents(icon and text) of the row to the end
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(_selectedDate==null?'No date selected':formatter.format(_selectedDate!)),    //formatter.format is imported from expense.dart/model.dart it is used to display date in readable fashion
                      IconButton(onPressed: _presentdatepicker, icon: const Icon(Icons.calendar_month)),
                    ],
                  )
                  )

                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  DropdownButton(              //three paramters here:value,items,onChanged
                      value: _selectedcategory,  //shows currently selected item in the dropdown
                      items: Category.values.map(   //values access each value of the enum category(food,travel,leisure,work)
                          (category)=>DropdownMenuItem(
                            value: category,
                            child:Text(category.name.toUpperCase()),
                          ),
                      ).toList(),   //displays each category as a dropdown item

                      onChanged: (value){
                        if(value==null){  //iff value is not selected then skips the function(return)
                          return;
                        }
                        setState(() {
                          _selectedcategory=value;
                        });
                      }),
                  const Spacer(),   //flexible sized gap. SizedBox is a fixed size gap
                  TextButton(onPressed: (){
                    Navigator.pop(context);   //removes the overlay
                  },
                      child: Text('Cancel')
                  ),


                 ElevatedButton(onPressed:_submitExpenseData,
                     child: Text('Save Expense')
                 )
              ]
              ),




            ]
          )
        ),
      ),
    );
  }
  }


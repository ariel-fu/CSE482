import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:odk_remake/models/FormQuestionFormat.dart';
import 'package:odk_remake/models/excel_file.dart'; // Import ExcelFile
import 'package:flutter/cupertino.dart';
import 'package:odk_remake/screens/SavedExcelScreen.dart';

import 'package:odk_remake/services/parseData.dart';
import 'package:survey_kit/survey_kit.dart' as survey_kit;
import 'package:survey_kit/src/steps/step.dart' as surveystep;

class Form extends StatefulWidget {
  final ExcelFile excelFile; // Add this

  const Form({Key? key, required this.excelFile})
      : super(key: key); // Modify this

  // This widget is the root of your application.
  @override
  State<Form> createState() => FormPageState();
}

class FormPageState extends State<Form> {
  bool readExcel = false;
  // Order is automatically maintained
  static Map<String, FormQuestionFormat> formFormats = {};
  List<int> surveySteps = [];
  Map<String, String> surveyResponse = {};
  String surveyResultsText = '';
  static bool isDraft = false;
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};
  int surveyIndex = 0;
  bool isFinished = false;
  static Map<String, FormQuestionFormat> getFormFormats() {
    return formFormats;
  }

  @override
  Widget build(BuildContext context) {
    print("here!!");
    // for each valid form format, create the widget
    if (!readExcel) {
      formFormats =
          parseQuestionFormatData(widget.excelFile.path); // Modify this
      readExcel = true;
    }

    List<FormQuestionFormat> questions = [];
    for (FormQuestionFormat fQf in formFormats.values) {
      questions.add(fQf);
    }

    var question;
    if (currentQuestionIndex < questions.length) {
      question = questions[currentQuestionIndex];
    }

    // Calculate the progress
    double progress = (currentQuestionIndex + 1) / questions.length;

    bool isRelevant = true;
    if (question != null && question.relevant != "null") {
      // determine whether we should render the question
      List<String> operation = parseOperation(question.relevant);
      String parameter = parseRelevantParameter(operation[0]);
      isRelevant = determineRelevancy(parameter, operation[1], operation[2]);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add the progress bar at the top of the column
            LinearProgressIndicator(
              value: progress,
              semanticsLabel: 'Survey progress',
            ),
            if (!isFinished && isRelevant) ...[
              Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20), // Add horizontal padding
                child: Center(child: Text(question.label)),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20), // Add horizontal padding
                child: Center(child: _getQuestionInput(question)),
              ),
            ],

            if (isFinished) ...[
              ListView.builder(
                shrinkWrap: true,
                itemCount: formFormats.length,
                itemBuilder: (context, index) {
                  if (index >= surveySteps.length) {
                    return Container();
                  }
                  int questionIndex = surveySteps.elementAt(index);
                  String key = questions.elementAt(questionIndex).name;
                  print(key);
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20), // Add horizontal padding
                    child: Card(
                      child: ListTile(
                        title: Padding(
                            padding:
                                EdgeInsets.all(8), // Add horizontal padding
                            child: Text(formFormats[key]!.label,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold))),
                        subtitle: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20), // Add horizontal padding
                          child: Text(answers[key].toString()),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Center the buttons
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Add your save as draft functionality here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SavedExcelScreen(),
                              settings: RouteSettings(arguments: {
                                'isDraft': true,
                                'surveyResponses': answers
                              })));
                    },
                    child: Text('Save as Draft'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Add your send form functionality here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SavedExcelScreen(),
                              settings: RouteSettings(arguments: {
                                'isDraft': false,
                                'surveyResponses': answers
                              })));
                    },
                    child: Text('Send Form'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
      floatingActionButton: isFinished
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "backButton",
                  child: Icon(Icons.arrow_back),
                  onPressed: isFinished
                      ? null
                      : () {
                          if (currentQuestionIndex > 0) {
                            setState(() {
                              surveyIndex--;
                              currentQuestionIndex =
                                  surveySteps.elementAt(surveyIndex);
                              // remove all elements in front
                              surveySteps.removeRange(
                                  surveyIndex + 1, surveySteps.length);
                            });
                          }
                        },
                ),
                SizedBox(width: 10), // Add some space between the buttons
                FloatingActionButton(
                  heroTag: "nextButton",
                  child: Icon(Icons.arrow_forward),
                  onPressed: isFinished
                      ? null
                      : () {
                          surveySteps.add(currentQuestionIndex);
                          surveyIndex++;
                          if (currentQuestionIndex < questions.length - 1) {
                            setState(() {
                              do {
                                currentQuestionIndex++;
                                question = questions[currentQuestionIndex];
                                isRelevant = true;
                                if (question.relevant != "null") {
                                  // determine whether we should render the question
                                  List<String> operation =
                                      parseOperation(question.relevant);
                                  String parameter =
                                      parseRelevantParameter(operation[0]);
                                  isRelevant = determineRelevancy(
                                      parameter, operation[1], operation[2]);
                                }
                              } while (!isRelevant &&
                                  currentQuestionIndex < questions.length);
                            });
                          } else {
                            setState(() {
                              currentQuestionIndex++;
                              print(answers); // Print the answers when done
                              isFinished = true;
                            });
                          }
                        },
                ),
              ],
            ),
    );
  }

  Widget _getQuestionInput(FormQuestionFormat question) {
    switch (question.questionType) {
      case QuestionType.Text:
        return _buildTextInput(question.name);
      case QuestionType.Email:
        return _buildTextInput(question.name);
      case QuestionType.Note:
        return _buildTextInput(question.name);
      case QuestionType.Integer:
        return _buildTextInput(question.name);
      case QuestionType.Numeric:
        return _buildTextInput(question.name);
      case QuestionType.Date:
        return _buildDateInput(question.name);
      case QuestionType.Time:
        return _buildTimeInput(question.name);
      case QuestionType.SelectOne:
        return _buildSingleChoiceInput(question.name, question.answerChoices);
      case QuestionType.SelectMultiple:
        return _buildMultiChoiceInput(question.name, question.answerChoices);
      case QuestionType.LikertScale:
        return _buildSingleChoiceInput(question.name, question.answerChoices);

      // Handle other question types...
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildTextInput(String name) {
    return Center(
        child: TextField(
      key: ValueKey(name), // Provide a unique Key
      onChanged: (value) {
        answers[name] = value;
      },
    ));
  }

  DateTime? selectedDate;
  Widget _buildDateInput(String name) {
    return ElevatedButton(
      key: ValueKey(name), // Provide a unique Key
      child: Text('Select a date'),
      onPressed: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2050),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          setState(() {
            answers[name] = pickedDate;
          });
        }
      },
    );
  }

  TimeOfDay? selectedTime;
  Widget _buildTimeInput(String name) {
    return ElevatedButton(
      key: ValueKey(name), // Provide a unique Key

      child: Text('Select a time'),
      onPressed: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null && pickedTime != selectedTime) {
          setState(() {
            answers[name] = pickedTime;
          });
        }
      },
    );
  }

  String? selectedChoice;
  Widget _buildSingleChoiceInput(String name, List<String> choices) {
    return Center(
        child: SizedBox(
      width: 500,
      child: ListView.builder(
        shrinkWrap: true,
        key: ValueKey(name), // Provide a unique Key
        itemCount: choices.length,
        itemBuilder: (context, index) {
          return RadioListTile<String>(
            title: Text(choices[index]),
            value: choices[index],
            groupValue: selectedChoice,
            onChanged: (String? value) {
              setState(() {
                answers[name] = value;
                selectedChoice = value;
                print(answers);
              });
            },
          );
        },
      ),
    ));
  }

  Map<String, bool> values = {};
  Widget _buildMultiChoiceInput(String name, List<String> choices) {
    List<String> selectedChoices = [];

    for (String choice in choices) {
      if (values[choice] == null) {
        values[choice] = false;
      }
    }
    print("before $values");
    return Column(
      children: choices.map((choice) {
        return CheckboxListTile(
          title: Text(choice),
          value: values[choice],
          onChanged: (bool? value) {
            setState(() {
              print("$choice = $value");
              values[choice] = value!;
              if (values[choice] == true) {
                selectedChoices.add(choice);
              } else {
                selectedChoices.remove(choice);
              }
              print("values: $values");
              answers[name] = selectedChoices;
              print(answers);
            });
          },
        );
      }).toList(),
    );
  }

  String parseRelevantParameter(String input) {
    RegExp exp = RegExp(r'\{(.*?)\}');
    var matches = exp.allMatches(input);
    String result = '';
    for (var match in matches) {
      result += match.group(1)!; // group(0) is the full match including '{}'
    }

    return result;
  }

  List<String> parseOperation(String input) {
    RegExp exp = RegExp(r'(.*?)\s(>|<|>=|<=|=)\s(.*)');
    var match = exp.firstMatch(input);

    List<String> resultingOperation = [];
    if (match != null) {
      resultingOperation.add(match.group(1).toString());
      resultingOperation.add(match.group(2).toString());
      resultingOperation.add(match.group(3).toString());
    }

    return resultingOperation;
  }

  bool determineRelevancy(String parameter, String operator, String compareTo) {
    FormQuestionFormat? formQuestionFormat = formFormats[parameter];
    if (formQuestionFormat == null) {
      print("$parameter is not part of a valid questipon");
      return false;
    }

    if (answers[parameter] == null) {
      print("$parameter has no result");
      return false;
    }
    QuestionType questionType = formQuestionFormat.questionType;

    switch (questionType) {
      case QuestionType.Text:
        // Handle text question
        String result = answers[parameter];
        print('Text question $result');
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
      case QuestionType.Email:
        // Handle email question
        String result = answers[parameter];
        print('email question $result');
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.Note:
        // Handle note question
        String result = answers[parameter];
        print('Note question $result');
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.Integer:
        // Handle integer question
        int result = int.parse(answers[parameter]);
        int numCompareTo = int.parse(compareTo);
        print('Integer question $result');
        switch (operator) {
          case '>':
            return result > numCompareTo;
          case '<':
            return result < numCompareTo;
          case '>=':
            return result >= numCompareTo;
          case '<=':
            return result <= numCompareTo;
          case '=':
            return result == numCompareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.Numeric:
        // Handle numeric question
        double result = double.parse(answers[parameter]);
        double numCompareTo = double.parse(compareTo);

        print('Numeric question $result');
        switch (operator) {
          case '>':
            print("res ${result > numCompareTo}");
            return result > numCompareTo;
          case '<':
            return result < numCompareTo;
          case '>=':
            return result >= numCompareTo;
          case '<=':
            return result <= numCompareTo;
          case '=':
            return result == numCompareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.Date:
        // Handle date question
        DateTime result = answers[parameter];
        DateTime dateCompareTo = DateTime.parse(compareTo);
        print('Date question $result');
        switch (operator) {
          case '>':
            return result.isAfter(dateCompareTo);
          case '<':
            return result.isBefore(dateCompareTo);
          case '>=':
            return result.isAfter(dateCompareTo) || result == dateCompareTo;
          case '<=':
            return result.isBefore(dateCompareTo) || result == dateCompareTo;
          case '=':
            return result == dateCompareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
      case QuestionType.Time:
        // Handle time question
        TimeOfDay todResult = answers[parameter];
        final format = DateFormat.jm();
        TimeOfDay todTimeCompareTo =
            TimeOfDay.fromDateTime(format.parse(compareTo));

        DateTime result = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, todResult.hour, todResult.minute);
        DateTime dateCompareTo = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            todTimeCompareTo.hour,
            todTimeCompareTo.minute);

        print('Date question $result');
        switch (operator) {
          case '>':
            return result.isAfter(dateCompareTo);
          case '<':
            return result.isBefore(dateCompareTo);
          case '>=':
            return result.isAfter(dateCompareTo) || result == dateCompareTo;
          case '<=':
            return result.isBefore(dateCompareTo) || result == dateCompareTo;
          case '=':
            return result == dateCompareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
      case QuestionType.SelectOne:
        // Handle select one question
        String result = answers[parameter];
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.LikertScale:
        // Handle Likert scale question
        String result = answers[parameter];
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.SelectMultiple:
        // Handle select multiple question
        List<String> results = answers[parameter];
        // TODO not sure how to deal with this vcase yet
        return true;
        break;
      default:
        // Handle other question types
        print('Other question type');
        break;
    }

    return true;
  }
}

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odk_remake/theme/theme_constants.dart';
import 'package:odk_remake/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:odk_remake/models/FormQuestionFormat.dart';
import 'package:odk_remake/models/excel_file.dart'; // Import ExcelFile
import 'package:flutter/cupertino.dart';
import 'package:odk_remake/screens/SavedExcelScreen.dart';

import 'package:odk_remake/services/parseData.dart';
// import 'package:survey_kit/survey_kit.dart' as survey_kit;
// import 'package:survey_kit/src/steps/step.dart' as surveystep;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class Form extends StatefulWidget {
  final ExcelFile excelFile; // Add this
  final Map<String, dynamic> answers;

  const Form(
      {super.key,
      required this.excelFile,
      required this.answers}); // Modify this

  // This widget is the root of your application.
  @override
  State<Form> createState() => FormPageState();
}

class FormPageState extends State<Form> {
  bool readExcel = false;
  // Order is automatically maintained
  static Map<String, FormQuestionFormat> formFormats = {};
  List<int> surveySteps = [];
  Map<String, dynamic> surveyResponse = {};
  String surveyResultsText = '';
  // static bool isDraft =
  int currentQuestionIndex = 0;
  // Map<String, dynamic> answers = {};
  int surveyIndex = 0;
  bool isFinished = false;
  static Map<String, FormQuestionFormat> getFormFormats() {
    return formFormats;
  }

  @override
  Widget build(BuildContext context) {
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

    if (!surveySteps.contains(currentQuestionIndex)) {
      surveySteps.add(currentQuestionIndex);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey'),
      ),
      body: Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Add the progress bar at the top of the column
              LinearProgressIndicator(
                value: progress,
                semanticsLabel: 'Survey progress',
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).brightness == Brightness.dark
                      ? COLOR_PRIMARY_DARK
                      : COLOR_PRIMARY_LIGHT,
                ),
              ),
              if (!isFinished && isRelevant) ...[
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20), // Add horizontal padding
                  child: Center(child: Text(question.label ?? '')),
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
                    if (questionIndex >= questions.length) {
                      return Container();
                    }
                    String key = questions.elementAt(questionIndex).name;
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

                            child: Text(
                              widget.answers[key].toString().startsWith("[") &&
                                      widget.answers[key]
                                          .toString()
                                          .endsWith("]")
                                  ? widget.answers[key].toString().substring(1,
                                      widget.answers[key].toString().length - 1)
                                  : widget.answers[key].toString(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Center the buttons
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        // Add your save as draft functionality here

                        await handleFormSubmit("draft");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SavedExcelScreen(),
                                settings: RouteSettings(arguments: {
                                  'isDraft': true,
                                  'surveyResponses': widget.answers
                                })));
                      },
                      child: Text('Save as Draft'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Add your send form functionality here
                        await handleFormSubmit("completed");

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SavedExcelScreen(),
                                settings: RouteSettings(arguments: {
                                  'isDraft': false,
                                  'surveyResponses': widget.answers
                                })));
                      },
                      child: Text('Mark Form Completed'),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
                              currentQuestionIndex =
                                  surveySteps.elementAt(surveySteps.length - 2);

                              surveySteps.removeAt(surveySteps.length - 1);
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
        return _buildNumericInput(question.name);
      case QuestionType.Numeric:
        return _buildNumericInput(question.name);
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
    TextEditingController controller =
        TextEditingController(text: widget.answers[name]);

    return Center(
      child: TextField(
        key: ValueKey(name),
        controller: controller,
        onChanged: (value) {
          widget.answers[name] = value;
        },
      ),
    );
  }

  // Same as text input but makes sure it's a number and not letters
  Widget _buildNumericInput(String name) {
    TextEditingController controller =
        TextEditingController(text: widget.answers[name]);

    return Center(
      child: TextField(
        key: ValueKey(name),
        controller: controller,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
        onChanged: (value) {
          widget.answers[name] = value;
        },
      ),
    );
  }

  DateTime? selectedDate;
  Widget _buildDateInput(String name) {
    selectedDate = widget.answers[name] != null
        ? DateTime.tryParse(widget.answers[name])
        : null;

    return ElevatedButton(
      key: ValueKey(name),
      child: Text('Select a date'),
      onPressed: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2050),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
            widget.answers[name] = pickedDate.toString();
          });
        }
      },
    );
  }

  TimeOfDay? selectedTime;
  Widget _buildTimeInput(String name) {
    // Remove "TimeOfDay(" from the beginning and ")" from the end

    // Split the remaining string into hours and minutes
    if (widget.answers[name] != null) {
      List<String> components = widget.answers[name]
          .replaceAll("TimeOfDay(", "")
          .replaceAll(")", "")
          .split(":");

      selectedTime = TimeOfDay(
          hour: int.parse(components[0]), minute: int.parse(components[1]));
    } else {
      selectedTime = null;
    }

    // Create and return the TimeOfDay object

    return ElevatedButton(
      key: ValueKey(name),
      child: Text('Select a time'),
      onPressed: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null && pickedTime != selectedTime) {
          setState(() {
            selectedTime = pickedTime;
            widget.answers[name] = pickedTime.toString();
          });
        }
      },
    );
  }

  String? selectedChoice;
  Widget _buildSingleChoiceInput(String name, List<String> choices) {
    selectedChoice = widget.answers[name] as String?;
    return Center(
      child: SizedBox(
        width: 500,
        child: ListView.builder(
          shrinkWrap: true,
          key: ValueKey(name),
          itemCount: choices.length,
          itemBuilder: (context, index) {
            return RadioListTile<String>(
              title: Text(choices[index]),
              value: choices[index],
              groupValue: selectedChoice,
              onChanged: (String? value) {
                setState(() {
                  selectedChoice = value;
                  widget.answers[name] = value;
                });
              },
            );
          },
        ),
      ),
    );
  }

  Map<String, bool> values = {};
  Widget _buildMultiChoiceInput(String name, List<String> choices) {
    List<String> selectedChoices = widget.answers[name] as List<String>? ?? [];

    return Column(
      children: choices.map((choice) {
        return Builder(
          builder: (context) {
            return CheckboxListTile(
              title: Text(choice),
              value: selectedChoices.contains(choice),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedChoices.add(choice);
                  } else {
                    selectedChoices.remove(choice);
                  }
                  widget.answers[name] = selectedChoices;
                });
              },
              selectedTileColor:
                  Provider.of<ThemeManager>(context).themeMode == ThemeMode.dark
                      ? COLOR_PRIMARY_DARK
                      : COLOR_PRIMARY_LIGHT,
            );
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
      return false;
    }

    if (widget.answers[parameter] == null) {
      return false;
    }
    QuestionType questionType = formQuestionFormat.questionType;

    switch (questionType) {
      case QuestionType.Text:
        // Handle text question
        String result = widget.answers[parameter];
        print('Text question $result');
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
      case QuestionType.Email:
        // Handle email question
        String result = widget.answers[parameter];
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
        String result = widget.answers[parameter];
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
        int result = int.parse(widget.answers[parameter]);
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
        double result = double.parse(widget.answers[parameter]);
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
        DateTime result = widget.answers[parameter];
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
        TimeOfDay todResult = widget.answers[parameter];
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
        String result = widget.answers[parameter];
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.LikertScale:
        // Handle Likert scale question
        String result = widget.answers[parameter];
        switch (operator) {
          case '=':
            return result == compareTo;
          default:
            throw FormatException('Unknown operator: $operator');
        }
        break;
      case QuestionType.SelectMultiple:
        // Handle select multiple question
        List<String> results = widget.answers[parameter];
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

  Future<void> handleFormSubmit(String statusType) async {
    TextEditingController textController = TextEditingController();

    Future<String?> showPopupTextBox(BuildContext context) async {
      return await showDialog<String>(
        context: context,
        // barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Survey Name'),
            content: TextField(
              controller: textController,
              decoration: InputDecoration(hintText: 'Enter Survey Name Here'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  List<String> savedFileNames =
                      prefs.getStringList('savedFileNames') ?? [];

                  if (savedFileNames.contains(textController.text) &&
                      widget.excelFile.name == textController.text) {
                    Navigator.of(context).pop(textController.text);
                    // Show an error dialog
                  } else if (savedFileNames.contains(textController.text)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('File name already exists.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (textController.text == "") {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('File name cannot be empty.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.of(context).pop(textController.text);
                  }
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }

    String? enteredText = await showPopupTextBox(context);
    Future<void> saveAnswers(Map<String, dynamic> answers) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setStringList("answers of ${enteredText}",
          widget.answers.entries.map((e) => '${e.key}:${e.value}').toList());
    }

    Future<void> addExcelFile() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String? filePath = widget.excelFile.path;

      String? fileName;
      if (enteredText != null) {
        fileName = enteredText;
      } else {
        return;
      }

      if ((fileName != widget.excelFile.name) || statusType == "completed") {
        try {
          File file = File(filePath);
          // List<int> bytes = await file.readAsBytes();

          // Save the file to app directory
          Directory appDirectory = await getApplicationDocumentsDirectory();
          String savedFilePath = '${appDirectory.path}/$fileName';
          await file.copy(savedFilePath);

          List<String> savedFileNames =
              prefs.getStringList('savedFileNames') ?? [];
          savedFileNames.add(fileName);
          await prefs.setStringList('savedFileNames', savedFileNames);

          await prefs.setString(fileName, statusType);

          if (widget.excelFile.status == "draft") {
            await deleteExcelFile(widget.excelFile);
          }
        } catch (e) {
          print('Error saving file: $e');
        }
      } else {
        print('Error: File name or path are null');
      }
    }

    await addExcelFile();
    await saveAnswers(widget.answers);
  }
}

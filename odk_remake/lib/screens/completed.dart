import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class Completed extends StatefulWidget {
  final ExcelFile excelFile; // Add this
  final Map<String, dynamic> answers;

  const Completed(
      {super.key,
      required this.excelFile,
      required this.answers}); // Modify this

  // This widget is the root of your application.
  @override
  State<Completed> createState() => FormPageState();
}

class FormPageState extends State<Completed> {
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

    bool isRelevant = true;
    if (question != null && question.relevant != "null") {
      // determine whether we should render the question
      List<String> operation = parseOperation(question.relevant);
      String parameter = parseRelevantParameter(operation[0]);
      isRelevant = determineRelevancy(parameter, operation[1], operation[2]);
    }

    while (currentQuestionIndex < questions.length - 1) {
      setState(() {
        do {
          bool isRelevant = true;
          if (question != null && question.relevant != "null") {
            // determine whether we should render the question
            List<String> operation = parseOperation(question.relevant);
            String parameter = parseRelevantParameter(operation[0]);
            isRelevant =
                determineRelevancy(parameter, operation[1], operation[2]);
          }

          if (!surveySteps.contains(currentQuestionIndex) && isRelevant) {
            surveySteps.add(currentQuestionIndex);
          }
          currentQuestionIndex++;
          question = questions[currentQuestionIndex];
          isRelevant = true;
          if (question.relevant != "null") {
            // determine whether we should render the question
            List<String> operation = parseOperation(question.relevant);
            String parameter = parseRelevantParameter(operation[0]);
            isRelevant =
                determineRelevancy(parameter, operation[1], operation[2]);
          }
        } while (!isRelevant && currentQuestionIndex < questions.length);
      });
    }
    currentQuestionIndex++;
    isFinished = true;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.excelFile.name} Survey Answers'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (true) ...[
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

                          child: Text(widget.answers != null &&
                                      widget.answers.containsKey(key)
                                  ? widget.answers[key]
                                              .toString()
                                              .startsWith("[") &&
                                          widget.answers[key]
                                              .toString()
                                              .endsWith("]")
                                      ? widget.answers[key]
                                          .toString()
                                          .substring(
                                              1,
                                              widget.answers[key]
                                                      .toString()
                                                      .length -
                                                  1)
                                      : widget.answers[key].toString()
                                  : 'No answer' // Handle the case when widget.answers is null or key doesn't exist
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 20)),
              if (widget.excelFile.status != "sent" &&
                  widget.excelFile.status != "waiting")
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // Center the buttons
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final result =
                              await InternetAddress.lookup('example.com');
                          if (result.isNotEmpty &&
                              result[0].rawAddress.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Answers successfully sent"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } on SocketException catch (_) {
                          await handleNoWifiFormSubmit();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Answers will be sent once connected to WiFi"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SavedExcelScreen(),
                                settings: RouteSettings(arguments: {
                                  'isDraft': false,
                                  'surveyResponses': widget.answers
                                })));
                        await Firebase.initializeApp();
                        Future<void> sendSurveyAnswers() {
                          Map<String, dynamic> data = {};
                          for (dynamic key in widget.answers.keys) {
                            data[key] = widget.answers[key];
                          }

                          return FirebaseFirestore.instance
                              .collection('completed')
                              .doc(widget.excelFile.name)
                              .set(data);
                        }

                        await sendSurveyAnswers();
                      },
                      child: Text('Send Form'),
                    ),
                  ],
                )
            ]
          ],
        ),
      ),
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

  Future<void> handleNoWifiFormSubmit() async {
    String? enteredText = widget.excelFile.name;

    Future<void> addExcelFile() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String? fileName = widget.excelFile.name;

      await prefs.setString(fileName, "waiting");
      await loadSavedFiles();
      setState(() {});
    }

    await addExcelFile();
  }
}

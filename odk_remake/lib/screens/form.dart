import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  State<Form> createState() => _FormPageState();
}

class _FormPageState extends State<Form> {
  bool readExcel = false;
  // Order is automatically maintained
  Map<String, FormQuestionFormat> formFormats = {};
  List<survey_kit.Step> surveySteps = [];
  Map<String, String> surveyResponse = {};
  String surveyResultsText = '';
  static bool isDraft = false;

  @override
  Widget build(BuildContext context) {
    print("here!!");
    // for each valid form format, create the widget
    if (!readExcel) {
      formFormats =
          parseQuestionFormatData(widget.excelFile.path); // Modify this
      readExcel = true;
    }

    List<survey_kit.Step> steps = [];
    // DUMMY
    survey_kit.Step firstPage = survey_kit.InstructionStep(
      title: 'Welcome to the ${widget.excelFile.name} survey',
      text: 'Ready to get started?',
      buttonText: 'Let\'s go!',
    );
    steps.add(firstPage);
    for (FormQuestionFormat formStep in formFormats.values) {
      steps.add(formStep.generateStep());
    }
    // DUMMY
    survey_kit.Step finalStep = AlternativeCompletionStep(
      stepIdentifier: survey_kit.StepIdentifier(id: '321'),
      text: 'Thanks for taking the survey, we will contact you soon!',
      title: 'Done!',
    );

    steps.add(finalStep);

    survey_kit.SurveyKit survey = buildSurvey(steps);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Start Form"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: buildSurvey(steps),
            )
          ],
        ),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  survey_kit.SurveyKit buildSurvey(List<survey_kit.Step> surveySteps) {
    this.surveySteps = surveySteps;
    return survey_kit.SurveyKit(
      onResult: (survey_kit.SurveyResult result) {
        List<String> resultString = [];
        for (var stepResult in result.results) {
          for (var questionResult in stepResult.results) {
            if (questionResult.result != null && questionResult.result != "") {
              if (questionResult.result is survey_kit.TextChoice) {
                resultString
                    .add((questionResult.result as survey_kit.TextChoice).text);
              } else {
                resultString.add(questionResult.result.toString());
              }
            }
          }
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SavedExcelScreen(),
                settings: RouteSettings(arguments: _FormPageState.isDraft)));
      },
      task: survey_kit.NavigableTask(
          id: survey_kit.TaskIdentifier(), steps: surveySteps),
      showProgress: true,
      localizations: const <String, String>{
        'cancel': 'Cancel',
        'next': 'Next',
      },
      themeData: getSurveyTheme(),
      surveyProgressbarConfiguration: survey_kit.SurveyProgressConfiguration(
        backgroundColor: Colors.white,
      ),
    );
  }

  ThemeData? getSurveyTheme() {
    return Theme.of(context).copyWith(
      primaryColor: Colors.cyan,
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 255, 255, 255),
        iconTheme: IconThemeData(
          color: Colors.cyan,
        ),
        titleTextStyle: TextStyle(
          color: Colors.cyan,
        ),
      ),
      iconTheme: const IconThemeData(
        color: Colors.cyan,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.cyan,
        selectionColor: Colors.cyan,
        selectionHandleColor: Colors.cyan,
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: Colors.cyan,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
            const Size(150.0, 60.0),
          ),
          side: MaterialStateProperty.resolveWith(
            (Set<MaterialState> state) {
              if (state.contains(MaterialState.disabled)) {
                return const BorderSide(
                  color: Colors.grey,
                );
              }
              return const BorderSide(
                color: Colors.cyan,
              );
            },
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          textStyle: MaterialStateProperty.resolveWith(
            (Set<MaterialState> state) {
              if (state.contains(MaterialState.disabled)) {
                return Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey,
                    );
              }
              return Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.cyan,
                  );
            },
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.cyan,
                ),
          ),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 28.0,
          color: Colors.black,
        ),
        displayMedium: TextStyle(
          fontSize: 28.0,
          color: Colors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: 24.0,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          color: Colors.black,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.cyan,
      )
          .copyWith(
            onPrimary: Color.fromARGB(255, 255, 255, 255),
          )
          .copyWith(background: Color.fromARGB(255, 255, 255, 255)),
    );
  }
}

class AlternativeCompletionStep extends survey_kit.Step {
  final String title;
  final String text;
  final String assetPath;

  AlternativeCompletionStep(
      {bool isOptional = false,
      required survey_kit.StepIdentifier stepIdentifier,
      bool showAppBar = true,
      required this.title,
      required this.text,
      this.assetPath = ""})
      : super(
          stepIdentifier: stepIdentifier,
          isOptional: isOptional,
          showAppBar: showAppBar,
        );

  @override
  Widget createView({required survey_kit.QuestionResult? questionResult}) {
    return CompletionView(completionStep: this, assetPath: assetPath);
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class CompletionView extends StatelessWidget {
  final AlternativeCompletionStep completionStep;
  final DateTime _startDate = DateTime.now();
  final String assetPath;

  CompletionView({required this.completionStep, this.assetPath = ""});

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: completionStep,
      resultFunction: () => survey_kit.CompletionStepResult(
        completionStep.stepIdentifier,
        _startDate,
        DateTime.now(),
      ),
      title: Text(completionStep.title,
          style: Theme.of(context).textTheme.displayMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64.0),
        child: Column(
          children: [
            Text(
              completionStep.text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class StepView extends StatelessWidget {
  final surveystep.Step step;
  final Widget title;
  final Widget child;
  final survey_kit.QuestionResult Function() resultFunction;
  final bool isValid;
  final survey_kit.SurveyController? controller;

  bool isDraftSaved = false;
  StepView({
    required this.step,
    required this.child,
    required this.title,
    required this.resultFunction,
    this.controller,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    final _surveyController =
        controller ?? context.read<survey_kit.SurveyController>();

    return _content(_surveyController, context);
  }

  Widget _content(
      survey_kit.SurveyController surveyController, BuildContext context) {
    return SizedBox.expand(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: title,
                ),
                child,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Review Form',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      ElevatedButton(
                        onPressed: isValid || step.isOptional
                            ? () {
                                _FormPageState.isDraft = true;

                                surveyController.nextStep(
                                    context, resultFunction);
                              }
                            : null,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Save as Draft'),
                            Icon(
                                Icons.arrow_forward), // This adds an arrow icon
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isValid || step.isOptional
                            ? () {
                                _FormPageState.isDraft = false;
                                surveyController.nextStep(
                                    context, resultFunction);
                              }
                            : null,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Send Form'),
                            Icon(
                                Icons.arrow_forward), // This adds an arrow icon
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

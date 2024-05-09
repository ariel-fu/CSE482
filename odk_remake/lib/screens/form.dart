import 'dart:io';

import 'package:flutter/material.dart';

import 'package:odk_remake/models/FormQuestionFormat.dart';
import 'package:flutter/cupertino.dart';

import 'package:odk_remake/services/parseData.dart';
import 'package:survey_kit/survey_kit.dart' as survey_kit;


class Form extends StatefulWidget {
  const Form({super.key});

  // This widget is the root of your application.
@override
  State<Form> createState() => _FormPageState();
}

class _FormPageState extends State<Form> {
  bool readExcel = false;
  // Order is automatically maintained
  Map<String, FormQuestionFormat> formFormats = {};

  @override
  Widget build(BuildContext context) {
    print("here!!");
    // for each valid form format, create the widget
    if (!readExcel) {
      formFormats = parseQuestionFormatData('form_data/test/simple.xlsx');
      readExcel = true;
    }

    List<survey_kit.Step> steps = [];
    // DUMMY
    survey_kit.Step firstPage = survey_kit.InstructionStep(
          title: 'Welcome to the demo survey',
          text: 'Get ready for a bunch of super random questions!',
          buttonText: 'Let\'s go!',
        );
    steps.add(firstPage);
    for(FormQuestionFormat formStep in formFormats.values) {
      steps.add(formStep.generateStep());
    }
    // DUMMY
    survey_kit.Step finalStep = survey_kit.CompletionStep(
          stepIdentifier: survey_kit.StepIdentifier(id: '321'),
          text: 'Thanks for taking the survey, we will contact you soon!',
          title: 'Done!',
          buttonText: 'Submit survey',
        );
    steps.add(finalStep);
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

  Widget buildSurvey(List<survey_kit.Step> surveySteps) {
    return survey_kit.SurveyKit(
      onResult: (survey_kit.SurveyResult result) {
        print(result.finishReason);
        Navigator.pushNamed(context, '/');
      },
      task: survey_kit.NavigableTask(steps: surveySteps),
      showProgress: true,
      localizations: const <String, String>{
        'cancel': 'Cancel',
        'next': 'Next',
      },
      themeData: Theme.of(context).copyWith(
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
      ),
      surveyProgressbarConfiguration: survey_kit.SurveyProgressConfiguration(
        backgroundColor: Colors.white,
      ),
    );
  }
}

import 'package:odk_remake/steps/MultiChoiceAnswerStep.dart';
import 'package:odk_remake/steps/SingleChoiceAnswerStep.dart';
import 'package:survey_kit/survey_kit.dart';
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

import 'package:flutter/cupertino.dart';
import 'package:survey_kit/survey_kit.dart' as survey_kit;

enum QuestionType {
  // todo: add more here
  Text,
  Email,
  Note,
  Integer,
  Numeric,
  Date,
  Time,
  SelectOne,
  LikertScale,
  SelectMultiple
}

class FormQuestionFormat {
  QuestionType questionType;
  String name;
  String label;
  String parameters;
  String relevant;
  bool required;
  List<String> answerChoices;
  FormQuestionFormat(
      {required this.questionType,
      required this.name,
      required this.label,
      required this.parameters,
      required this.required,
      required this.relevant,
      List<String>? answerChoices})
      : this.answerChoices = answerChoices ?? [];

  String printAnswerChoices() {
    if (answerChoices == null) {
      return "empty";
    }

    String ret = "{";

    for (String tuple in answerChoices) {
      ret += "(name: ${tuple}, ";
    }

    ret += "}";

    return ret;
  }

  @override
  String toString() {
    return '{name: $name, label: $label, parameters: $parameters, relevant: $relevant, answer choices: ${printAnswerChoices()}}\n';
  }
}

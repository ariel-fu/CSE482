import 'package:flutter/widgets.dart';
import 'package:survey_kit/survey_kit.dart';

abstract class FormQuestionWidget {
  Step step;
  String question;  

  FormQuestionWidget({
    required this.step,
    required this.question
  });
}
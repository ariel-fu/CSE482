import 'package:flutter/widgets.dart';

abstract class FormQuestionWidget {
  Container widget;
  String question;  

  FormQuestionWidget({
    required this.widget,
    required this.question
  });
}
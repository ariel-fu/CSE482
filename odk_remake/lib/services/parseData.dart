import 'dart:io';
import 'package:excel/excel.dart';
import 'package:odk_remake/models/FormQuestionFormat.dart';
import 'package:survey_kit/survey_kit.dart';

const String SURVEY_TABLE = 'survey';
const String SELECT_CHOICES_TABLE = 'choices';
String filePath = "";

List<TextChoice> parseSelectChoices(String listName) {
  List<TextChoice> selectChoices = [];
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  if (excel.tables.containsKey(SELECT_CHOICES_TABLE)) {
    for (var row in excel.tables[SELECT_CHOICES_TABLE]!.rows) {
      // [list_name, name, label, image(?)]
      String list_name = row[0] == null ? "n/a" : row[0]!.value.toString();
      if (list_name == listName) {
        String name = row[1] == null ? "n/a" : row[1]!.value.toString();
        String label = row[2] == null ? "n/a" : row[2]!.value.toString();
        TextChoice textChoice = TextChoice(text: label, value: name);
        selectChoices.add(textChoice);
      }
    }
  }

  return selectChoices;
}

Map<String, FormQuestionFormat> parseQuestionFormatData(String input) {
  filePath = input;
  Map<String, FormQuestionFormat> formFormats = {};
  var bytes = File(filePath).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  for (var row in excel.tables[SURVEY_TABLE]!.rows) {
    String typeString = row[0] == null ? "n/a" : row[0]!.value.toString();
    String type = typeString.split(" ").length > 1
        ? typeString.split(" ")[0]
        : typeString;
    String name = row[1] == null ? "n/a" : row[1]!.value.toString();
    String label = row[2] == null ? "n/a" : row[2]!.value.toString();
    String parameters = row[13] == null ? "n/a" : row[13]!.value.toString();
    bool required = row[4] == null ? false : row[4]!.value.toString() == "yes";
    String relevant = row[5] == null ? "n/a" : row[5]!.value.toString();

    FormQuestionFormat? format;
    switch (type) {
      case "text":
        print("Input matches QuestionType.Text");
        format = FormQuestionFormat(
            questionType: QuestionType.Text,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "email":
        print("Input matches QuestionType.Email");
        format = FormQuestionFormat(
            questionType: QuestionType.Email,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "note":
        print("Input matches QuestionType.Note");
        format = FormQuestionFormat(
            questionType: QuestionType.Note,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "integer":
        print("Input matches QuestionType.Integer");
        format = FormQuestionFormat(
            questionType: QuestionType.Integer,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "numeric":
        print("Input matches QuestionType.Numeric");
        format = FormQuestionFormat(
            questionType: QuestionType.Numeric,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "date":
        print("Input matches QuestionType.Date");
        format = FormQuestionFormat(
            questionType: QuestionType.Date,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "time":
        print("Input matches QuestionType.Time");
        format = FormQuestionFormat(
            questionType: QuestionType.Time,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant);
        break;
      case "select_one":
        print("Input matches QuestionType.SelectOne");
        // parse the 2nd file for choices
        String listName = typeString.split(" ")[1];
        format = FormQuestionFormat(
            questionType: QuestionType.SelectOne,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant,
            answerChoices: parseSelectChoices(listName));
        break;
      case "likert_scale":
        print("Input matches QuestionType.LikertScale");
        // parse the 2nd file for choices
        String listName = typeString.split(" ")[1];
        format = FormQuestionFormat(
            questionType: QuestionType.LikertScale,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant,
            answerChoices: parseSelectChoices(listName));
        break;
      case "select_multiple":
        print("Input matches QuestionType.SelectMultiple");
        String listName = typeString.split(" ")[1];
        format = FormQuestionFormat(
            questionType: QuestionType.SelectMultiple,
            name: name,
            label: label,
            parameters: parameters,
            required: required,
            relevant: relevant,
            answerChoices: parseSelectChoices(listName));
        break;
      default:
    }

    // print the data parsed from the excel
    // print(format.toString());

    if (format != null) {
      formFormats[name] = format;
    }
  }
  return formFormats;
}

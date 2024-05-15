import 'package:survey_kit/survey_kit.dart';

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
  List<TextChoice> answerChoices;
  FormQuestionFormat({
    required this.questionType,
    required this.name,
    required this.label,
    required this.parameters,
    required this.required,
    required this.relevant,
    List<TextChoice>? answerChoices,
  }) : this.answerChoices = answerChoices ?? List.empty();

  String printAnswerChoices() {
    if (answerChoices == null) {
      return "empty";
    }

    String ret = "{";

    for (TextChoice tuple in answerChoices) {
      ret += "(name: ${tuple.text}, tuple: ${tuple.value}), ";
    }

    ret += "}";

    return ret;
  }

  ///  Use this to generate a question step for the FormQuestionFormat
  Step generateStep() {
    Step step = InstructionStep(title: 'Dummy step', text: 'Dummy text');
    switch (questionType) {
      case QuestionType.Text:
        print("Input matches QuestionType.Text");
        step = QuestionStep(
            title: name, text: label, answerFormat: const TextAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Email:
        print("Input matches QuestionType.Email");
        step = QuestionStep(
            title: name, text: label, answerFormat: const TextAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Note:
        print("Input matches QuestionType.Note");
        // TODO: identify what a note is
        step = QuestionStep(
            title: name, text: label, answerFormat: const TextAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Integer:
        print("Input matches QuestionType.Integer");
        step = QuestionStep(
            title: name,
            text: label,
            answerFormat: const IntegerAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Numeric:
        print("Input matches QuestionType.Numeric");
        // TODO: difference between integer & numeric
        step = QuestionStep(
            title: name,
            text: label,
            answerFormat: const IntegerAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Date:
        print("Input matches QuestionType.Date");
        step = QuestionStep(
            title: name, text: label, answerFormat: DateAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.Time:
        print("Input matches QuestionType.Time");
        step = QuestionStep(
            title: name, text: label, answerFormat: const TimeAnswerFormat(), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.SelectOne:
        print("Input matches QuestionType.SelectOne");
        // parse the 2nd file for choices
        step = QuestionStep(
            title: name,
            text: label,
            answerFormat: SingleChoiceAnswerFormat(textChoices: answerChoices), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.LikertScale:
        print("Input matches QuestionType.LikertScale");
        // parse the 2nd file for choices
        step = QuestionStep(
            title: name,
            text: label,
            answerFormat: SingleChoiceAnswerFormat(textChoices: answerChoices), stepIdentifier: StepIdentifier(id: name));
        break;
      case QuestionType.SelectMultiple:
        print("Input matches QuestionType.SelectMultiple");
        // parse the 2nd file for choices
        step = QuestionStep(
            title: name,
            text: label,
            answerFormat: MultipleChoiceAnswerFormat(textChoices: answerChoices), stepIdentifier: StepIdentifier(id: name));
        break;
      default:
    }
    return step;
  }

  @override
  String toString() {
    return '{name: $name, label: $label, parameters: $parameters, relevant: $relevant, answer choices: ${printAnswerChoices()}}\n';
  }
}

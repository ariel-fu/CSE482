import 'package:odk_remake/NameLabelTuple.dart';

enum QuestionType {
  // todo: add more here
  Text,
  Date,
  Time,
  SelectOne,
  SelectMultiple
}

class FormQuestionFormat {
   QuestionType questionType;
   String name;
   String label;
   String parameters;
   String relevant;
   bool required;
   List<NameLabelTuple> answerChoices;
   FormQuestionFormat({
    required this.questionType,
    required this.name,
    required this.label,
    required this.parameters,
    required this.required,
    required this.relevant,
    List<NameLabelTuple>? answerChoices,
  }) : this.answerChoices = answerChoices ?? List.empty();  

  String printAnswerChoices() {
    if(answerChoices == null) {
      return "empty";
    }

    String ret = "{";

    for(NameLabelTuple tuple in answerChoices) {
      ret += "(name: ${tuple.name}, tuple: ${tuple.label}), ";
    }

    ret += "}";

    return ret;
  }

    @override
  String toString() {
    return '{name: $name, label: $label, parameters: $parameters, relevant: $relevant, answer choices: ${printAnswerChoices()}}\n';
  }
}

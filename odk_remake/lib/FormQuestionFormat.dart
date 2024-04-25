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
   FormQuestionFormat({
    required this.questionType,
    required this.name,
    required this.label,
    required this.parameters,
    required this.required,
    required  this.relevant
  });  
}

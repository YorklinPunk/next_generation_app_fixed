class OperationException {
  String code;
  String description;

  OperationException(this.code, this.description);

  OperationException.empty()
      : code = '',
        description = '';
}

class OperationResult {
  bool isValid;
  List<OperationException> exceptions;

  OperationResult({required this.isValid, required this.exceptions});
}

class OperationResultGeneric<T> extends OperationResult {
  T content;

  OperationResultGeneric({
    required bool isValid,
    required List<OperationException> exceptions,
    required this.content,
  }) : super(isValid: isValid, exceptions: exceptions);
}

class Failure {
  final String message;

  Failure([this.message = "Sorry, an unexpected error occurred!"]);

  @override
  String toString() => 'Failure(message: $message)';
}

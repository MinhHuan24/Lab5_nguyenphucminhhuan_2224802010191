class TodoModel {
  final int id;
  final String title;
  final bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    required this.isDone,
  });

  factory TodoModel.fromJson(
      Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      isDone: json['isDone'],
    );
  }
}
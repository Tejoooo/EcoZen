class ProblemModel {
  final String uid;
  final String pid;
  final String description;
  final String status;
  final String image;
  final DateTime uploadedAt;
  final double latitude;
  final double longitude;

  const ProblemModel(
    this.uid,
    this.pid,
    this.description,
    this.status,
    this.image,
    this.uploadedAt,
    this.latitude,
    this.longitude,
  );

  factory ProblemModel.fromJSON(Map<String, dynamic> json) {
    return ProblemModel(
      json['user'].toString(),
      json['pk'].toString(),
      json['description'],
      json['status'] ?? "Submitted",
      json['image'],
      DateTime.parse(json['uploaded_at'] ?? DateTime.now().toString()),
      json['latitude'],
      json['longitude'],
    );
  }
}

class Photo {
  final int id;
  final int albumId;
  final String title;
  final String url;
  final String thumbnailUrl;

  Photo({
    required this.id,
    required this.albumId,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    this.newId = 0,
  });

  int newId;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      albumId: json['albumId'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      newId: json['id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': newId,
      'albumId': albumId,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

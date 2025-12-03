class AzkarModel {
  final String? category;
  final String? zekr;
  final String? description;
  final int? count;
  final String? reference;
  final String? search;

  AzkarModel({
    this.category,
    this.zekr,
    this.description,
    this.count,
    this.reference,
    this.search,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    final parsedCount = json['count'] is String
        ? int.tryParse(json['count'])
        : json['count'];
    return AzkarModel(
      category: json['category'],
      zekr: json['zekr'],
      description: json['description'],
      count: (parsedCount == null || parsedCount == 0) ? 1 : parsedCount,
      reference: json['reference'],
      search: json['search'],
    );
  }
}

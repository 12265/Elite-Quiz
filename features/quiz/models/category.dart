class Category {
  const Category({
    this.languageId,
    this.categoryName,
    this.image,
    this.rowOrder,
    this.noOf,
    this.noOfQues,
    this.maxLevel,
    required this.isPlayed,
    this.isPremium = false,
    required this.requiredCoins,
    this.hasUnlocked = false,
    this.id,
  });

  final String? id;
  final String? languageId;
  final String? categoryName;
  final String? image;
  final String? rowOrder;
  final String? noOf;
  final String? noOfQues;
  final String? maxLevel;
  final bool isPlayed;
  final bool isPremium;
  final bool hasUnlocked;
  final int requiredCoins;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      isPlayed: json['is_play'] == null ? true : json['is_play'] == "1",
      id: json["id"],
      languageId: json["language_id"],
      categoryName: json["category_name"],
      image: json["image"],
      rowOrder: json["row_order"],
      noOf: json["no_of"],
      noOfQues: json["no_of_que"],
      maxLevel: json["maxlevel"],
      isPremium: (json['is_premium'] ?? "0") == "1",
      hasUnlocked: (json['has_unlocked'] ?? "0") == "1",
      requiredCoins: int.parse(json['coins'] ?? '0'),
    );
  }

  Category copyWith({bool? hasUnlocked}) {
    return Category(
      isPlayed: isPlayed,
      id: id,
      languageId: languageId,
      categoryName: categoryName,
      image: image,
      rowOrder: rowOrder,
      noOf: noOf,
      noOfQues: noOfQues,
      maxLevel: maxLevel,
      isPremium: isPremium,
      hasUnlocked: hasUnlocked ?? this.hasUnlocked,
      requiredCoins: requiredCoins,
    );
  }
}

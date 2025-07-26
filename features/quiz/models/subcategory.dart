class Subcategory {
  const Subcategory({
    required this.isPlayed,
    this.id,
    this.image,
    this.languageId,
    this.mainCatId,
    this.maxLevel,
    this.noOfQue,
    this.rowOrder,
    this.status,
    this.subcategoryName,
    this.isPremium = false,
    required this.requiredCoins,
    this.hasUnlocked = false,
  });

  final String? id;
  final String? image;
  final String? languageId;
  final String? mainCatId;
  final String? maxLevel;
  final String? noOfQue;
  final String? rowOrder;
  final String? status;
  final String? subcategoryName;
  final bool isPlayed;
  final bool isPremium;
  final bool hasUnlocked;
  final int requiredCoins;

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    return Subcategory(
      id: json["id"],
      image: json['image'],
      isPlayed: json['is_play'] == null ? true : json['is_play'] == "1",
      languageId: json["language_id"],
      mainCatId: json["maincat_id"],
      maxLevel: json["maxlevel"],
      noOfQue: json["no_of_que"],
      rowOrder: json["row_order"],
      status: json["status"],
      subcategoryName: json["subcategory_name"],
      isPremium: (json['is_premium'] ?? "0") == "1",
      hasUnlocked: (json['has_unlocked'] ?? "0") == "1",
      requiredCoins: int.parse(json['coins'] ?? '0'),
    );
  }

  Subcategory copyWith({bool? hasUnlocked}) => Subcategory(
        isPlayed: isPlayed,
        requiredCoins: requiredCoins,
        id: id,
        image: image,
        languageId: languageId,
        mainCatId: mainCatId,
        maxLevel: maxLevel,
        noOfQue: noOfQue,
        rowOrder: rowOrder,
        status: status,
        subcategoryName: subcategoryName,
        isPremium: isPremium,
        hasUnlocked: hasUnlocked ?? this.hasUnlocked,
      );
}

class PlaceCategory {
  final String id;
  final String name;
  final String imagePath;

  const PlaceCategory({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  static const List<PlaceCategory> allCategories = [
    PlaceCategory(
      id: 'mosque',
      name: 'Mosques',
      imagePath: 'assets/images/categories/mosque.png',
    ),
    PlaceCategory(
      id: 'museum',
      name: 'Museums',
      imagePath: 'assets/images/categories/museum.png',
    ),
    PlaceCategory(
      id: 'park',
      name: 'Parks',
      imagePath: 'assets/images/categories/park.png',
    ),
    PlaceCategory(
      id: 'restaurant',
      name: 'Restaurants',
      imagePath: 'assets/images/categories/restaurant.png',
    ),
    PlaceCategory(
      id: 'cafe',
      name: 'Cafes',
      imagePath: 'assets/images/categories/cafe.png',
    ),
    PlaceCategory(
      id: 'attraction',
      name: 'Attractions',
      imagePath: 'assets/images/categories/attraction.png',
    ),
    PlaceCategory(
      id: 'historical',
      name: 'Historical',
      imagePath: 'assets/images/categories/historical.png',
    ),
    PlaceCategory(
      id: 'shopping',
      name: 'Shopping',
      imagePath: 'assets/images/categories/shopping.png',
    ),
    PlaceCategory(
      id: 'hotel',
      name: 'Hotels',
      imagePath: 'assets/images/categories/hotel.png',
    ),
    PlaceCategory(
      id: 'church',
      name: 'Churches',
      imagePath: 'assets/images/categories/church.png',
    ),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

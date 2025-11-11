import 'package:ads_app/Models/category_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryManager {
  static final List<Category> _searchCategories = [
    Category(0, "ابرز الإعلانات", FontAwesomeIcons.turnUp),
    Category(1, "السيارات", FontAwesomeIcons.car),
    Category(2, "تسويق", FontAwesomeIcons.book),
    Category(3, "الحواسيب", FontAwesomeIcons.computer),
    Category(4, "الموضة والازياء", FontAwesomeIcons.shirt),
    Category(5, "الترفيه والالعاب", FontAwesomeIcons.gamepad),
    Category(6, "البقالة والادوات المنزلية", FontAwesomeIcons.basketShopping),
    Category(7, "الصحة", FontAwesomeIcons.suitcaseMedical),
    Category(8, "المنزل والاثاث", FontAwesomeIcons.house),
    Category(9, "الحيوانات الاليفة", FontAwesomeIcons.dog),
    Category(10, "طعام", FontAwesomeIcons.burger),
    Category(11, "متنوع", FontAwesomeIcons.layerGroup),
  ];

  static final Category _unknownCategory =
      Category(-1, "غير معروف", FontAwesomeIcons.question);

  static Category getCategoryById(int id) {
    if (id >= 0 && id < _searchCategories.length) {
      return _searchCategories[id];
    }
    return _unknownCategory;
  }

  static Category getSearchCategoryById(int id) {
    if (id >= 0 && id < _searchCategories.length) {
      return _searchCategories[id];
    }
    return _unknownCategory;
  }

  static List<Category> getAllCategories() {
    return List.unmodifiable(_searchCategories);
  }

  static List<Category> getAllSearchCategories() {
    return List.unmodifiable(_searchCategories);
  }
}

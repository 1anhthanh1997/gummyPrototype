import 'package:web_test/model/item_model.dart';

class StepModel {
  int id;
  int parentId;
  int gameType;
  String stepAssets;
  String background;
  List<ItemModel> items;
  double height;

  StepModel(
      {this.id = 0,
      this.parentId,
      this.gameType,
      this.stepAssets,
      this.background,
      this.items,
      this.height});

  List<ItemModel> getItemList(List itemListJson) {
    List<ItemModel> itemList = [];
    itemList = itemListJson
        .map((imageInfo) => new ItemModel.fromJson(imageInfo))
        .toList();
    return itemList;
  }

  StepModel.fromJson(Map<String, dynamic> json) {
    print(json['background']);
    id = json['id'] == null ? 0 : json['id'];
    parentId = json['parentId'] ?? 0;
    gameType = json['gameType'] == null ? 0 : json['gameType'];
    stepAssets = json['stepAssets'] == null ? '' : json['stepAssets'];
    background = json['background'] == null ? '' : json['background'];
    items = json['items'] == null ? [] : getItemList(json['items']);
    height = json['height'] == null ? 0 : json['height'].toDouble();
  }
}

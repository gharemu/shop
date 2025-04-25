class Product {
  int? wishlistItemId;
  int? quantity;
  int? cartItemId;
  int? id;
  String? name;
  String? description;
  String? oldPrice;
  String? discountPrice;
  int? discount;
  String? category;
  String? parentCategory;
  String? subCategory;
  int? stock;
  String? image;
  String? size;
  String? color;
  String? createdAt;

  Product({
    this.wishlistItemId,
    this.quantity,
    this.id,
    this.name,
    this.description,
    this.oldPrice,
    this.discountPrice,
    this.discount,
    this.category,
    this.parentCategory,
    this.subCategory,
    this.stock,
    this.image,
    this.size,
    this.color,
    this.createdAt,
    this.cartItemId,
  });

  Product.fromJson(Map<String, dynamic> json) {
    wishlistItemId = json['wishlist_item_id'];
    quantity = json['quantity'];
    id = json['id'];
    cartItemId = json['cart_item_id'];
    name = json['name'];
    description = json['description'];
    oldPrice = json['old_price'];
    discountPrice = json['discount_price'];
    discount = json['discount'];
    category = json['category'];
    parentCategory = json['parent_category'];
    subCategory = json['sub_category'];
    stock = json['stock'];
    image = json['image'];
    size = json['size'];
    color = json['color'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wishlist_item_id'] = this.wishlistItemId;
    data['quantity'] = this.quantity;
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['old_price'] = this.oldPrice;
    data['discount_price'] = this.discountPrice;
    data['discount'] = this.discount;
    data['category'] = this.category;
    data['parent_category'] = this.parentCategory;
    data['sub_category'] = this.subCategory;
    data['stock'] = this.stock;
    data['image'] = this.image;
    data['size'] = this.size;
    data['color'] = this.color;
    data['created_at'] = this.createdAt;
    data['cart_item_id'] = this.cartItemId;
    return data;
  }
}

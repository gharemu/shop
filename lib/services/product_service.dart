// services/product_service.dart
import 'package:police_app/models/product.dart';

class ProductService {
  // Men products
  List<Product> getMenProducts() {
    return [
      Product(
        id: 'm1',
        name: 'Slim Fit Casual Shirt',
        brand: 'Roadster',
        description:
            'Blue slim fit casual shirt, has a spread collar, long sleeves, button placket, curved hem, and 1 patch pocket',
        category: 'Shirts',
        gender: 'Men',
        originalPrice: 1499,
        discountedPrice: 799,
        discount: 47,
        imageUrl: 'assets/images/men/shirt1.jpg',
        additionalImages: [
          'assets/images/men/shirt1_1.jpg',
          'assets/images/men/shirt1_2.jpg',
        ],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Blue', 'White', 'Black'],
        rating: 4.2,
        reviews: 1203,
      ),
      Product(
        id: 'm2',
        name: 'Men Pure Cotton T-shirt',
        brand: 'H&M',
        description: 'Black solid T-shirt, has a round neck, short sleeves',
        category: 'T-shirts',
        gender: 'Men',
        originalPrice: 799,
        discountedPrice: 499,
        discount: 38,
        imageUrl: 'assets/images/men/tshirt1.jpg',
        additionalImages: [
          'assets/images/men/tshirt1_1.jpg',
          'assets/images/men/tshirt1_2.jpg',
        ],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Black', 'White', 'Grey', 'Navy Blue'],
        rating: 4.1,
        reviews: 2035,
      ),
      Product(
        id: 'm3',
        name: 'Men Slim Fit Jeans',
        brand: 'Levis',
        description: 'Dark blue slim fit mid-rise clean look stretchable jeans',
        category: 'Jeans',
        gender: 'Men',
        originalPrice: 2999,
        discountedPrice: 1799,
        discount: 40,
        imageUrl: 'assets/images/men/jeans1.jpg',
        additionalImages: [
          'assets/images/men/jeans1_1.jpg',
          'assets/images/men/jeans1_2.jpg',
        ],
        sizes: ['30', '32', '34', '36', '38'],
        colors: ['Dark Blue', 'Black', 'Light Blue'],
        rating: 4.5,
        reviews: 1854,
      ),
      Product(
        id: 'm4',
        name: 'Running Shoes',
        brand: 'Nike',
        description:
            'Men black mesh running sports shoes with cushioned footbed',
        category: 'Footwear',
        gender: 'Men',
        originalPrice: 3995,
        discountedPrice: 2995,
        discount: 25,
        imageUrl: 'assets/images/men/shoes1.jpg',
        additionalImages: [
          'assets/images/men/shoes1_1.jpg',
          'assets/images/men/shoes1_2.jpg',
        ],
        sizes: ['UK7', 'UK8', 'UK9', 'UK10'],
        colors: ['Black', 'Grey', 'Blue'],
        rating: 4.6,
        reviews: 872,
      ),
    ];
  }

  // Women products
  List<Product> getWomenProducts() {
    return [
      Product(
        id: 'w1',
        name: 'Printed A-Line Dress',
        brand: 'Biba',
        description:
            'Pink and gold-toned printed woven A-line dress, has a round neck, three-quarter sleeves',
        category: 'Dresses',
        gender: 'Women',
        originalPrice: 2499,
        discountedPrice: 1499,
        discount: 40,
        imageUrl: 'assets/images/women/dress1.jpg',
        additionalImages: [
          'assets/images/women/dress1_1.jpg',
          'assets/images/women/dress1_2.jpg',
        ],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['Pink', 'Blue', 'Yellow'],
        rating: 4.3,
        reviews: 1567,
      ),
      Product(
        id: 'w2',
        name: 'Women Kurta with Palazzos',
        brand: 'Anouk',
        description: 'Yellow printed kurta with palazzos',
        category: 'Kurtas',
        gender: 'Women',
        originalPrice: 2999,
        discountedPrice: 1469,
        discount: 51,
        imageUrl: 'assets/images/women/kurta1.jpg',
        additionalImages: [
          'assets/images/women/kurta1_1.jpg',
          'assets/images/women/kurta1_2.jpg',
        ],
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        colors: ['Yellow', 'Red', 'Green'],
        rating: 4.2,
        reviews: 1296,
      ),
      Product(
        id: 'w3',
        name: 'Printed Wrap Top',
        brand: 'Vero Moda',
        description: 'Red and black printed wrap top with ruffled detail',
        category: 'Tops',
        gender: 'Women',
        originalPrice: 1699,
        discountedPrice: 849,
        discount: 50,
        imageUrl: 'assets/images/women/top1.jpg',
        additionalImages: [
          'assets/images/women/top1_1.jpg',
          'assets/images/women/top1_2.jpg',
        ],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['Red', 'Blue', 'Black'],
        rating: 4.1,
        reviews: 983,
      ),
      Product(
        id: 'w4',
        name: 'Analogue Watch',
        brand: 'Fossil',
        description: 'Rose gold-toned analogue watch with a metal strap',
        category: 'Watches',
        gender: 'Women',
        originalPrice: 8995,
        discountedPrice: 6995,
        discount: 22,
        imageUrl: 'assets/images/women/watch1.jpg',
        additionalImages: [
          'assets/images/women/watch1_1.jpg',
          'assets/images/women/watch1_2.jpg',
        ],
        sizes: ['Free Size'],
        colors: ['Rose Gold', 'Silver', 'Gold'],
        rating: 4.5,
        reviews: 527,
      ),
    ];
  }

  // Kids products
  List<Product> getKidsProducts() {
    return [
      Product(
        id: 'k1',
        name: 'Boys Printed T-shirt',
        brand: 'Max',
        description: 'Yellow printed round neck T-shirt, has short sleeves',
        category: 'T-shirts',
        gender: 'Kids',
        originalPrice: 499,
        discountedPrice: 349,
        discount: 30,
        imageUrl: 'assets/images/kids/tshirt1.jpg',
        additionalImages: [
          'assets/images/kids/tshirt1_1.jpg',
          'assets/images/kids/tshirt1_2.jpg',
        ],
        sizes: ['2-3Y', '4-5Y', '6-7Y', '8-9Y'],
        colors: ['Yellow', 'Blue', 'Red'],
        rating: 4.3,
        reviews: 687,
      ),
      Product(
        id: 'k2',
        name: 'Girls Casual Dress',
        brand: 'Allen Solly Junior',
        description: 'Pink floral printed casual dress with frilled sleeves',
        category: 'Dresses',
        gender: 'Kids',
        originalPrice: 1299,
        discountedPrice: 779,
        discount: 40,
        imageUrl: 'assets/images/kids/dress1.jpg',
        additionalImages: [
          'assets/images/kids/dress1_1.jpg',
          'assets/images/kids/dress1_2.jpg',
        ],
        sizes: ['2-3Y', '4-5Y', '6-7Y', '8-9Y', '10-11Y'],
        colors: ['Pink', 'Blue', 'White'],
        rating: 4.4,
        reviews: 512,
      ),
      Product(
        id: 'k3',
        name: 'Boys Casual Shoes',
        brand: 'Kittens',
        description: 'Blue mesh sports shoes with velcro closure',
        category: 'Footwear',
        gender: 'Kids',
        originalPrice: 999,
        discountedPrice: 599,
        discount: 40,
        imageUrl: 'assets/images/kids/shoes1.jpg',
        additionalImages: [
          'assets/images/kids/shoes1_1.jpg',
          'assets/images/kids/shoes1_2.jpg',
        ],
        sizes: ['5C', '6C', '7C', '8C', '9C'],
        colors: ['Blue', 'Red', 'Black'],
        rating: 4.2,
        reviews: 342,
      ),
      Product(
        id: 'k4',
        name: 'Girls Denim Jacket',
        brand: 'H&M',
        description: 'Light blue washed denim jacket with button closure',
        category: 'Jackets',
        gender: 'Kids',
        originalPrice: 1499,
        discountedPrice: 899,
        discount: 40,
        imageUrl: 'assets/images/kids/jacket1.jpg',
        additionalImages: [
          'assets/images/kids/jacket1_1.jpg',
          'assets/images/kids/jacket1_2.jpg',
        ],
        sizes: ['4-5Y', '6-7Y', '8-9Y', '10-11Y'],
        colors: ['Light Blue', 'Dark Blue'],
        rating: 4.4,
        reviews: 247,
      ),
    ];
  }

  // Products under 999
  List<Product> getUnder999Products() {
    List<Product> allProducts = [
      ...getMenProducts(),
      ...getWomenProducts(),
      ...getKidsProducts(),
    ];
    return allProducts
        .where((product) => product.discountedPrice < 999)
        .toList();
  }

  // Luxury products
  List<Product> getLuxuryProducts() {
    return [
      Product(
        id: 'l1',
        name: 'Slim Fit Tuxedo Suit',
        brand: 'Louis Philippe',
        description:
            'Black solid slim-fit tuxedo suit, has a notched lapel, single-breasted with a single button closure, long sleeves, three pockets, double vented back hem',
        category: 'Suits',
        gender: 'Men',
        originalPrice: 14999,
        discountedPrice: 9999,
        discount: 33,
        imageUrl: 'assets/images/luxury/suit1.jpg',
        additionalImages: [
          'assets/images/luxury/suit1_1.jpg',
          'assets/images/luxury/suit1_2.jpg',
        ],
        sizes: ['38', '40', '42', '44', '46'],
        colors: ['Black', 'Navy Blue'],
        rating: 4.7,
        reviews: 304,
      ),
      Product(
        id: 'l2',
        name: 'Designer Lehenga Choli',
        brand: 'Sabyasachi',
        description: 'Red and gold embroidered lehenga choli with dupatta',
        category: 'Lehenga Choli',
        gender: 'Women',
        originalPrice: 29999,
        discountedPrice: 22999,
        discount: 23,
        imageUrl: 'assets/images/luxury/lehenga1.jpg',
        additionalImages: [
          'assets/images/luxury/lehenga1_1.jpg',
          'assets/images/luxury/lehenga1_2.jpg',
        ],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Red', 'Pink', 'Maroon'],
        rating: 4.8,
        reviews: 156,
      ),
      Product(
        id: 'l3',
        name: 'Leather Chronograph Watch',
        brand: 'Tag Heuer',
        description: 'Brown chronograph analog watch with leather strap',
        category: 'Watches',
        gender: 'Men',
        originalPrice: 35999,
        discountedPrice: 31999,
        discount: 11,
        imageUrl: 'assets/images/luxury/watch1.jpg',
        additionalImages: [
          'assets/images/luxury/watch1_1.jpg',
          'assets/images/luxury/watch1_2.jpg',
        ],
        sizes: ['Free Size'],
        colors: ['Brown', 'Black'],
        rating: 4.9,
        reviews: 89,
      ),
      Product(
        id: 'l4',
        name: 'Diamond Stud Earrings',
        brand: 'Tanishq',
        description: 'Gold-toned diamond studded stud earrings',
        category: 'Jewellery',
        gender: 'Women',
        originalPrice: 25999,
        discountedPrice: 23999,
        discount: 8,
        imageUrl: 'assets/images/luxury/earrings1.jpg',
        additionalImages: [
          'assets/images/luxury/earrings1_1.jpg',
          'assets/images/luxury/earrings1_2.jpg',
        ],
        sizes: ['Free Size'],
        colors: ['Gold'],
        rating: 4.7,
        reviews: 103,
      ),
    ];
  }

  // Get products by category
  List<Product> getProductsByCategory(String category) {
    List<Product> allProducts = [
      ...getMenProducts(),
      ...getWomenProducts(),
      ...getKidsProducts(),
      ...getLuxuryProducts(),
    ];
    return allProducts
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  // Get products by gender
  List<Product> getProductsByGender(String gender) {
    List<Product> allProducts = [
      ...getMenProducts(),
      ...getWomenProducts(),
      ...getKidsProducts(),
      ...getLuxuryProducts(),
    ];
    return allProducts
        .where(
          (product) => product.gender.toLowerCase() == gender.toLowerCase(),
        )
        .toList();
  }

  // Get products by brand
  List<Product> getProductsByBrand(String brand) {
    List<Product> allProducts = [
      ...getMenProducts(),
      ...getWomenProducts(),
      ...getKidsProducts(),
      ...getLuxuryProducts(),
    ];
    return allProducts
        .where((product) => product.brand.toLowerCase() == brand.toLowerCase())
        .toList();
  }

  // Get all products
  List<Product> getAllProducts() {
    return [
      ...getMenProducts(),
      ...getWomenProducts(),
      ...getKidsProducts(),
      ...getLuxuryProducts(),
    ];
  }

  // Get products on discount (> 30%)
  List<Product> getDiscountedProducts() {
    List<Product> allProducts = getAllProducts();
    return allProducts.where((product) => product.discount >= 30).toList();
  }
}

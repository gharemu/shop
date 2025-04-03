import 'package:Deals/models/product.dart';

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
        imageUrl:
            'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?q=80&w=3425&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1620012253295-c15cc3e65df4?q=80&w=3456&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1604695573706-53170668f6a6?q=80&w=3387&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1576566588028-4147f3842f27?q=80&w=3764&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=3300&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1586363104862-3a5e2ab60d99?q=80&w=3542&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1542272604-787c3835535d?q=80&w=3026&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=3387&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1584370848010-d7fe6bc767ec?q=80&w=3387&auto=format&fit=crop',
        ],
        sizes: ['30', '32', '34', '36', '38'],
        colors: ['Dark Blue', 'Black', 'Light Blue'],
        rating: 4.5,
        reviews: 1854,
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
        imageUrl:
            'https://images.unsplash.com/photo-1612336307429-8a898d10e223?q=80&w=2787&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1623180894967-b8cd4d2b7394?q=80&w=2592&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=3538&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1678720175173-f57e35f1a49d?q=80&w=3648&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1678720175348-4c3c8c99c1df?q=80&w=3648&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1678720176275-e549dfabb1e2?q=80&w=3648&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1648368825566-dcef6952f398?q=80&w=3648&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1648368832194-da2d0fc8764f?q=80&w=3648&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?q=80&w=3634&auto=format&fit=crop',
        ],
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: ['Red', 'Blue', 'Black'],
        rating: 4.1,
        reviews: 983,
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
        imageUrl:
            'https://images.unsplash.com/photo-1543804082-44da1c9d0684?q=80&w=3387&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1534067783941-51c9c23ecefd?q=80&w=3387&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?q=80&w=3372&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?q=80&w=3435&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1524236831290-542182cc1f39?q=80&w=3435&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1533735380053-eb8d0759b24a?q=80&w=3387&auto=format&fit=crop',
        ],
        sizes: ['2-3Y', '4-5Y', '6-7Y', '8-9Y', '10-11Y'],
        colors: ['Pink', 'Blue', 'White'],
        rating: 4.4,
        reviews: 512,
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
        imageUrl:
            'https://images.unsplash.com/photo-1632149877166-f75d49000351?q=80&w=3464&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1543076659-9380cdf10613?q=80&w=3548&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1549473448-5d7196c91f48?q=80&w=3334&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1594938291221-94f18cbb5660?q=80&w=3560&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1594938374182-a57645hkt?q=80&w=3560&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1593032465175-481ac7f401f0?q=80&w=3480&auto=format&fit=crop',
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
        imageUrl:
            'https://images.unsplash.com/photo-1616628188859-7a11abb6fcc9?q=80&w=3456&auto=format&fit=crop',
        additionalImages: [
          'https://images.unsplash.com/photo-1610030469668-7e55ca9c12c2?q=80&w=3648&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1594997756045-3c1777f9cb49?q=80&w=3579&auto=format&fit=crop',
        ],
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Red', 'Pink', 'Maroon'],
        rating: 4.8,
        reviews: 156,
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

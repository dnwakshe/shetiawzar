import '../models/product.dart';

/// Seed products matching Wakshe Agrotech Store demo specification.
final List<Product> initialSeedProducts = [
  Product(
    id: '1',
    name: 'Hand-forged Koyta',
    category: 'Cutting',
    price: 349.0,
    stock: 24,
    icon: '🌾',
    tag: 'Bestseller',
    description:
        'A sturdy traditional sickle for harvesting grass, crops and everyday farm cutting work.',
    updatedAt: DateTime(2026, 11, 20, 10, 30),
  ),
  Product(
    id: '2',
    name: 'Heavy-duty Axe',
    category: 'Cutting',
    price: 799.0,
    stock: 12,
    icon: '🪓',
    tag: 'Hand-forged',
    description:
        'A durable forged-steel axe head designed for demanding cutting and wood work.',
    updatedAt: DateTime(2026, 11, 18, 14, 15),
  ),
  Product(
    id: '3',
    name: 'Agricultural Spade',
    category: 'Digging',
    price: 599.0,
    stock: 18,
    icon: '⛏️',
    tag: 'Farm essential',
    description:
        'Thick steel blade for digging, turning soil and preparing garden or farm beds.',
    updatedAt: DateTime(2026, 11, 21, 9, 0),
  ),
  Product(
    id: '4',
    name: 'Garden Khurpi',
    category: 'Digging',
    price: 199.0,
    stock: 40,
    icon: '🧤',
    tag: 'Everyday use',
    description:
        'Compact hand tool for weeding, loosening soil and working around plants.',
    updatedAt: DateTime(2026, 11, 15, 16, 45),
  ),
  Product(
    id: '5',
    name: 'Steel Sattur',
    category: 'Cutting',
    price: 449.0,
    stock: 15,
    icon: '🔪',
    tag: 'Traditional',
    description:
        'A strong traditional cutting tool. Tempered blade crafted for precision and strength.',
    updatedAt: DateTime(2026, 11, 19, 11, 20),
  ),
  Product(
    id: '6',
    name: 'Wooden Handle Tool',
    category: 'Other',
    price: 149.0,
    stock: 30,
    icon: '🪵',
    tag: 'Accessory',
    description:
        'Replacement wooden handle. Confirm compatibility and measurements before ordering.',
    updatedAt: DateTime(2026, 11, 10, 8, 30),
  ),
  Product(
    id: '7',
    name: 'Serrated Vila (विळा)',
    category: 'Cutting',
    price: 299.0,
    stock: 22,
    icon: '🌾',
    tag: 'Harvesting',
    description:
        'Curved high-carbon steel sickle designed for rapid crop harvesting and fodder mowing.',
    updatedAt: DateTime(2026, 11, 22, 12, 0),
  ),
  Product(
    id: '8',
    name: 'Heavy Farm Phawada (फावडे)',
    category: 'Digging',
    price: 499.0,
    stock: 16,
    icon: '⛏️',
    tag: 'Soil prep',
    description:
        'Robust channel-digging steel blade crafted for irrigation trenches and mud bunding.',
    updatedAt: DateTime(2026, 11, 17, 13, 0),
  ),
];

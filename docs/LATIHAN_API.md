# Latihan Menyesuaikan API

Di responsi, **API dan soalnya bisa berganti**, tapi strukturnya tetap: model → API provider → controller → view. Bagian yang paling sering membuat bingung adalah **menyesuaikan model dan API provider dengan bentuk JSON yang baru**.

Lembar ini melatih tepat bagian itu, memakai API publik dengan bentuk respons yang berbeda-beda.

**Cara memakai lembar ini:**

1. Baca contoh JSON-nya, lalu buka URL API-nya di browser untuk membandingkan.
2. Tulis sendiri model dan fungsi API-nya, di kertas atau di project latihan.
3. Baru buka **"Lihat jawaban"** untuk mencocokkan.

> Semua kode jawaban di sini sudah dicek dengan Dart analyzer dan dijalankan terhadap contoh JSON di masing-masing latihan. Contoh JSON-nya dipotong supaya pendek. Kalau saat dibuka di browser ada field yang sedikit berbeda, ikuti yang di browser: itu justru latihan yang bagus.

---

## Daftar isi

- [Bagian A: 5 pertanyaan sebelum menulis kode](#bagian-a-5-pertanyaan-sebelum-menulis-kode)
- [Bagian B: Contekan pola `fromJson`](#bagian-b-contekan-pola-fromjson)
- [Bagian C: Contekan pola API provider](#bagian-c-contekan-pola-api-provider)
- [Latihan 1: Kenali bentuk respons](#latihan-1-kenali-bentuk-respons)
- [Latihan 2: Array langsung + objek bersarang (JSONPlaceholder)](#latihan-2-array-langsung--objek-bersarang-jsonplaceholder)
- [Latihan 3: List di dalam key + filter kategori (DummyJSON Products)](#latihan-3-list-di-dalam-key--filter-kategori-dummyjson-products)
- [Latihan 4: Pagination + list berisi objek (PokéAPI)](#latihan-4-pagination--list-berisi-objek-pokéapi)
- [Latihan 5: Hasil bisa `null` + field berpola (TheMealDB)](#latihan-5-hasil-bisa-null--field-berpola-themealdb)
- [Latihan 6: Tipe data campur aduk (JSON buatan)](#latihan-6-tipe-data-campur-aduk-json-buatan)
- [Latihan 7: Simulasi responsi lengkap (DummyJSON Recipes)](#latihan-7-simulasi-responsi-lengkap-dummyjson-recipes)
- [Template kosong](#template-kosong)

---

## Bagian A: 5 pertanyaan sebelum menulis kode

Setiap dapat API baru, buka dulu di browser dan jawab lima pertanyaan ini. Jawabannya langsung menentukan kodenya.

| No | Pertanyaan | Kenapa penting |
| --- | --- | --- |
| 1 | Respons list diawali `[` atau `{`? | `[` → `jsonDecode(...) as List`. `{` → list-nya ada di dalam sebuah key. |
| 2 | Kalau `{`, list-nya ada di key apa? | Misalnya `results`, `data`, `products`, `meals`. Itu yang dibaca: `body['products']`. |
| 3 | Ada pagination? (`next`, `page`, `total`, `skip`) | Kalau ada, perlu parameter halaman dan infinite scroll. Kalau tidak, cukup sekali ambil. |
| 4 | Apa tipe setiap field? | Teks, angka bulat, angka desimal, `true/false`, list, atau objek. Hati-hati dengan angka yang ditulis sebagai string (`"8.1"`). |
| 5 | Endpoint detail mengembalikan apa? | Biasanya satu objek `{...}`, tapi ada yang dibungkus list (`{"meals": [ {...} ]}`). |

---

## Bagian B: Contekan pola `fromJson`

Hampir semua field di API mana pun masuk ke salah satu baris ini:

| Bentuk di JSON | Contoh | Kode `fromJson` |
| --- | --- | --- |
| Teks | `"name": "Rick"` | `json['name']?.toString() ?? '-'` |
| Angka bulat | `"stock": 5` | `(json['stock'] as num?)?.toInt() ?? 0` |
| Angka desimal (kadang bulat) | `"price": 9.99` atau `"price": 10` | `(json['price'] as num?)?.toDouble() ?? 0` |
| Angka **berbentuk teks** | `"rating": "8.1"` | `double.tryParse(json['rating'].toString()) ?? 0` |
| `true/false` atau `1/0` | `"is_available": 1` | `json['is_available'] == true \|\| json['is_available'] == 1` |
| Objek bersarang | `"address": {"city": "..."}` | `json['address']?['city']?.toString() ?? '-'` |
| List teks | `"tags": ["a", "b"]` | `(json['tags'] as List?)?.map((e) => e.toString()).toList() ?? []` |
| List objek, ambil satu nilai | `"types": [{"type": {"name": "fire"}}]` | `(json['types'] as List?)?.map((t) => t['type']?['name']?.toString() ?? '-').toList() ?? []` |
| List objek, jadikan class | `"variants": [{"size": "M"}]` | `(json['variants'] as List?)?.map((v) => Variant.fromJson(v as Map<String, dynamic>)).toList() ?? []` |

Tiga kebiasaan yang mencegah crash:

- **Selalu pakai `?.` dan `??`.** Kalau sebuah key tidak ada atau bernilai `null`, aplikasi tetap jalan dengan nilai default.
- **Pakai `as num`, bukan `as int` atau `as double`.** API sering mengirim `10` padahal di tempat lain `9.99`. `num` menerima keduanya.
- **List dari `jsonDecode` bertipe `List<dynamic>`.** Jangan `as List<String>`, tapi `.map((e) => e.toString()).toList()`.

---

## Bagian C: Contekan pola API provider

Yang berubah antar-API hanya **cara mengambil list dari respons**:

```dart
final body = jsonDecode(response.body);

// Bentuk 1: array langsung            [ {...}, {...} ]                 (mockapi, JSONPlaceholder)
final list = body as List;

// Bentuk 2: list di dalam sebuah key  { "products": [ ... ], ... }      (DummyJSON)
final list = (body as Map<String, dynamic>)['products'] as List;

// Bentuk 3: list + info halaman       { "info": {...}, "results": [...] } (Rick & Morty, PokéAPI)
final list = body['results'] as List;
final hasNext = body['info']?['next'] != null;   // Rick & Morty
final hasNext = body['next'] != null;            // PokéAPI

// Bentuk 4: list yang BISA null       { "meals": null }                (TheMealDB)
final list = (body['meals'] as List?) ?? [];

// Lalu, untuk semua bentuk:
return list.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();
```

---

## Latihan 1: Kenali bentuk respons

Untuk setiap potongan respons di bawah, tentukan: (a) bentuknya nomor berapa di Bagian C, (b) baris kode untuk mengambil list-nya, (c) apakah ada pagination.

**A.**
```json
[ { "id": "1", "title": "KKN di Desa Penari" }, { "id": "2", "title": "Agak Laen" } ]
```

**B.**
```json
{ "page": 1, "per_page": 6, "total": 12, "total_pages": 2, "data": [ { "id": 7, "email": "michael@reqres.in" } ] }
```

**C.**
```json
{ "count": 1302, "next": "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20", "previous": null, "results": [ { "name": "bulbasaur", "url": "..." } ] }
```

**D.**
```json
{ "meals": null }
```

**E.**
```json
{ "status": "success", "data": { "movies": [ { "id": 1, "title": "Dilan 1990" } ], "page": 1 } }
```

**F.** (endpoint detail)
```json
{ "meals": [ { "idMeal": "52772", "strMeal": "Teriyaki Chicken Casserole" } ] }
```


<details>
<summary><b>Lihat jawaban</b></summary>

| | Bentuk | Kode mengambil list | Pagination |
| --- | --- | --- | --- |
| A | 1 (array langsung) | `body as List` | Tidak |
| B | 2 (list di key `data`) | `body['data'] as List` | Ya: `page`, `total_pages`. Halaman berikutnya ada kalau `page < total_pages`. |
| C | 3 (list + info) | `body['results'] as List` | Ya: `next` tidak `null` berarti masih ada halaman |
| D | 4 (bisa null) | `(body['meals'] as List?) ?? []` | Tidak. `null` berarti tidak ada hasil, jadi tampilkan pesan kosong, bukan error. |
| E | 2, tapi **bersarang dua tingkat** | `body['data']['movies'] as List` | Ya: `data.page` |
| F | Detail **dibungkus list** | `Meal.fromJson((body['meals'] as List).first)` | - |

Pelajaran dari E dan F: jangan berasumsi. Selalu telusuri dari `{` paling luar sampai ketemu list atau objek yang dicari.

</details>


---

## Latihan 2: Array langsung + objek bersarang (JSONPlaceholder)

- **List:** `https://jsonplaceholder.typicode.com/users`
- **Detail:** `https://jsonplaceholder.typicode.com/users/1`
- **Bentuk:** array langsung, mirip mockapi di soal responsi film.

Contoh respons list (satu item):

```json
[
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz",
    "address": {
      "street": "Kulas Light",
      "suite": "Apt. 556",
      "city": "Gwenborough",
      "zipcode": "92998-3874",
      "geo": { "lat": "-37.3159", "lng": "81.1496" }
    },
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org",
    "company": {
      "name": "Romaguera-Crona",
      "catchPhrase": "Multi-layered client-server neural-net",
      "bs": "harness real-time e-markets"
    }
  }
]
```

**Tugas:**

1. Buat class `User` dengan field: `id`, `name`, `username`, `email`, `phone`, `website`, `street`, `city`, `companyName`.
2. `street` dan `city` ada **di dalam** `address`, sedangkan `companyName` ada di dalam `company`. Ambil langsung ke field biasa, tanpa membuat class `Address`.
3. Tulis `getUsers()` (list) dan `getUser(id)` (detail).

**Petunjuk:** objek bersarang dibaca seperti membuka folder: `json['address']?['city']`.


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class User {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String street;
  final String city;
  final String companyName;

  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.street,
    required this.city,
    required this.companyName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '-',
        username: json['username']?.toString() ?? '-',
        email: json['email']?.toString() ?? '-',
        phone: json['phone']?.toString() ?? '-',
        website: json['website']?.toString() ?? '-',
        // Field bersarang: masuk ke objek 'address' dulu, baru ambil 'street'.
        street: json['address']?['street']?.toString() ?? '-',
        city: json['address']?['city']?.toString() ?? '-',
        companyName: json['company']?['name']?.toString() ?? '-',
      );
}

class UserApi {
  static const baseUrl = 'https://jsonplaceholder.typicode.com';

  // Respons berupa ARRAY langsung: [ {...}, {...} ]
  Future<List<User>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users'));
    final list = jsonDecode(res.body) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Detail berupa OBJEK: { ... }
  Future<User> getUser(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/users/$id'));
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
```

**Yang dilatih:** respons berupa array (`as List`), dan membaca objek bersarang dengan `?['...']`. Tanda `?` di depan `['city']` membuat aplikasi tidak crash kalau `address` tidak ada.

</details>


---

## Latihan 3: List di dalam key + filter kategori (DummyJSON Products)

- **List:** `https://dummyjson.com/products?limit=100`
- **Detail:** `https://dummyjson.com/products/1`
- **Bentuk:** objek, list-nya ada di key `products`.

Contoh respons (dipotong):

```json
{
  "products": [
    {
      "id": 1,
      "title": "Essence Mascara Lash Princess",
      "description": "A popular mascara known for its volumizing effects.",
      "category": "beauty",
      "price": 9.99,
      "discountPercentage": 7.17,
      "rating": 4.94,
      "stock": 5,
      "tags": ["beauty", "mascara"],
      "brand": "Essence",
      "thumbnail": "https://cdn.dummyjson.com/products/images/beauty/1/thumbnail.png",
      "images": ["https://cdn.dummyjson.com/products/images/beauty/1/1.png"]
    },
    {
      "id": 21,
      "title": "Cucumber",
      "description": "Crisp and hydrating cucumbers.",
      "category": "groceries",
      "price": 2,
      "rating": 4.07,
      "stock": 99,
      "tags": ["vegetables"],
      "thumbnail": "https://cdn.dummyjson.com/products/images/groceries/cucumber/thumbnail.png",
      "images": []
    }
  ],
  "total": 194,
  "skip": 0,
  "limit": 30
}
```

**Tugas:**

1. Buat class `Product`: `id`, `title`, `description`, `category`, `price`, `rating`, `stock`, `brand`, `thumbnail`, `images`, `tags`.
2. Perhatikan produk kedua: `price` bernilai `2` (bulat, bukan desimal) dan **tidak punya `brand`**. Model harus tetap jalan.
3. Tulis `getProducts()` dan `getProduct(id)`.
4. Buat filter kategori **lokal**: fungsi untuk mengambil daftar kategori unik dari data, dan fungsi untuk menyaring produk berdasarkan kategori.

Ini mirip filter genre di soal responsi film.


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String brand;
  final String thumbnail;
  final List<String> images;
  final List<String> tags;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.thumbnail,
    required this.images,
    required this.tags,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '-',
        description: json['description']?.toString() ?? '-',
        category: json['category']?.toString() ?? '-',
        // price bisa 9.99 (double) atau 10 (int): 'as num' menerima keduanya.
        price: (json['price'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        // Tidak semua produk punya 'brand', jadi wajib ada nilai default.
        brand: json['brand']?.toString() ?? 'Tanpa merek',
        thumbnail: json['thumbnail']?.toString() ?? '',
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class ProductApi {
  static const baseUrl = 'https://dummyjson.com';

  // Respons berupa OBJEK, list-nya ada di key 'products':
  // { "products": [ ... ], "total": 194, "skip": 0, "limit": 30 }
  Future<List<Product>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products?limit=100'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['products'] as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/products/$id'));
    return Product.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

// Filter kategori secara lokal (tanpa request baru).
List<String> categoriesOf(List<Product> products) =>
    products.map((p) => p.category).toSet().toList()..sort();

List<Product> filterByCategory(List<Product> products, String? category) =>
    category == null
        ? products
        : products.where((p) => p.category == category).toList();
```

**Yang dilatih:**

- `body['products'] as List`: list tidak langsung di akar respons.
- `as num?` lalu `.toDouble()`: menerima `9.99` maupun `2`. Kalau ditulis `as double`, produk kedua membuat aplikasi crash.
- Field yang kadang hilang (`brand`) wajib punya nilai default.
- `.toSet()` menghilangkan duplikat, jadi daftar kategori untuk chip filter diambil dari datanya sendiri, tidak ditulis manual.

</details>


---

## Latihan 4: Pagination + list berisi objek (PokéAPI)

- **List:** `https://pokeapi.co/api/v2/pokemon?offset=0&limit=20`
- **Detail:** `https://pokeapi.co/api/v2/pokemon/pikachu`
- **Bentuk:** objek dengan `next` dan `results`, mirip Rick & Morty.

Contoh respons list:

```json
{
  "count": 1302,
  "next": "https://pokeapi.co/api/v2/pokemon?offset=20&limit=20",
  "previous": null,
  "results": [
    { "name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/" },
    { "name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2/" }
  ]
}
```

Contoh respons detail (dipotong, aslinya sangat panjang):

```json
{
  "id": 25,
  "name": "pikachu",
  "height": 4,
  "weight": 60,
  "sprites": {
    "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png",
    "other": {
      "official-artwork": {
        "front_default": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png"
      }
    }
  },
  "types": [
    { "slot": 1, "type": { "name": "electric", "url": "https://pokeapi.co/api/v2/type/13/" } }
  ],
  "stats": [
    { "base_stat": 35, "effort": 0, "stat": { "name": "hp", "url": "https://pokeapi.co/api/v2/stat/1/" } },
    { "base_stat": 55, "effort": 0, "stat": { "name": "attack", "url": "https://pokeapi.co/api/v2/stat/2/" } }
  ]
}
```

**Tugas:**

1. List hanya berisi `name` dan `url`. Buat class `PokemonSummary` dengan `id` dan `name`. **`id` diambil dari angka di akhir `url`.**
2. Buat class `Pokemon` untuk detail: `id`, `name`, `height`, `weight`, `imageUrl`, `types` (`List<String>`, misalnya `["electric"]`), dan `stats`.
3. `imageUrl` diambil dari `sprites.other.official-artwork.front_default`. Kalau tidak ada, pakai `sprites.front_default`.
4. `stats` adalah list objek. Buat class `Stat` (`name`, `value`) untuk satu elemennya.
5. Tulis `getPokemons(offset)` yang juga mengembalikan apakah masih ada halaman berikutnya.


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Item di halaman list: API hanya memberi name dan url.
class PokemonSummary {
  final int id;
  final String name;

  const PokemonSummary({required this.id, required this.name});

  factory PokemonSummary.fromJson(Map<String, dynamic> json) {
    // url: "https://pokeapi.co/api/v2/pokemon/25/" -> ambil angka 25
    final url = json['url']?.toString() ?? '';
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    return PokemonSummary(
      id: int.tryParse(segments.isEmpty ? '' : segments.last) ?? 0,
      name: json['name']?.toString() ?? '-',
    );
  }

  // Gambar tidak ada di list, tapi bisa disusun dari id.
  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class Stat {
  final String name;
  final int value;

  const Stat({required this.name, required this.value});

  // Satu elemen 'stats': { "base_stat": 35, "stat": { "name": "hp" } }
  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        name: json['stat']?['name']?.toString() ?? '-',
        value: (json['base_stat'] as num?)?.toInt() ?? 0,
      );
}

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final String imageUrl;
  final List<String> types;
  final List<Stat> stats;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '-',
        height: (json['height'] as num?)?.toInt() ?? 0,
        weight: (json['weight'] as num?)?.toInt() ?? 0,
        // Bersarang 3 tingkat; key 'official-artwork' memakai tanda minus.
        imageUrl: json['sprites']?['other']?['official-artwork']?['front_default']
                ?.toString() ??
            json['sprites']?['front_default']?.toString() ??
            '',
        // List of OBJECT -> ambil satu nilai dari tiap objek.
        types: (json['types'] as List?)
                ?.map((t) => t['type']?['name']?.toString() ?? '-')
                .toList() ??
            [],
        // List of OBJECT -> jadikan class sendiri (Stat).
        stats: (json['stats'] as List?)
                ?.map((s) => Stat.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class PokemonApi {
  static const baseUrl = 'https://pokeapi.co/api/v2';

  // { "count": 1302, "next": "...?offset=20&limit=20", "results": [ {name,url} ] }
  Future<({List<PokemonSummary> items, bool hasNext})> getPokemons({
    int offset = 0,
  }) async {
    final res = await http.get(Uri.parse('$baseUrl/pokemon?offset=$offset&limit=20'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final items = (body['results'] as List)
        .map((e) => PokemonSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, hasNext: body['next'] != null);
  }

  Future<Pokemon> getPokemon(String name) async {
    final res = await http.get(Uri.parse('$baseUrl/pokemon/$name'));
    return Pokemon.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
```

**Yang dilatih:**

- **Pagination dengan `next`**: sama seperti `hasNext` di Rick & Morty. Halaman berikutnya memakai `offset + 20`.
- **List objek → `List<String>`** (`types`): ambil satu nilai dari setiap objek.
- **List objek → `List<Stat>`** (`stats`): kalau setiap objek punya beberapa nilai yang dipakai, jadikan class sendiri.
- **Bersarang dalam**, dan key dengan tanda minus (`'official-artwork'`) tetap ditulis sebagai string biasa.
- **List hanya berisi ringkasan.** Data lengkap baru diambil di halaman Detail, persis pola `DetailController`.

</details>


---

## Latihan 5: Hasil bisa `null` + field berpola (TheMealDB)

- **Cari:** `https://www.themealdb.com/api/json/v1/1/search.php?s=chicken`
- **Detail:** `https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772`
- **Bentuk:** `{ "meals": [...] }`, tapi bisa **`{ "meals": null }`** kalau tidak ada hasil.

Contoh respons ada hasil (dipotong):

```json
{
  "meals": [
    {
      "idMeal": "52772",
      "strMeal": "Teriyaki Chicken Casserole",
      "strCategory": "Chicken",
      "strArea": "Japanese",
      "strInstructions": "Preheat oven to 350° F. Spray a 9x13-inch baking pan...",
      "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
      "strIngredient1": "soy sauce",
      "strIngredient2": "water",
      "strIngredient3": "",
      "strIngredient4": null,
      "strMeasure1": "3/4 cup",
      "strMeasure2": "1/2 cup",
      "strMeasure3": "",
      "strMeasure4": null
    }
  ]
}
```

Contoh respons tidak ada hasil (coba `search.php?s=zzzz`):

```json
{ "meals": null }
```

**Tugas:**

1. Buat class `Meal`: `id` (dari `idMeal`), `name`, `category`, `area`, `instructions`, `thumbnail`, dan `ingredients` (`List<String>`).
2. Bahan **tidak** berbentuk list, tapi tersebar di `strIngredient1` sampai `strIngredient20` (dan takarannya di `strMeasure1`–`20`). Sebagian kosong `""` atau `null`. Kumpulkan yang terisi saja menjadi list, misalnya `"3/4 cup soy sauce"`.
3. `search(keyword)` harus mengembalikan list kosong, **bukan error**, saat `meals` bernilai `null`.
4. Detail juga dibungkus list `{ "meals": [ {...} ] }`. Ambil item pertamanya.


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final List<String> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Bahan ada di strIngredient1 ... strIngredient20, sebagian kosong/null.
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim() ?? '';
      final measure = json['strMeasure$i']?.toString().trim() ?? '';
      if (ingredient.isNotEmpty) {
        ingredients.add(measure.isEmpty ? ingredient : '$measure $ingredient');
      }
    }
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '-',
      category: json['strCategory']?.toString() ?? '-',
      area: json['strArea']?.toString() ?? '-',
      instructions: json['strInstructions']?.toString() ?? '-',
      thumbnail: json['strMealThumb']?.toString() ?? '',
      ingredients: ingredients,
    );
  }
}

class MealApi {
  static const baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // { "meals": [ ... ] }  ATAU  { "meals": null } kalau tidak ada hasil!
  Future<List<Meal>> search(String keyword) async {
    final res = await http.get(Uri.parse('$baseUrl/search.php?s=$keyword'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['meals'] as List?; // <- pakai List? karena bisa null
    if (list == null) return [];
    return list.map((e) => Meal.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Meal?> getMeal(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/lookup.php?i=$id'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final list = body['meals'] as List?;
    if (list == null || list.isEmpty) return null;
    // Detail juga dibungkus list berisi satu item.
    return Meal.fromJson(list.first as Map<String, dynamic>);
  }
}
```

**Yang dilatih:**

- **`as List?`** (dengan tanda tanya). Kalau ditulis `as List`, pencarian tanpa hasil langsung crash.
- **Nama key dibuat di dalam loop**: `json['strIngredient$i']`.
- **Detail yang dibungkus list**: ambil `.first`.
- **Nama key tidak harus sama dengan nama field.** `idMeal` dan `strMeal` menjadi `id` dan `name` yang lebih enak dipakai di kode.

</details>


---

## Latihan 6: Tipe data campur aduk (JSON buatan)

API buatan dosen atau asisten (misalnya di mockapi) sering **tidak rapi**: angka ditulis sebagai teks, `true/false` ditulis `1/0`, list kadang `null`. Latihan ini sengaja dibuat berantakan.

```json
{
  "id": "17",
  "name": "Kopi Susu Gula Aren",
  "price": "18000",
  "is_available": 1,
  "rating": 4,
  "tags": null,
  "store": {
    "name": "Kedai Senja",
    "location": { "city": "Yogyakarta" }
  },
  "variants": [
    { "size": "M", "extra": 0 },
    { "size": "L", "extra": 5000 }
  ]
}
```

**Tugas:** buat class `MenuItem` dan `Variant`, dengan tipe Dart yang **benar**:

| Field | Tipe Dart yang diminta | Jebakan |
| --- | --- | --- |
| `id` | `int` | Di JSON berupa teks `"17"` |
| `price` | `int` | Di JSON berupa teks `"18000"` |
| `isAvailable` | `bool` | Di JSON berupa angka `1` |
| `rating` | `double` | Di JSON berupa angka bulat `4` |
| `tags` | `List<String>` | Di JSON bernilai `null` |
| `storeName`, `city` | `String` | `city` bersarang dua tingkat |
| `variants` | `List<Variant>` | List berisi objek |

Buat juga `toJson()` yang menghasilkan bentuk yang bisa dibaca lagi oleh `fromJson()`. Ini penting kalau data disimpan sebagai favorit di Hive atau Shared Preferences.


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
class Variant {
  final String size;
  final int extra;

  const Variant({required this.size, required this.extra});

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        size: json['size']?.toString() ?? '-',
        extra: (json['extra'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {'size': size, 'extra': extra};
}

class MenuItem {
  final int id;
  final String name;
  final int price;
  final bool isAvailable;
  final double rating;
  final List<String> tags;
  final String storeName;
  final String city;
  final List<Variant> variants;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
    required this.rating,
    required this.tags,
    required this.storeName,
    required this.city,
    required this.variants,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        // "17" (string) -> 17 (int). tryParse aman untuk string MAUPUN angka.
        id: int.tryParse(json['id'].toString()) ?? 0,
        price: int.tryParse(json['price'].toString()) ?? 0,
        name: json['name']?.toString() ?? '-',
        // Bisa 1/0 atau true/false.
        isAvailable: json['is_available'] == true || json['is_available'] == 1,
        // 4 (int) -> 4.0 (double).
        rating: double.tryParse(json['rating'].toString()) ?? 0,
        // null -> list kosong.
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        storeName: json['store']?['name']?.toString() ?? '-',
        city: json['store']?['location']?['city']?.toString() ?? '-',
        variants: (json['variants'] as List?)
                ?.map((v) => Variant.fromJson(v as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'is_available': isAvailable,
        'rating': rating,
        'tags': tags,
        'store': {
          'name': storeName,
          'location': {'city': city},
        },
        'variants': variants.map((v) => v.toJson()).toList(),
      };
}
```

**Yang dilatih:**

- `int.tryParse(x.toString())` dan `double.tryParse(x.toString())` aman untuk teks **maupun** angka, jadi cocok saat kamu tidak yakin tipe yang dikirim API.
- `bool` dari `1/0` atau `true/false`.
- `toJson()` harus menyusun ulang bentuk bersarang (`store.location.city`) supaya `fromJson()` bisa membacanya kembali. Uji dengan `MenuItem.fromJson(item.toJson())`: hasilnya harus sama.

</details>


---

## Latihan 7: Simulasi responsi lengkap (DummyJSON Recipes)

Kerjakan seperti responsi sungguhan: **maksimal 2 jam**, tanpa melihat jawaban, boleh melihat repo Rick & Morty dan `docs/PANDUAN.md`.

**API:**

- List: `https://dummyjson.com/recipes?limit=50`
- Detail: `https://dummyjson.com/recipes/{id}`

Contoh respons (dipotong):

```json
{
  "recipes": [
    {
      "id": 1,
      "name": "Classic Margherita Pizza",
      "ingredients": ["Pizza dough", "Tomato sauce", "Fresh mozzarella cheese"],
      "instructions": ["Preheat the oven to 475°F (245°C).", "Roll out the pizza dough."],
      "prepTimeMinutes": 20,
      "cookTimeMinutes": 15,
      "servings": 4,
      "difficulty": "Easy",
      "cuisine": "Italian",
      "caloriesPerServing": 300,
      "tags": ["Pizza", "Italian"],
      "userId": 166,
      "image": "https://cdn.dummyjson.com/recipe-images/1.webp",
      "rating": 4.6,
      "reviewCount": 98,
      "mealType": ["Dinner"]
    }
  ],
  "total": 50,
  "skip": 0,
  "limit": 30
}
```

**Soal:**

1. Halaman Login dan Register dengan Shared Preferences dan local database.
2. Halaman list resep: tampilkan gambar, nama, cuisine, rating, dan tingkat kesulitan. Judul AppBar menampilkan username yang login. Di pojok kanan AppBar ada tombol ke halaman favorit.
3. Halaman detail: tampilkan **semua** data dari endpoint detail, termasuk daftar bahan (`ingredients`) dan langkah memasak (`instructions`).
4. Tombol favorit: saat ditambahkan, ikon berubah warna dan muncul Snackbar **hijau**. Saat dihapus, ikon kembali dan muncul Snackbar **merah**.
5. Halaman favorit memakai **local database (Hive)**. Resep yang dihapus dari favorit hilang dari list.
6. Filter berdasarkan `mealType` (Breakfast, Lunch, Dinner, Snack, dan seterusnya). **Catatan:** `mealType` adalah list, jadi satu resep bisa muncul di lebih dari satu filter.

**Langkah yang disarankan** (perkiraan waktu):

| Waktu | Kerjakan | File dari Rick & Morty |
| --- | --- | --- |
| 0–15 menit | Buka API di browser, jawab 5 pertanyaan Bagian A, tulis model `Recipe` | `models/character.dart` → `models/recipe.dart` |
| 15–30 menit | API provider: ganti `baseUrl`, list dari key `recipes`, **hapus pagination** | `providers/api_provider.dart` |
| 30–45 menit | Salin auth apa adanya, pastikan login jalan | `modules/auth/*`, `db_helper.dart`, `session_service.dart` |
| 45–75 menit | Halaman list + filter `mealType` + judul AppBar username | `modules/home/*` |
| 75–95 menit | Halaman detail (list bahan dan langkah) | `modules/detail/*` |
| 95–115 menit | Favorit di Hive + Snackbar hijau/merah | `modules/favorite/*`, `db_helper.dart` |
| 115–120 menit | Hapus yang tidak dipakai (`episode`, bottom nav), cek ulang soal satu per satu | |


<details>
<summary><b>Lihat jawaban</b></summary>

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class Recipe {
  final int id;
  final String name;
  final String image;
  final String cuisine;
  final String difficulty;
  final double rating;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int caloriesPerServing;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> mealType;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.cuisine,
    required this.difficulty,
    required this.rating,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.caloriesPerServing,
    required this.ingredients,
    required this.instructions,
    required this.mealType,
    required this.tags,
  });

  static List<String> _strings(dynamic value) =>
      (value as List?)?.map((e) => e.toString()).toList() ?? [];

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '-',
        image: json['image']?.toString() ?? '',
        cuisine: json['cuisine']?.toString() ?? '-',
        difficulty: json['difficulty']?.toString() ?? '-',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
        cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
        servings: (json['servings'] as num?)?.toInt() ?? 0,
        caloriesPerServing: (json['caloriesPerServing'] as num?)?.toInt() ?? 0,
        ingredients: _strings(json['ingredients']),
        instructions: _strings(json['instructions']),
        mealType: _strings(json['mealType']),
        tags: _strings(json['tags']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'cuisine': cuisine,
        'difficulty': difficulty,
        'rating': rating,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'caloriesPerServing': caloriesPerServing,
        'ingredients': ingredients,
        'instructions': instructions,
        'mealType': mealType,
        'tags': tags,
      };
}

class RecipeApi {
  static const baseUrl = 'https://dummyjson.com';

  // { "recipes": [ ... ], "total": 50, "skip": 0, "limit": 30 }
  Future<List<Recipe>> getRecipes() async {
    final res = await http.get(Uri.parse('$baseUrl/recipes?limit=50'));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['recipes'] as List)
        .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Recipe> getRecipe(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/recipes/$id'));
    return Recipe.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}

// Filter berdasarkan mealType (list): satu resep bisa Lunch DAN Dinner.
List<Recipe> filterByMealType(List<Recipe> recipes, String? type) =>
    type == null ? recipes : recipes.where((r) => r.mealType.contains(type)).toList();
```

**Favorit di Hive** (tambahkan di `DbHelper` atau buat service sendiri):

```dart
late Box<Map> _favorites;

Future<void> initFavorites() async {
  _favorites = await Hive.openBox<Map>('favorites');
}

List<Recipe> getFavorites() => _favorites.values
    .map((e) => Recipe.fromJson(Map<String, dynamic>.from(e)))
    .toList();

bool isFavorite(int id) => _favorites.containsKey(id);

Future<void> addFavorite(Recipe r) => _favorites.put(r.id, r.toJson());

Future<void> removeFavorite(int id) => _favorites.delete(id);
```

`Map<String, dynamic>.from(e)` diperlukan karena Hive mengembalikan `Map<dynamic, dynamic>`.

**Snackbar hijau dan merah:**

```dart
Get.snackbar(
  'Favorit',
  '${recipe.name} ditambahkan',
  backgroundColor: Colors.green,   // Colors.red saat dihapus
  colorText: Colors.white,
  snackPosition: SnackPosition.BOTTOM,
);
```

**Daftar chip filter dari data** (karena `mealType` berupa list, pakai `expand`):

```dart
final types = recipes.expand((r) => r.mealType).toSet().toList()..sort();
```

</details>


---

## Template kosong

Salin ini setiap kali dapat API baru, lalu isi berdasarkan jawaban 5 pertanyaan di Bagian A.

```dart
class NamaModel {
  // 1. Satu baris per key di JSON
  final String id;
  final String judul;

  const NamaModel({
    required this.id,
    required this.judul,
  });

  // 2. JSON -> objek (pakai contekan Bagian B untuk tiap tipe)
  factory NamaModel.fromJson(Map<String, dynamic> json) => NamaModel(
        id: json['id'].toString(),
        judul: json['KEY_DI_JSON']?.toString() ?? '-',
      );

  // 3. objek -> JSON (wajib kalau disimpan sebagai favorit)
  Map<String, dynamic> toJson() => {
        'id': id,
        'KEY_DI_JSON': judul,
      };
}

// 4. API provider (pilih bentuk dari Bagian C)
Future<List<NamaModel>> getAll() async {
  final res = await http.get(Uri.parse('$baseUrl/ENDPOINT'));
  final body = jsonDecode(res.body);
  final list = body as List;                // atau body['KEY_LIST'] as List
  return list.map((e) => NamaModel.fromJson(e as Map<String, dynamic>)).toList();
}
```

**Cara cepat mengecek modelnya benar** sebelum membuat tampilan: panggil API sekali, lalu cetak hasilnya di konsol.

```dart
final items = await api.getAll();
print('Jumlah: ${items.length}');
print('Pertama: ${items.first.judul}');
```

Kalau jumlahnya 0 atau muncul error `type 'Null' is not a subtype of ...`, berarti ada nama key atau tipe yang salah. Bandingkan lagi dengan JSON di browser.

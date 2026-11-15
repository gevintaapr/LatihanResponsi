// ====================================================================
// FILE    : lib/app/modules/detail/detail_controller.dart
// LAPISAN : Logika / Detail Screen
//
// GUNANYA :
//   Menerima karakter dari Home (Get.arguments) agar langsung tampil,
//   lalu mengambil data terbaru dari GET /character/{id}.
//
// DIPAKAI OLEH: DetailView.
// ====================================================================

import 'package:get/get.dart';

import '../../data/models/character.dart';
import '../../data/providers/api_provider.dart';

class DetailController extends GetxController {
  final ApiProvider _api = Get.find();

  /// Data awal dari list (langsung tampil), lalu diperbarui dari
  /// endpoint /character/{id}.
  final character = Rxn<Character>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  late final int _id;

  @override
  void onInit() {
    super.onInit();
    // Data yang dikirim dari Home lewat Get.toNamed(Routes.detail, arguments: character).
    final args = Get.arguments;
    if (args is Character) {
      character.value = args;
      _id = args.id;
    } else {
      _id = args is int ? args : 0;
    }
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      // GET /character/{id} untuk data paling baru.
      character.value = await _api.getCharacter(_id);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }
}

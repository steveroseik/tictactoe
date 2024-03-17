import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../Configurations/constants.dart';

final storageProvider = Provider<DataStorage>(
        (ref) => DataStorage(ref));

class DataStorage{

  bool initialized = false;

  ProviderRef<DataStorage> ref;

  late LazyBox box;

  DataStorage(this.ref);

  init() async{
    box = await Hive.openLazyBox(Const.storage);
    initialized = true;
  }

}
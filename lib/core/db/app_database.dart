import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:liko_auto/core/db/converters.dart';
import 'package:liko_auto/core/db/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Favorites,
  ViewHistory,
  MyListings,
  Notifications,
  Bookings,
  Reviews,
  BlockedUsers,
  MutedThreads,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur utilisable dans les tests (in-memory).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'liko_auto.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

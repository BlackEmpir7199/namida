import 'package:get/get.dart';

import 'package:namida/class/folder.dart';
import 'package:namida/class/track.dart';
import 'package:namida/controller/scroll_search_controller.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/core/enums.dart';

class Folders {
  static Folders get inst => _instance;
  static final Folders _instance = Folders._internal();
  Folders._internal();

  final Rxn<Folder> currentFolder = Rxn<Folder>();

  final RxList<Folder> currentFolderslist = <Folder>[].obs;

  List<Track> get currentTracks => currentFolder.value?.tracks ?? [];

  /// Even with this logic, root paths are invincible.
  final RxBool isHome = true.obs;

  /// Used for non-hierarchy.
  final RxBool isInside = false.obs;

  /// Highlights the track that is meant to be navigated to after calling [goToFolder].
  final RxnInt indexToScrollTo = RxnInt();

  void stepIn(Folder? folder, {Track? trackToScrollTo}) {
    if (folder == null || folder.path == '') {
      isHome.value = true;
      isInside.value = false;
      currentFolder.value = null;
      return;
    }
    isHome.value = false;
    isInside.value = true;

    final dirInside = folder.getDirectoriesInside();

    if (dirInside.length == 1 && folder.tracks.isEmpty) {
      stepIn(dirInside.first);
      return;
    }

    currentFolderslist
      ..clear()
      ..addAll(dirInside);

    currentFolder.value = folder;
    if (trackToScrollTo != null) {
      indexToScrollTo.value = folder.tracks.indexOf(trackToScrollTo);
    }
    if (LibraryTab.folders.scrollController.hasClients) {
      LibraryTab.folders.scrollController.jumpTo(0);
    }
  }

  void stepOut() {
    Folder? folder;
    if (SettingsController.inst.enableFoldersHierarchy.value) {
      folder = currentFolder.value?.getParentFolder(fullyFunctional: true);
    }
    indexToScrollTo.value = null;
    stepIn(folder);
  }

  void onFirstLoad() {
    stepIn(Folder(SettingsController.inst.defaultFolderStartupLocation.value));
  }
}

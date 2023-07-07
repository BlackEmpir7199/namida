import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:namida/controller/miniplayer_controller.dart';
import 'package:namida/controller/navigator_controller.dart';
import 'package:namida/controller/player_controller.dart';
import 'package:namida/controller/scroll_search_controller.dart';
import 'package:namida/controller/search_sort_controller.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/namida_converter_ext.dart';
import 'package:namida/core/translations/strings.dart';
import 'package:namida/packages/searchbar_animation.dart';
import 'package:namida/ui/pages/albums_page.dart';
import 'package:namida/ui/pages/artists_page.dart';
import 'package:namida/ui/pages/search_page.dart';
import 'package:namida/ui/pages/settings_page.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/widgets/stats.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size(0, 56.0),
        child: Obx(
          () => AppBar(
              toolbarHeight: 56.0 * (1 - MiniPlayerController.inst.miniplayerHP.value * 0.3),
              leading: NamidaNavigator.inst.currentWidgetStack.length > 1 ? const NamidaBackButton() : const NamidaDrawerButton(),
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              title: NamidaNavigator.inst.currentRoute?.toTitle(),
              actions: NamidaNavigator.inst.currentRoute?.toActions()
              // [
              // NamidaHero(
              //   tag: 'dsfdfds',
              //   child: NamidaIconButton(
              //     padding: const EdgeInsets.only(right: 12.0, left: 10.0),
              //     icon: Broken.ghost,
              //     onPressed: () async {
              //       GoogleSignIn googleSignIn = GoogleSignIn(
              //         scopes: [
              //           'email',
              //           'https://www.googleapis.com/auth/youtube',
              //           'https://www.googleapis.com/auth/youtube.readonly',
              //           'https://www.googleapis.com/auth/youtube.force-ssl',
              //         ],
              //       );
              //       await googleSignIn.signOut();
              //       final acc = await googleSignIn.signIn();
              //       final accessToken = await acc?.authentication.then((value) => value.accessToken);
              //       final accHeaders = await acc?.authHeaders;
              //       print('ACCCCCCCCCC ${acc?.displayName ?? 'NULLLLLLL'}');
              //       print('ACCCCCCCCCC ${accessToken ?? 'NULLLLLLL'}');
              //       YoutubeController.inst.sussyBaka = accessToken ?? '';
              //       // final String url = 'https://www.googleapis.com/youtube/v3/channels?access_token=$accessToken&part=snippet&mine=true';
              //       final String url = 'https://youtube.com/watch?v=o3DHvFyPYRE&bpctr=9999999999&hl=en&access_token=$accessToken';
              //       http.Response response = await http.get(Uri.parse(url), headers: accHeaders);
              //       // print('ACCCCCCCCCC ${response.body.replaceAll('\n', ' ')}');
              //       print('ACCCCCCCCCC ${response.headers.toString()}');
              //       final cookie = Cookie.fromSetCookieValue(response.headers['set-cookie'].toString());
              //       print('ACCCCCCCCCC cookie: ${cookie.name}');
              //       print('ACCCCCCCCCC cookie: ${cookie.value}');
              //       print('ACCCCCCCCCC cookie: ${cookie.path}');
              //       YoutubeController.inst.sussyBakaHeader = response.headers;
              //     },
              //   ),
              // ),
              // ],
              ),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Obx(
            () => Transform.scale(
              scale: 1 - (MiniPlayerController.inst.miniplayerHP.value * 0.05),
              child: WillPopScope(
                onWillPop: () async {
                  await NamidaNavigator.inst.popPage();
                  return false;
                },
                child: Navigator(
                  key: NamidaNavigator.inst.navKey,
                  restorationScopeId: 'namida',
                  requestFocus: false,
                  observers: [NamidaNavigator.inst.heroController],
                  onGenerateRoute: (settings) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      NamidaNavigator.inst.onFirstLoad();
                    });
                    return GetPageRoute(page: () => const SizedBox());
                  },
                ),
              ),
            ),
          ),

          /// Search Box
          Positioned.fill(
            child: Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ScrollSearchController.inst.isGlobalSearchMenuShown.value ? SearchPage() : null,
              ),
            ),
          ),

          /// Bottom Glow/Shadow
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Player.inst.nowPlayingTrack.value == kDummyTrack
                  ? const SizedBox(key: Key('emptyglow'))
                  : Container(
                      key: const Key('actualglow'),
                      height: 28.0,
                      transform: Matrix4.translationValues(0, 8.0, 0),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: context.theme.scaffoldBackgroundColor,
                            spreadRadius: 4.0,
                            blurRadius: 8.0,
                          ),
                        ],
                      ),
                    ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Obx(
        () => !SettingsController.inst.enableBottomNavBar.value
            ? const SizedBox()
            : Transform.translate(
                offset: Offset(0, 64.0 * MiniPlayerController.inst.miniplayerHP.value),
                child: NavigationBar(
                  animationDuration: const Duration(seconds: 1),
                  elevation: 22,
                  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                  height: 64.0,
                  onDestinationSelected: (value) => ScrollSearchController.inst.animatePageController(value.toEnum()),
                  selectedIndex: SettingsController.inst.selectedLibraryTab.value.toInt(),
                  destinations: SettingsController.inst.libraryTabs
                      .map(
                        (e) => NavigationDestination(
                          icon: Icon(e.toIcon()),
                          label: e.toText(),
                        ),
                      )
                      .toList(),
                ),
              ),
      ),
    );
  }
}

class NamidaStatsIcon extends StatelessWidget {
  const NamidaStatsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return NamidaIconButton(
      padding: const EdgeInsets.only(right: 12.0, left: 10.0),
      icon: Broken.chart_21,
      onPressed: () {
        NamidaNavigator.inst.navigateTo(
          SettingsSubPage(
            title: Language.inst.STATS,
            child: const StatsSection(),
          ),
        );
      },
    );
  }
}

class NamidaBackButton extends StatelessWidget {
  const NamidaBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return NamidaIconButton(
      key: const ValueKey('arrowleft'),
      icon: Broken.arrow_left_2,
      onPressed: () => NamidaNavigator.inst.popPage(),
    );
  }
}

class NamidaDrawerButton extends StatelessWidget {
  const NamidaDrawerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return NamidaIconButton(
      key: const ValueKey('drawericon'),
      icon: Broken.menu_1,
      onPressed: () => NamidaNavigator.inst.toggleDrawer(),
    );
  }
}

class NamidaSettingsButton extends StatelessWidget {
  const NamidaSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return NamidaIconButton(
      padding: const EdgeInsets.only(right: 12.0, left: 6.0),
      icon: Broken.setting_2,
      onPressed: () => NamidaNavigator.inst.navigateTo(const SettingsPage()),
    );
  }
}

class NamidaSearchBar extends StatelessWidget {
  const NamidaSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchBarAnimation(
      isSearchBoxOnRightSide: true,
      textAlignToRight: false,
      durationInMilliSeconds: 300,
      enableKeyboardFocus: true,
      isOriginalAnimation: false,
      textEditingController: ScrollSearchController.inst.searchTextEditingController,
      hintText: Language.inst.SEARCH,
      searchBoxWidth: context.width / 1.2,
      buttonColour: Colors.transparent,
      enableBoxShadow: false,
      buttonShadowColour: Colors.transparent,
      hintTextColour: context.theme.colorScheme.onSurface,
      searchBoxColour: context.theme.cardColor.withAlpha(200),
      enteredTextStyle: context.theme.textTheme.displayMedium,
      cursorColour: context.theme.colorScheme.onBackground,
      buttonBorderColour: Colors.black45,
      cursorRadius: const Radius.circular(12.0),
      buttonWidget: IgnorePointer(
        child: NamidaIconButton(
          icon: Broken.search_normal,
          onPressed: () {},
        ),
      ),
      secondaryButtonWidget: IgnorePointer(
        child: NamidaIconButton(
          icon: Broken.search_status_1,
          onPressed: () {},
        ),
      ),
      trailingWidget: NamidaIconButton(
        icon: Broken.close_circle,
        padding: EdgeInsets.zero,
        iconSize: 22,
        onPressed: () => ScrollSearchController.inst.resetSearch(),
      ),
      onTap: () => ScrollSearchController.inst.showSearchMenu(),
      onPressButton: (isOpen) {
        ScrollSearchController.inst.showSearchMenu(isOpen);
        ScrollSearchController.inst.resetSearch();
      },
      onChanged: (value) => SearchSortController.inst.searchAll(value),
    );
  }
}

class AlbumSearchResultsPage extends StatelessWidget {
  const AlbumSearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlbumsPage(
      albums: SearchSortController.inst.albumSearchTemp,
      countPerRow: SettingsController.inst.albumGridCount.value,
    );
  }
}

class ArtistSearchResultsPage extends StatelessWidget {
  const ArtistSearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ArtistsPage(
      artists: SearchSortController.inst.artistSearchTemp,
      countPerRow: SettingsController.inst.artistGridCount.value,
    );
  }
}

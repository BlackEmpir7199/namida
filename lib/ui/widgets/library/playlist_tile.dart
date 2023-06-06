import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:namida/class/playlist.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/dialogs/common_dialogs.dart';
import 'package:namida/ui/widgets/library/multi_artwork_container.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final void Function()? onTap;

  const PlaylistTile({
    super.key,
    required this.playlist,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double playlistThumnailSize = 75;
    const double playlistTileHeight = 75;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: const Color.fromARGB(60, 120, 120, 120),
          onLongPress: () => NamidaDialogs.inst.showPlaylistDialog(playlist),
          onTap: onTap ?? () {},
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            height: playlistTileHeight + 14,
            child: Row(
              children: [
                MultiArtworkContainer(
                  heroTag: 'playlist_artwork_${playlist.name}',
                  size: playlistThumnailSize,
                  tracks: playlist.tracks.map((e) => e.track).toList(),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name.translatePlaylistName(),
                        style: context.textTheme.displayMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        [playlist.tracks.map((e) => e.track).toList().displayTrackKeyword, playlist.creationDate.dateFormatted].join(' • '),
                        style: context.textTheme.displaySmall?.copyWith(fontSize: 13.7.multipliedFontScale),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (playlist.moods.isNotEmpty)
                        Text(
                          playlist.moods.join(', ').overflow,
                          style: context.textTheme.displaySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  playlist.tracks.map((e) => e.track).toList().totalDurationFormatted,
                  style: context.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 2.0),
                MoreIcon(
                  iconSize: 20,
                  onPressed: () => NamidaDialogs.inst.showPlaylistDialog(playlist),
                ),
                const SizedBox(width: 8.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

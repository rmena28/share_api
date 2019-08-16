import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_api/composers/story_composer.dart';
import 'package:share_api/intents/base.dart';
import 'package:share_api/share_result.dart';

class Instagram extends ShareIntent {
  Instagram(MethodChannel channel) : super(channel);
  final String handlerModule = 'instagram';

  Future<int> shareToStory(StoryComposer composer) async {
    try {
      final tempDir = await getTemporaryDirectory();
      String backgroundAssetName;
      String stickerAssetName;
      String backgroundFileName;
      String stickerFileName;

      if (composer.backgroundAsset != null) {
        backgroundAssetName = 'backgroundAsset.jpg';
        final Uint8List backgroundAssetAsList = composer.backgroundAsset;
        final backgroundAssetPath = '${tempDir.path}/$backgroundAssetName';
        final file = await File(backgroundAssetPath).create();
        await file.writeAsBytes(backgroundAssetAsList);
      }

      if (composer.backgroundFile != null) {
        File backgroundFile = File(composer.backgroundFile);
        backgroundFileName = basename(backgroundFile.path);
        final backgroundFilePath = '${tempDir.path}/$backgroundFileName';
        await backgroundFile.copy(backgroundFilePath);
      }

      if (composer.stickerAsset != null) {
        stickerAssetName = 'stickerAsset.png';
        final Uint8List stickerAssetAsList = composer.stickerAsset;
        final stickerAssetPath = '${tempDir.path}/$stickerAssetName';
        final file = await File(stickerAssetPath).create();
        await file.writeAsBytes(stickerAssetAsList);
      }

       if (composer.stickerFile != null) {
        File stickerFile = File(composer.stickerFile);
        stickerFileName = basename(stickerFile.path);
        final backgroundFilePath = '${tempDir.path}/$stickerFileName';
        await stickerFile.copy(backgroundFilePath);
      }


      String topBackgroundColor;
      String bottomBackgroundColor;

      if (composer.topBackgroundColor != null) {
        final sixHexValue = composer.topBackgroundColor.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2);
        topBackgroundColor = '#$sixHexValue';
      }

      if (composer.bottomBackgroundColor != null) {
        final sixHexValue = composer.bottomBackgroundColor.value
            .toRadixString(16)
            .padLeft(8, '0')
            .substring(2);
        bottomBackgroundColor = '#$sixHexValue';
      }

      return await channel.invokeMethod('share', {
        'handler': {
          'module': handlerModule,
          'function': 'shareToStory',
        },
        'arguments': {
          'backgroundAssetName': backgroundAssetName,
          'backgroundFileName': backgroundFileName,
          'backgroundMediaType': composer.backgroundMediaType,
          'stickerAssetName': stickerAssetName,
          'stickerFileName': stickerFileName,
          'stickerMediaType': composer.stickerMediaType,
          'topBackgroundColor': topBackgroundColor,
          'bottomBackgroundColor': bottomBackgroundColor,
          'contentUrl': composer.contentUrl,
        }
      });
    } on Exception catch (e) {
//      throw e;
      print(e);
      return ShareResult.failed;
    }
  }

  @override
  Future<bool> isPackageInstalled() async {
    return await channel.invokeMethod('isInstalled', {
      'handler': {
        'module': handlerModule,
      }
    });
  }
}

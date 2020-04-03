///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/3/20 14:07
///
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetEntityImageProvider extends ImageProvider<AssetEntityImageProvider> {
  AssetEntityImageProvider(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = 150,
    this.isOriginal = true,
  });

  final AssetEntity entity;

  /// Scale for image provider.
  /// 缩放
  final double scale;

  /// Size for thumb data.
  /// 缩略图的大小
  final int thumbSize;

  /// Choose if original data or thumb data should be loaded.
  /// 选择载入原数据还是缩略图数据
  final bool isOriginal;

  ImageFileType _imageFileType;

  ImageFileType get imageFileType => _imageFileType ?? _getType();

  @override
  ImageStreamCompleter load(AssetEntityImageProvider key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<AssetEntityImageProvider>('Image key', key),
        ];
      },
    );
  }

  @override
  Future<AssetEntityImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AssetEntityImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(AssetEntityImageProvider key, DecoderCallback decode) async {
    assert(key == this);
    Uint8List data;
    if (isOriginal ?? false) {
      data = await key.entity.originBytes;
    } else {
      data = await key.entity.thumbDataWithSize(thumbSize, thumbSize);
    }
    return decode(data);
  }

  /// Get image type by reading the file extension.
  /// 从图片后缀判断图片类型
  ///
  /// ⚠ Not all the system version support read file name from the entity, so this method might not
  /// working sometime.
  /// 并非所有的系统版本都支持读取文件名，所以该方法有时无法返回正确的type。
  ImageFileType _getType() {
    ImageFileType type;
    final String extension = entity.title?.split('.')?.last;
    if (extension != null) {
      switch (extension.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          type = ImageFileType.jpg;
          break;
        case 'png':
          type = ImageFileType.png;
          break;
        case 'gif':
          type = ImageFileType.gif;
          break;
        case 'tiff':
          type = ImageFileType.tiff;
          break;
        case 'heic':
          type = ImageFileType.heic;
          break;
        default:
          type = ImageFileType.other;
          break;
      }
    }
    return type;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! AssetEntityImageProvider) {
      return false;
    } else {
      final AssetEntityImageProvider typedOther = other as AssetEntityImageProvider;
      final bool result = entity == typedOther.entity &&
          scale == typedOther.scale &&
          isOriginal == typedOther.isOriginal;
      return result;
    }
  }

  @override
  int get hashCode => hashValues(entity, scale, isOriginal);
}

enum ImageFileType { jpg, png, gif, tiff, heic, other }

enum SpecialAssetType { video, audio, gif, heic }

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liko_auto/core/api/api_client.dart';
import 'package:liko_auto/core/api/api_exception.dart';
import 'package:liko_auto/core/api/app_config.dart';
import 'package:liko_auto/features/listings/domain/api_listing.dart';

class ListingFilters {
  const ListingFilters({
    this.status,
    this.brandId,
    this.modelId,
    this.cityId,
    this.minPrice,
    this.maxPrice,
    this.query,
  });

  final ListingStatus? status;
  final int? brandId;
  final int? modelId;
  final int? cityId;
  final int? minPrice;
  final int? maxPrice;
  final String? query;

  Map<String, dynamic> toQueryParams() => {
        if (status != null) 'status': status!.name,
        if (brandId != null) 'brandId': brandId,
        if (modelId != null) 'modelId': modelId,
        if (cityId != null) 'cityId': cityId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
      };

  bool get isEmpty =>
      status == null &&
      brandId == null &&
      modelId == null &&
      cityId == null &&
      minPrice == null &&
      maxPrice == null;
}

class ListingsRepository {
  const ListingsRepository(this._api);
  final ApiClient _api;

  Future<List<ApiListing>> getListings([ListingFilters? filters]) async {
    final params = filters?.toQueryParams();
    final res = await _api.get<List<dynamic>>(
      AppConfig.listings,
      queryParameters: params?.isNotEmpty ?? false ? params : null,
    );
    return (res.data ?? [])
        .cast<Map<String, dynamic>>()
        .map(ApiListing.fromJson)
        .toList();
  }

  Future<ApiListing> getListing(int id) async {
    final res =
        await _api.get<Map<String, dynamic>>(AppConfig.listing(id));
    return ApiListing.fromJson(res.data!);
  }

  /// Crée une annonce avec ses photos via multipart/form-data.
  Future<ApiListing> postListingWithMedia({
    required CreateListingRequest listing,
    required List<File> photos,
  }) async {
    try {
      final multipartPhotos = <MultipartFile>[];
      for (final photo in photos) {
        multipartPhotos.add(
          await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split(RegExp(r'[/\\]')).last,
          ),
        );
      }

      final formData = FormData.fromMap({
        'listing': listing.toJson().toString(),
        if (multipartPhotos.isNotEmpty) 'photos': multipartPhotos,
      });

      final res = await _api.post<Map<String, dynamic>>(
        AppConfig.listingsWithMedia,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final body = res.data!;
      final listingJson = body['listing'] as Map<String, dynamic>;
      return ApiListing.fromJson(listingJson);
    } on ApiException {
      rethrow;
    }
  }
}

final listingsRepositoryProvider = Provider<ListingsRepository>(
  (ref) => ListingsRepository(ref.watch(apiClientProvider)),
);

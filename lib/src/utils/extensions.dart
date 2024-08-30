import 'package:collection/collection.dart';
import 'package:recs_front/generated/inputs.gq.dart';

extension OnString on String? {
  bool isBlank() {
    return this == null || this!.trim().isEmpty;
  }
}

extension SkuSearchParamsExtension on SkuSearchParam {
  bool isEqualTo(SkuSearchParam other) {
    return other == this ||
        (other.productId == productId &&
            other.name == name &&
            other.brand == brand &&
            other.skuId == skuId &&
            const ListEquality().equals(other.categoryIds, categoryIds));
  }

  bool isEmpty() {
    return ((productId?.isEmpty ?? true) &&
        (skuId?.isEmpty ?? true) &&
        (name?.isEmpty ?? true) &&
        (brand?.isEmpty ?? true) &&
        (categoryIds?.isEmpty ?? true));
  }
}

extension ProductSearchParamsExtension on ProductParamSearch {
  bool isEqualTo(ProductParamSearch other) {
    return other == this ||
        (other.productId == productId &&
            other.name == name &&
            other.brand == brand &&
            const ListEquality().equals(other.categoryIds, categoryIds));
  }

  bool isEmpty() {
    return ((productId?.isEmpty ?? true) &&
        (name?.isEmpty ?? true) &&
        (brand?.isEmpty ?? true) &&
        (categoryIds?.isEmpty ?? true));
  }
}

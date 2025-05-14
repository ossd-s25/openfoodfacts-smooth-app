import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/pages/nutripatrol/report_image.dart';
import 'package:smooth_app/pages/product/common/product_refresher.dart';

class ReportPageLoader {
  const ReportPageLoader._();

  /// Shows the report image page.
  static Future<void> showReportPage({
    required final Product product,
    required final bool isLoggedInMandatory,
    required final BuildContext context,
    required final ImageField imageField,
  }) async {
    if (!await ProductRefresher().checkIfLoggedIn(
      context,
      isLoggedInMandatory: isLoggedInMandatory,
    )) {
      return;
    }
    if (context.mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ReportImage(
              language: OpenFoodFactsLanguage.ENGLISH,
              imageField: imageField,
              product: product),
        ),
      );
    }
  }
}
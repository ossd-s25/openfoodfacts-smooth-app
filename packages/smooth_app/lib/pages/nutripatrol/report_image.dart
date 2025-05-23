import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

// We have to have our own enums here, since Nutripatrol doesn't have externally obtainable reasons for reporting
enum ReportReason {
  photoNotMatching,
  photoNotMatchingAndContinuingWithReport,
  inappropriate,
  outdated,
  includes_personal_infos,
  duplicate,
  other
}

extension ReportReasonUserText on ReportReason {
  String get userText {
    switch (this) {
      case ReportReason.photoNotMatching ||
            ReportReason.photoNotMatchingAndContinuingWithReport:
        return 'Photo does not match product';
      case ReportReason.inappropriate:
        return 'Photo is inappropriate';
      case ReportReason.other:
        return 'Other reason';
      case ReportReason.outdated:
        return 'Outdated';
      case ReportReason.includes_personal_infos:
        return 'Includes personal information';
      case ReportReason.duplicate:
        return 'Duplicate';
    }
  }
}

extension ToString on ReportReason {
  String get name {
    switch (this) {
      case ReportReason.photoNotMatching ||
            ReportReason.photoNotMatchingAndContinuingWithReport ||
            ReportReason.other:
        return 'other';
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.outdated:
        return 'outdated';
      case ReportReason.includes_personal_infos:
        return 'includes_personal_infos';
      case ReportReason.duplicate:
        return 'duplicate';
    }
  }
}

class ReportImageState extends State<ReportImage> {
  ReportReason? reportReason;
  String reportExplanation = '';

  @override
  Widget build(BuildContext context) {
    ProductImage? productImage = widget.product.images
        ?.firstWhere((image) => image.field == widget.imageField);

    if (productImage?.contributor == null) {
      final ProductImage? replacement = widget.product.images?.firstWhereOrNull(
          (image) =>
              image.imgid == productImage?.imgid && image.contributor != null);
      if (replacement != null) {
        productImage = replacement;
      }
    }

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: const Text('Report an Image'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SmoothCardWithRoundedHeader(
            title: 'Image to report',
            leading: const icons.Flag(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 12.0,
                children: [
                  ProductPicture.fromProduct(
                    imageField: widget.imageField,
                    product: widget.product,
                    size: const Size(50, 50),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image to Report',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (productImage != null)
                        Text(
                            'Contributor: ${productImage.contributor ?? 'unknown'}'),
                      Text(
                          'Date uploaded: ${productImage?.uploaded != null ? DateFormat('yyyy-MM-dd').format(productImage!.uploaded!) : 'unknown'}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SmoothCardWithRoundedHeader(
            title: 'Reason',
            leading: const Text('1'),
            trailing: SmoothCardHeaderButton(
                tooltip: 'Expand',
                child: const icons.Edit(),
                onTap: () {
                  setState(() {
                    reportReason = null;
                  });
                }),
            child: Builder(
              builder: (BuildContext context) {
                if (reportReason == null) {
                  return Column(
                    children: [
                      for (final ReportReason reason in ReportReason.values)
                        if (reason !=
                            ReportReason
                                .photoNotMatchingAndContinuingWithReport)
                          SmoothButtonWithArrow(
                              text: reason.userText,
                              onTap: () => {
                                    setState(() {
                                      reportReason = reason;
                                    })
                                  }),
                    ],
                  );
                } else {
                  return SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Text(reportReason!.userText),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          if (reportReason == ReportReason.photoNotMatching ||
              reportReason ==
                  ReportReason.photoNotMatchingAndContinuingWithReport)
            SmoothCardWithRoundedHeader(
              title: 'Explanation',
              leading: const Text('2'),
              contentPadding: const EdgeInsets.all(12),
              trailing: SmoothCardHeaderButton(
                  tooltip: 'Expand',
                  child: const icons.Edit(),
                  onTap: () {
                    setState(() {
                      reportReason = ReportReason.photoNotMatching;
                    });
                  }),
              child: Builder(
                builder: (BuildContext context) {
                  if (reportReason ==
                      ReportReason.photoNotMatchingAndContinuingWithReport) {
                    return const SizedBox(
                      width: double.infinity,
                      child: Text('Continue making a report'),
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        const Text(
                            'Open Food Facts is a user maintained database with over 3 million products (according to Wikipedia).'),
                        const Text(
                            'If you own this product, you can take a photo of it to correct the product details.'),
                        SmoothButtonWithArrow(
                            text: 'Take a picture of the product',
                            onTap: () => {print('To be implemented...')}),
                        SmoothButtonWithArrow(
                          text: 'Continue making a report',
                          onTap: () => {
                            setState(() {
                              reportReason = ReportReason
                                  .photoNotMatchingAndContinuingWithReport;
                            })
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          const SizedBox(
            height: 12,
          ),
          if (reportReason != null &&
              reportReason != ReportReason.photoNotMatching)
            SmoothCardWithRoundedHeader(
              contentPadding: EdgeInsets.zero,
              title: 'Comment',
              leading: Text(reportReason ==
                      ReportReason.photoNotMatchingAndContinuingWithReport
                  ? '3'
                  : '2'),
              child: TextFormField(
                initialValue: reportExplanation,
                minLines: null,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: LARGE_SPACE,
                    vertical: SMALL_SPACE,
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: ROUNDED_BORDER_RADIUS,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: ROUNDED_BORDER_RADIUS,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 5.0,
                    ),
                  ),
                ),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onChanged: (String value) {
                  setState(() {
                    reportExplanation = value;
                  });
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: SmoothButtonsBar2(
        negativeButton: SmoothActionButton2(
          text: 'Cancel',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        positiveButton: SmoothActionButton2(
          text: 'Submit',
          onPressed: () {
            const UriHelper nutriPatrolAPISubmitUriHelper =
                UriHelper(host: 'nutripatrol.openfoodfacts.net');

            final Uri nutriPatrolAPISubmitURI =
                nutriPatrolAPISubmitUriHelper.getPostUri(path: 'api/v1/flags');

            final User currentUser = ProductQuery.getWriteUser();

            if (reportReason == null ||
                productImage?.url == null ||
                productImage?.imgid == null) {
              return;
            }

            HttpHelper().doPostRequest(
                nutriPatrolAPISubmitURI,
                {
                  'type': 'image',
                  'url': productImage!.url!,
                  'user_id': currentUser.userId,
                  'source': 'mobile',
                  'image_id': productImage.imgid!,
                  'reason': reportReason!.name,
                  'comment': reportExplanation,
                },
                currentUser,
                uriHelper: nutriPatrolAPISubmitUriHelper,
                addCredentialsToBody: false);

            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class ReportImage extends StatefulWidget {
  const ReportImage(
      {required this.imageField, required this.product, super.key});

  final ImageField imageField;
  final Product product;

  @override
  State<StatefulWidget> createState() {
    return ReportImageState();
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/generic_lib/bottom_sheets/smooth_bottom_sheet.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';
import 'package:smooth_app/widgets/v2/smooth_leading_button.dart';
import 'package:smooth_app/widgets/v2/smooth_scaffold2.dart';
import 'package:smooth_app/widgets/v2/smooth_topbar2.dart';

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
    return SmoothScaffold2(
      topBar: const SmoothTopBar2(
        title: 'Report an Image',
        leadingAction: SmoothLeadingAction.close,
        reducedHeightOnScroll: true,
      ),
      padding: const EdgeInsets.all(MEDIUM_SPACE),
      bottomBar: SmoothButtonsBar2(
        negativeButton: SmoothActionButton2(
          text: 'Cancel',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        positiveButton: SmoothActionButton2(
          text: 'Submit',
          onPressed: submitAction,
        ),
      ),
      children: [
        SliverToBoxAdapter(
          child: SmoothCardWithRoundedHeader(
            title: 'Image to report',
            leading: const icons.Flag(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(MEDIUM_SPACE, 0, MEDIUM_SPACE, MEDIUM_SPACE),
              child: Row(
                spacing: MEDIUM_SPACE,
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
                      if (widget.productImage != null)
                        Text(
                            'Contributor: ${widget.productImage?.contributor ?? 'unknown'}'),
                      Text(
                          'Date uploaded: ${widget.productImage?.uploaded != null ? DateFormat('yyyy-MM-dd').format(widget.productImage!.uploaded!) : 'unknown'}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: MEDIUM_SPACE,
          ),
        ),
        SliverToBoxAdapter(
          child: SmoothCardWithRoundedHeader(
            title: 'Reason',
            leading: const Text(
              '1',
              style: TextStyle(color: Colors.black),
            ),
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
                          Builder(builder: (BuildContext context) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(reason.userText),
                                  onTap: () => {
                                    setState(() {
                                      reportReason = reason;
                                    })
                                  },
                                  trailing: const icons.Chevron.right(
                                      size: DEFAULT_ICON_SIZE / 2),
                                ),
                                if (reason != ReportReason.values.last)
                                  const Divider(),
                              ],
                            );
                          })
                    ],
                  );
                } else {
                  return SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          MEDIUM_SPACE, 0, MEDIUM_SPACE, MEDIUM_SPACE),
                      child: Text(reportReason!.userText),
                    ),
                  );
                }
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: MEDIUM_SPACE,
          ),
        ),
        if (reportReason == ReportReason.photoNotMatching ||
            reportReason ==
                ReportReason.photoNotMatchingAndContinuingWithReport)
          SliverToBoxAdapter(
            child: SmoothCardWithRoundedHeader(
              title: 'Explanation',
              leading: const Text(
                '2',
                style: TextStyle(color: Colors.black),
              ),
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
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              MEDIUM_SPACE, 0, MEDIUM_SPACE, MEDIUM_SPACE),
                          child: Text('Continue making a report')),
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
                          child: Column(
                            children: [
                              Text(
                                  'Open Food Facts is a user maintained database with over 3 million products (according to Wikipedia).'),
                              Text(
                                  'If you own this product, you can take a photo of it to correct the product details.'),
                            ],
                          ),
                        ),
                        ListTile(
                          title: const Text('Take a picture of the product'),
                          onTap: () => {
                            Navigator.pop(context)
                          },
                          trailing: const icons.Chevron.right(
                              size: DEFAULT_ICON_SIZE / 2),
                        ),
                        const Divider(),
                        ListTile(
                          title: const Text('Continue making a report'),
                          onTap: () => {
                            setState(() {
                              reportReason = ReportReason
                                  .photoNotMatchingAndContinuingWithReport;
                            })
                          },
                          trailing: const icons.Chevron.right(
                              size: DEFAULT_ICON_SIZE / 2),
                        )
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: MEDIUM_SPACE,
          ),
        ),
        if (reportReason != null &&
            reportReason != ReportReason.photoNotMatching)
          SliverToBoxAdapter(
            child: SmoothCardWithRoundedHeader(
              contentPadding: EdgeInsets.zero,
              title: 'Comment',
              leading: Text(
                reportReason ==
                        ReportReason.photoNotMatchingAndContinuingWithReport
                    ? '3'
                    : '2',
                style: TextStyle(color: Colors.black),
              ),
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
          ),
      ],
    );
  }

  Future<void> submitAction() async {
    final Uri nutriPatrolAPISubmitURI =
        Uri.https('nutripatrol.openfoodfacts.org', 'api/v1/flags');

    final User currentUser = ProductQuery.getWriteUser();

    if (reportReason == null ||
        widget.productImage?.imgid == null ||
        currentUser.cookie == null ||
        widget.product.barcode == null) {
      return;
    }

    final jsonData = {
      'type': 'image',
      'url': widget.productImage?.getUrl(widget.product.barcode!),
      'user_id': currentUser.userId,
      'source': 'mobile',
      'image_id': widget.productImage?.imgid,
      'reason': reportReason!.name,
      'comment': reportExplanation,
      'flavor': 'off',
      'barcode': widget.product.barcode,
    };

    try {
      // TODO(andylin2004): we should probably have a seperate nutripatrol library to abstract things like this out
      final response = await http.post(nutriPatrolAPISubmitURI,
          headers: {
            'Content-Type': 'application/json',
            'Cookie': currentUser.cookie!
          },
          body: json.encode(jsonData));

      if (context.mounted) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          await showSmoothModalSheet(
            context: context,
            builder: (BuildContext context) {
              return SmoothModalSheet(
                title: 'Report sent!',
                body: const Column(
                  spacing: MEDIUM_SPACE,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: icons.Check()),
                    Text('Thank you for your report!'),
                    Text('This report will soon be reviewed by our moderators.')
                  ],
                ),
              );
            },
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Server error: ${response.statusCode}: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class ReportImage extends StatefulWidget {
  const ReportImage(
      {required this.imageField, required this.product, super.key});

  final ImageField imageField;
  final Product product;

  ProductImage? get productImage {
    ProductImage? candidate =
        product.images?.firstWhere((image) => image.field == imageField);

    candidate = product.images?.firstWhere(
      (image) => image.imgid == candidate?.imgid && image.contributor != null,
      orElse: () {
        return candidate!;
      },
    );

    return candidate;
  }

  @override
  State<StatefulWidget> createState() {
    return ReportImageState();
  }
}

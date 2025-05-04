import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_image.dart';
import 'package:smooth_app/database/transient_file.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/pages/preferences/user_preferences_dev_mode.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

enum ReportReason {
  photoNotMatching,
  photoNotMatchingAndContinuingWithReport,
  inappropriatePhoto,
  other
}

class ReportImageState extends State<ReportImage> {
  ReportReason? reportReason;
  String reportExplanation = '';

  @override
  Widget build(BuildContext context) {
    final TransientFile transientFile = _getTransientFile(
      widget.product,
      widget.imageField,
    );

    return SmoothScaffold(
      appBar: SmoothAppBar(
        title: const Text('Report an Image'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          SmoothCardWithRoundedHeader(
            title: 'Image to report',
            leading: const icons.Flag(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 12.0,
                children: [
                  ProductPicture.fromTransientFile(
                    product: widget.product,
                    imageField: widget.imageField,
                    language: widget.language,
                    allowAlternativeLanguage: false,
                    transientFile: transientFile,
                    size: const Size(50, 50),
                    onTap: null,
                    errorTextStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    heroTag: ProductPicture.generateHeroTag(
                      widget.product.barcode!,
                      widget.imageField,
                    ),
                    showObsoleteIcon: false,
                    showOwnerIcon: true,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image to Report',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text('Contributor: xxxxx'),
                      const Text('Date uploaded: 01/01/2000'),
                      Text(reportExplanation),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          SmoothCardWithRoundedHeader(
            title: 'Reason',
            leading: const Text('1'),
            child: Column(
              children: [
                SmoothButtonWithArrow(
                    text: 'Photo does not match product',
                    onTap: () => {
                          setState(() {
                            reportReason = ReportReason.photoNotMatching;
                          })
                        }),
                SmoothButtonWithArrow(
                    text: 'Photo is inappropriate',
                    onTap: () => {
                          setState(() {
                            reportReason = ReportReason.inappropriatePhoto;
                          })
                        }),
                SmoothButtonWithArrow(
                    text: 'Other reason',
                    onTap: () => {
                          setState(() {
                            reportReason = ReportReason.other;
                          })
                        }),
              ],
            ),
          ),
          SizedBox(
            height: 12,
          ),
          if (reportReason == ReportReason.photoNotMatching ||
              reportReason ==
                  ReportReason.photoNotMatchingAndContinuingWithReport)
            SmoothCardWithRoundedHeader(
              title: 'Explanation',
              leading: const Text('2'),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
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
                            })
                  ],
                ),
              ),
            ),
          SizedBox(
            height: 12,
          ),
          if (reportReason != null &&
              reportReason != ReportReason.photoNotMatching)
            SmoothCardWithRoundedHeader(
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
                // spellCheckConfiguration: (prefs.getFlag(
                //                 UserPreferencesDevMode
                //                     .userPreferencesFlagSpellCheckerOnOcr) ??
                //             false) &&
                //         (Platform.isAndroid || Platform.isIOS)
                //     ? const SpellCheckConfiguration()
                //     : const SpellCheckConfiguration.disabled(),
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
          text: "Cancel",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        positiveButton: SmoothActionButton2(
          text: "Submit",
          onPressed: () {
            print("Submitted");
          },
        ),
      ),
    );
  }

  TransientFile _getTransientFile(
    final Product product,
    final ImageField imageField,
  ) =>
      TransientFile.fromProduct(
        product,
        imageField,
        widget.language,
      );
}

class ReportImage extends StatefulWidget {
  const ReportImage(
      {required this.language,
      required this.imageField,
      required this.product,
      super.key});

  final OpenFoodFactsLanguage language;
  final ImageField imageField;
  final Product product;

  @override
  State<StatefulWidget> createState() {
    return ReportImageState();
  }
}

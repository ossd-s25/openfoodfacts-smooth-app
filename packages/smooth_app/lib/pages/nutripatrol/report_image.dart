import 'package:flutter/widgets.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_list_diff.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

enum ReportReason { photoNotMatching, inappropriatePhoto, other }

class ReportImageState extends State<ReportImage> {
  ReportReason? reportReason;

  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text("Report an Image"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SmoothCardWithRoundedHeader(
                title: "Image to report",
                leading: icons.Flag(),
                child: Row(
                  children: [Text("A"), Text("B")],
                ),
              ),
              SmoothCardWithRoundedHeader(
                title: "Reason",
                leading: const Text("1"),
                child: Column(
                  children: [
                    SmoothButtonWithArrow(
                        text: "Photo does not match product",
                        onTap: () => {
                              setState(() {
                                reportReason = ReportReason.photoNotMatching;
                              })
                            }),
                    SmoothButtonWithArrow(
                        text: "Photo is inappropriate",
                        onTap: () => {
                              setState(() {
                                reportReason = ReportReason.inappropriatePhoto;
                              })
                            }),
                    SmoothButtonWithArrow(
                        text: "Other reason",
                        onTap: () => {
                              setState(() {
                                reportReason = ReportReason.other;
                              })
                            }),
                  ],
                ),
              ),
              if (reportReason == ReportReason.photoNotMatching)
                const SmoothCardWithRoundedHeader(
                  title: "Explanation",
                  leading: Text("2"),
                  child: Row(
                    children: [const Text("A"), const Text("B")],
                  ),
                ),
              SmoothCardWithRoundedHeader(
                title: "Comment",
                leading: Text(
                    reportReason == ReportReason.photoNotMatching ? "3" : "2"),
                child: const Row(
                  children: [Text("A"), Text("B")],
                ),
              ),
            ],
          ),
        ));
  }
}

class ReportImage extends StatefulWidget {
  const ReportImage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ReportImageState();
  }
}

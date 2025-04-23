import 'package:flutter/widgets.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_button_with_arrow.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/widgets/smooth_app_bar.dart';
import 'package:smooth_app/widgets/smooth_list_diff.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/resources/app_icons.dart' as icons;

class ReportImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SmoothScaffold(
        appBar: SmoothAppBar(
          title: Text("Report an Image"),
        ),
        body: Padding(padding: const EdgeInsets.all(20), child: Column(
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
                    SmoothButtonWithArrow(text: "Photo does not match product", onTap: () => {
                      print("Pressed 1")
                    }),
                    SmoothButtonWithArrow(text: "Photo is inappropriate", onTap: () => {
                      print("Pressed 2")
                    }),
                    SmoothButtonWithArrow(text: "Other reason", onTap: () => {
                      print("Pressed 3")
                    }),
                  ],
                ),
              ),
              const SmoothCardWithRoundedHeader(
                title: "Explanation",
                leading: Text("2"),
                child: Row(
                  children: [Text("A"), Text("B")],
                ),
              ),
              const SmoothCardWithRoundedHeader(
                title: "Comment",
                leading: Text("3"),
                child: Row(
                  children: [Text("A"), Text("B")],
                ),
              ),
            ],
        ),));
  }
}

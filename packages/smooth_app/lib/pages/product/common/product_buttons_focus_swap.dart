import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

/// A button bar containing three actions : Save, previous field, and next field
/// To ensure a fully working scroll, please set the [fixKeyboard] attribute in
/// the [SmoothScaffold] to [true]
class ProductBottomFocusSwapButtonsBar extends StatelessWidget {
  const ProductBottomFocusSwapButtonsBar({
    this.prevField,
    this.nextField,
    required this.onSave,
    super.key,
  });

  final VoidCallback? prevField;
  final VoidCallback? nextField;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return SmoothButtonsBar2(
      positiveButton: SmoothActionButton2(
        text: appLocalizations.save,
        onPressed: onSave,
      ),
    );
  }
}

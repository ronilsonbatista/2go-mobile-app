import 'package:flutter/material.dart';
import '../../tokens/colors.dart';

/// A form scaffold managing [SafeArea], [MediaQueryData.viewInsets], soft keyboard adaptation,
/// and smooth scrolling behavior.
class TwoGoKeyboardAwareScaffold extends StatelessWidget {
  const TwoGoKeyboardAwareScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? TwoGoColors.backgroundPrimary,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(child: body),
              ),
            );
          },
        ),
      ),
    );
  }
}

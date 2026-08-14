import 'package:baktaz_flutter/app/generated/assets.gen.dart';
import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_flutter/core/presentation/views/pages/empty_page.dart';
import 'package:baktaz_flutter/core/presentation/widgets/baktaz_app_bar.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colorScheme.surface,
    appBar: BaktazAppBar(
      backgroundColor: context.colorScheme.surface,
      centerTitle: true,
      title: 'Reviews',
      leading: const BackButton(),
    ),
    body: EmptyPage(title: 'No Reviews', iconPath: Assets.images.noReviews.path),
  );
}

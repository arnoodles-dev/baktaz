import 'package:baktaz_flutter/app/helpers/extensions/build_context_ext.dart';
import 'package:baktaz_shared/baktaz_shared.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_multi_formatter/widgets/country_flag.dart';

class CountrySelectorBottomSheet extends StatelessWidget {
  const CountrySelectorBottomSheet({super.key});

  static PhoneCountryData get defaultCountry => PhoneCodes.getPhoneCountryDataByCountryCode('PH')!;

  List<PhoneCountryData> get phoneCountryDataList => PhoneCodes.getAllCountryDatas()
    ..sort((PhoneCountryData a, PhoneCountryData b) {
      final String cleanedA = removeParentheses(a.country);
      final String cleanedB = removeParentheses(b.country);

      return cleanedA.compareTo(cleanedB);
    })
    ..removeWhere((PhoneCountryData data) => data == defaultCountry)
    ..insert(0, defaultCountry);

  String removeParentheses(String? str) => str?.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '') ?? '';

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      GestureDetector(onTap: () => Navigator.pop(context)),
      Padding(
        padding: EdgeInsets.only(bottom: context.viewInsets.bottom),
        child: DraggableScrollableSheet(
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) => Container(
            decoration: ShapeDecoration(
              color: context.colorScheme.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(BaktazRadius.xl),
                  topRight: Radius.circular(BaktazRadius.xl),
                ),
              ),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: _CountrySelectorList(phoneCountryDataList, scrollController: scrollController),
            ),
          ),
        ),
      ),
    ],
  );
}

class _CountrySelectorList extends HookWidget {
  const _CountrySelectorList(this.phoneCountryDataList, {this.scrollController});
  final List<PhoneCountryData> phoneCountryDataList;
  final ScrollController? scrollController;

  static List<PhoneCountryData> filterPhoneCountryDataList({
    required List<PhoneCountryData> phoneCountryDataList,
    required String value,
  }) {
    if (value.isNotEmpty) {
      return phoneCountryDataList
          .where(
            (PhoneCountryData country) =>
                (country.phoneCode?.toLowerCase() ?? '').contains(value.toLowerCase()) ||
                (country.country?.toLowerCase() ?? '').contains(value.toLowerCase()) ||
                (country.countryCode?.toLowerCase() ?? '').contains(value.toLowerCase()),
          )
          .toList();
    }

    return phoneCountryDataList;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = useTextEditingController();
    final ValueNotifier<List<PhoneCountryData>> filteredPhoneCountryDataList = useState<List<PhoneCountryData>>(
      <PhoneCountryData>[],
    );

    useEffect(() {
      final String value = searchController.text.trim();
      filteredPhoneCountryDataList.value = filterPhoneCountryDataList(
        phoneCountryDataList: phoneCountryDataList,
        value: value,
      );

      return null;
    }, <Object?>[]);

    return Padding(
      padding: Paddings.allLarge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BaktazText(text: context.i18n.common.select_country, style: context.textTheme.titleLarge),
          Gap.large(),
          BaktazTextField(
            labelText: context.i18n.common.search.capitalize(),
            controller: searchController,
            padding: EdgeInsets.zero,
            autofocus: true,
            onChanged: (String value) {
              final String value = searchController.text.trim();
              filteredPhoneCountryDataList.value = filterPhoneCountryDataList(
                phoneCountryDataList: phoneCountryDataList,
                value: value,
              );
            },
          ),
          Gap.large(),
          Flexible(
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                        _CountrySelectorListTile(phoneCountryData: filteredPhoneCountryDataList.value[index]),
                    childCount: filteredPhoneCountryDataList.value.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountrySelectorListTile extends StatelessWidget {
  const _CountrySelectorListTile({required this.phoneCountryData});
  final PhoneCountryData phoneCountryData;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CountryFlag(countryId: phoneCountryData.countryCode ?? ''),
    title: Align(
      alignment: AlignmentDirectional.centerStart,
      child: BaktazText(
        text: phoneCountryData.country ?? '',
        textAlign: TextAlign.start,
        style: context.textTheme.titleMedium,
      ),
    ),
    subtitle: Align(
      alignment: AlignmentDirectional.centerStart,
      child: BaktazText(text: '+${phoneCountryData.phoneCode ?? ''}', textAlign: TextAlign.start),
    ),
    onTap: () => Navigator.of(context).pop(phoneCountryData),
  );
}

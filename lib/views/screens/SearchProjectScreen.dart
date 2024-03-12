import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class SearchProjectScreen extends StatefulWidget {
  const SearchProjectScreen({Key? key}) : super(key: key);

  @override
  State<SearchProjectScreen> createState() => _SearchProjectScreenState();
}

class _SearchProjectScreenState extends State<SearchProjectScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  // late Future<List<dynamic>> _futureProjects;
  late Future<List<dynamic>> _futureProjects;

  @override
  void initState() {
    super.initState();
    _futureProjects = ApiService.fetchAllProjects();

    _dataSource = DataSource(
      onDetailButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewproject}?projectid=${data['ProjectID']}'),
      onDeleteButtonPressed: (data) {},
      data: [],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;

    return PortalMasterLayout(
      body: FutureBuilder<List<dynamic>>(
        future: _futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<dynamic> projects = snapshot.data!;
            _dataSource = DataSource(
              onDetailButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewproject}?projectid=${data['ProjectID']}'),
              onDeleteButtonPressed: (data) {},
              data: projects,
            );
            return ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                Text(
                  'Search Project',
                  style: themeData.textTheme.headlineMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CardHeader(
                          title: 'Project List',
                        ),
                        CardBody(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                child: FormBuilder(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      direction: Axis.horizontal,
                                      spacing: kDefaultPadding,
                                      runSpacing: kDefaultPadding,
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 300.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                            child: FormBuilderTextField(
                                              name: 'search',
                                              decoration: const InputDecoration(
                                                labelText: 'search',
                                                hintText: 'search',
                                                border: OutlineInputBorder(),
                                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: kDefaultPadding),
                                              child: SizedBox(
                                                height: 40.0,
                                                child: ElevatedButton(
                                                  style: themeData.extension<AppButtonTheme>()!.infoElevated,
                                                  onPressed: () {},
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                        child: Icon(
                                                          Icons.search,
                                                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                        ),
                                                      ),
                                                      const Text("Search"),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 40.0,
                                              child: ElevatedButton(
                                                style: themeData.extension<AppButtonTheme>()!.successElevated,
                                                onPressed: () => GoRouter.of(context).go(RouteUri.createproject),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                      ),
                                                    ),
                                                    const Text("New"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);
                                    return Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        controller: _scrollController,
                                        child: SizedBox(
                                          width: dataTableWidth,
                                          child: Theme(
                                            data: themeData.copyWith(
                                              cardTheme: appDataTableTheme.cardTheme,
                                              dataTableTheme: appDataTableTheme.dataTableThemeData,
                                            ),
                                            child: PaginatedDataTable(
                                              source: _dataSource,
                                              rowsPerPage: 20,
                                              showCheckboxColumn: false,
                                              showFirstLastButtons: true,
                                              columns: const [
                                                DataColumn(label: Text('ProjectID'), numeric: true),
                                                DataColumn(label: Text('CodeByRTC')),
                                                DataColumn(label: Text('ProjectTitle')),
                                                DataColumn(label: Text('ProjectStatus')),
                                                DataColumn(label: Text('TotalPoints')),
                                                DataColumn(label: Text('Actions')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class DataSource extends DataTableSource {
  final void Function(Map<String, dynamic> data) onDetailButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;
  final List<dynamic> data;

  DataSource({
    required this.onDetailButtonPressed,
    required this.onDeleteButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['CodeByRTC'].toString())),
      DataCell(Text(data['ProjectTitle'].toString())),
      DataCell(Text(data['ProjectStatus'].toString())),
      DataCell(Text(data['TotalPoints'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onDetailButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: const Text("Detail"),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(data),
                style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                child: const Text("Delete"),
              ),
            ],
          );
        },
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

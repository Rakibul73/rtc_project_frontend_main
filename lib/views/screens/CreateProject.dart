import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_asset_picker/form_builder_asset_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/generated/l10n.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:rtc_project_fronend/views/widgets/url_new_tab_launcher.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey_1 = GlobalKey<FormBuilderState>();
  final _formKey_2 = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // final lang = Lang.of(context);
    final List<Widget> fields = [];
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            "Research Proposal Application Form",
            style: themeData.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(
                      title: "This research proposal must be submitted according to the following format",
                      backgroundColor: Color.fromARGB(255, 139, 161, 168),
                      titleColor: Color.fromARGB(255, 50, 39, 42)),
                  CardBody(
                    child: FormBuilder(
                      key: _formKey_1,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: (kDefaultPadding * 22),
                                      child: FormBuilderTextField(
                                        name: 'RTC_Code',
                                        decoration: const InputDecoration(
                                          labelText: 'Code number of the project to be assigned by RTC',
                                          hintText: 'RTC Code',
                                          border: OutlineInputBorder(),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                        ),
                                        validator: FormBuilderValidators.required(),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          width: (kDefaultPadding * 22),
                                          child: FormBuilderDateTimePicker(
                                            name: 'date_of_received',
                                            onChanged: (value) {},
                                            inputType: InputType.date,
                                            decoration: const InputDecoration(
                                              labelText: 'Date of Received',
                                              border: OutlineInputBorder(),
                                            ),
                                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                                            initialValue: DateTime.now(),
                                            textAlign: TextAlign.center,
                                            format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CardHeader(title: "Part I: Research Proposal Identification Data", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                  CardBody(
                    child: FormBuilder(
                      key: _formKey_2,
                      autovalidateMode: AutovalidateMode.disabled,
                      clearValueOnUnregister: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: (kDefaultPadding * 50),
                                      child: FormBuilderTextField(
                                        name: 'project_title',
                                        decoration: const InputDecoration(
                                          labelText: 'Project Title',
                                          hintText: 'Project Title',
                                          border: OutlineInputBorder(),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                        ),
                                        validator: FormBuilderValidators.required(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDropdown(
                                          name: 'name_of_collaborating_department_institute',
                                          decoration: const InputDecoration(
                                            labelText: 'Name of Collaborating Department / Institute',
                                            border: OutlineInputBorder(),
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hintText: 'Select',
                                          ),
                                          focusColor: Colors.transparent,
                                          validator: FormBuilderValidators.required(),
                                          items: [
                                            'Faculty of Agriculture',
                                            'Faculty of Computer Science and Engineering',
                                            'Faculty of Business Administration',
                                            'Faculty of Animal Science and Veterinary Medicine',
                                            'Faculty of Fisheries',
                                            'Faculty of Environmental Science and Disaster Management',
                                            'Faculty of Nutrition and Food Science',
                                            'Faculty of Law and Land Administration'
                                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'address_of_collaborating_department_institute',
                                          decoration: const InputDecoration(
                                            labelText: 'Address of Collaborating Department / Institute',
                                            hintText: 'Address of Collaborating Department / Institute',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: FormBuilderCheckboxGroup(
                                        name: 'checkbox_group_horizontal',
                                        wrapSpacing: kDefaultPadding,
                                        orientation: OptionsOrientation.vertical,
                                        decoration: const InputDecoration(
                                          labelText: 'Nature of The Research Proposal',
                                          border: OutlineInputBorder(),
                                        ),
                                        options: const [
                                          FormBuilderFieldOption(value: 'Coordinated', child: Text('Coordinated')),
                                          FormBuilderFieldOption(value: 'Independent', child: Text('Independent')),
                                          FormBuilderFieldOption(value: 'Fundamental', child: Text('Fundamental')),
                                          FormBuilderFieldOption(value: 'Applied', child: Text('Applied')),
                                          FormBuilderFieldOption(value: 'Interdisciplinary', child: Text('Interdisciplinary')),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              name: 'location_of_field_activities',
                              decoration: const InputDecoration(
                                labelText: 'Location Of Field Activities',
                                hintText: '(Please specify major location(s) of research activities such as laboratory, farm, farmer’s field etc.)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateRangePicker(
                                          name: 'annual_duration_of_research_project',
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime(2030),
                                          format: DateFormat('MMMM d, yyyy'),
                                          onChanged: (value) {},
                                          decoration: const InputDecoration(
                                            labelText: 'Annual Duration Of Research Project',
                                            hintText: 'Annual Duration Of Research Project',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateRangePicker(
                                          name: 'long_term_duration_of_research_project',
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime(2030),
                                          format: DateFormat('MMMM d, yyyy'),
                                          onChanged: (value) {},
                                          decoration: const InputDecoration(
                                            labelText: 'Long-term Duration Of Research Project',
                                            hintText: 'Long-term Duration Of Research Project',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'total_budget_of_research_proposal',
                                          decoration: const InputDecoration(
                                            prefixText: '৳ ',
                                            labelText: 'Total Budget Of Research Proposal',
                                            hintText: '(Taka)',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderChoiceChip(
                                          name: 'has_this_proposal_been_submitted_to_any_other_agency',
                                          spacing: kDefaultPadding * 0.5,
                                          runSpacing: kDefaultPadding * 0.5,
                                          selectedColor: appColorScheme.warning,
                                          decoration: const InputDecoration(
                                            labelText: 'Has This Proposal Been Submitted To Any Other Agency For Financial Assistance?',
                                            border: OutlineInputBorder(),
                                          ),
                                          options: const [
                                            FormBuilderChipOption(value: 'Submitted', child: Text('Submitted')),
                                            FormBuilderChipOption(value: 'Not Submitted', child: Text('Not Submitted')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {}); // Trigger rebuild when choice changes
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      if (_formKey_2.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted')
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: FormBuilderTextField(
                                            name: 'name_of_the_agency',
                                            decoration: const InputDecoration(
                                              labelText: 'Name of The Agency',
                                              hintText: 'Name of the agency',
                                              border: OutlineInputBorder(),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                            validator: FormBuilderValidators.required(),
                                          ),
                                        ),
                                      if (_formKey_2.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted')
                                        const SizedBox(height: 15),
                                      if (_formKey_2.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted')
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: FormBuilderDateTimePicker(
                                            name: 'date_of_submission',
                                            onChanged: (value) {},
                                            inputType: InputType.date,
                                            decoration: const InputDecoration(
                                              labelText: 'Date Of Submission',
                                              border: OutlineInputBorder(),
                                            ),
                                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                                            // initialValue: DateTime.now(),
                                            textAlign: TextAlign.center,
                                            format: DateFormat("EEEE, MMMM d, yyyy"),
                                          ),
                                        ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderChoiceChip(
                                          name: 'is_there_any_commitment_to_other_research_project_as_pi_team_leader',
                                          spacing: kDefaultPadding * 0.5,
                                          runSpacing: kDefaultPadding * 0.5,
                                          selectedColor: appColorScheme.warning,
                                          decoration: const InputDecoration(
                                            labelText: 'Is There Any Commitment to Other Research Project(S) as PI / Team Leader?',
                                            border: OutlineInputBorder(),
                                          ),
                                          options: const [
                                            FormBuilderChipOption(value: 'Yes', child: Text('Yes')),
                                            FormBuilderChipOption(value: 'No', child: Text('No')),
                                          ],
                                          onChanged: (value) {
                                            setState(() {}); // Trigger rebuild when choice changes
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      if (_formKey_2.currentState?.fields['is_there_any_commitment_to_other_research_project_as_pi_team_leader']?.value == 'Yes')
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: FormBuilderTextField(
                                            name: 'name_of_the_project',
                                            decoration: const InputDecoration(
                                              labelText: 'Name of The Project',
                                              hintText: 'Name of The Project',
                                              border: OutlineInputBorder(),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                            validator: FormBuilderValidators.required(),
                                          ),
                                        ),
                                    ]),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewTextField extends StatelessWidget {
  const NewTextField({
    super.key,
    required this.name,
    this.onDelete,
  });
  final String name;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: name,
              validator: FormBuilderValidators.minLength(4),
              decoration: const InputDecoration(
                label: Text('New field'),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

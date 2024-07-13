// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:bijoy_helper/bijoy_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/screens/admin/project_overview/ViewProjectScreenAdmin.dart' as admin;
import 'package:rtc_project_fronend/views/screens/user/project_panel/ViewProjectScreen.dart' as user;
import 'package:rtc_project_fronend/views/screens/general/profile/MyProfileScreen.dart' as userprofile;
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ApplyForMonitoringScreen.dart' as usermonitoringreport;
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/FeedbackMonitoringReportScreen.dart' as usermonitoringreportwithfeedback;
import 'package:rtc_project_fronend/views/screens/general/fund_panel/ViewRequestForAProjectFundScreen.dart' as viewfund;
import 'package:rtc_project_fronend/views/screens/general/fund_panel/ViewRequestForAProjectAdvanceFundScreen.dart' as viewadvancefund;
import 'dart:html' as html;
import 'package:http/http.dart' as http;

Future<pw.Widget> generateImageWidget(Uint8List? fileBytes, width, height) async {
  final image = pw.MemoryImage(fileBytes!);
  return pw.Image(image, width: width, height: height, alignment: pw.Alignment.center, fit: pw.BoxFit.fill);
}

Future<void> generateProjectProposalPDFAdmin(admin.FormData formData, BuildContext context, Uint8List? methodologyFileBytes, Uint8List? piSignatureFileBytes, Uint8List? piSealFileBytes,
    Uint8List? chairmanSignatureFileBytes, Uint8List? chairmanSealFileBytes, List<dynamic> initialProjectGantts, List<dynamic> initialProjectBudget) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  // final fontBoldItalic = await rootBundle.load("fonts/times-new-roman-bold-italic.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final fontItalic = await rootBundle.load("fonts/times-new-roman-italic.ttf");
  final fontSymbola = await rootBundle.load("fonts/Symbola.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfItalic = pw.Font.ttf(fontItalic);
  final ttfBold = pw.Font.ttf(fontBold);
  // final ttfBoldItalic = pw.Font.ttf(fontBoldItalic);
  final ttfSymbola = pw.Font.ttf(fontSymbola);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  final methodologyimage = await generateImageWidget(methodologyFileBytes, 500.0, 500.0);
  final piSignatureimage = await generateImageWidget(piSignatureFileBytes, 200.0, 40.0);
  final piSealimage = await generateImageWidget(piSealFileBytes, 200.0, 40.0);
  final chairmanSignatureimage = await generateImageWidget(chairmanSignatureFileBytes, 200.0, 40.0);
  final chairmanSealimage = await generateImageWidget(chairmanSealFileBytes, 200.0, 40.0);

  List<pw.Widget> widgets = [];

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "RESEARCH PROPOSAL APPLICATION FORM",
            style: pw.TextStyle(font: ttfBold, fontSize: 12, decoration: pw.TextDecoration.underline, decorationThickness: 2.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "This research proposal must be submitted according to the following format",
            style: pw.TextStyle(
              font: ttfItalic,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.5, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 16),
            child: pw.Text(
              "Code number of the project to be assigned by RTC",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 16),
            child: pw.Text(
              "Date of Received",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (5.0),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 13),
            child: pw.Container(
              width: 150,
              height: 27,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('000000'), // Black border color
                  width: 0.5, // Border width
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  formData.rtcCode,
                  style: pw.TextStyle(fontSize: 12.0, font: ttfGeneral), // Adjust the font size as needed
                ),
              ),
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 6),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 9),
            child: pw.Container(
              width: 150,
              height: 27,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('000000'), // Black border color
                  width: 0.5, // Border width
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  formData.dateOfReceived,
                  style: pw.TextStyle(fontSize: 12.0, font: ttfGeneral), // Adjust the font size as needed
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.01, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 32),
            child: pw.Text(
              "-------------------------------------------------------------------------------------------------------------------",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.start,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 28),
            child: pw.Text(
              "PART I: RESEARCH PROPOSAL IDENTIFICATION DATA",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.RichText(
              textAlign: pw.TextAlign.start,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '1. TITLE:  ',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                  pw.TextSpan(
                    text: formData.projectTitle,
                    style: pw.TextStyle(
                      font: ttfGeneral,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.RichText(
              textAlign: pw.TextAlign.start,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '2. NATURE OF THE RESEARCH PROPOSAL ',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                  pw.TextSpan(
                    text: "(check appropriate ones):",
                    style: pw.TextStyle(
                      font: ttfGeneral,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.natureOfTheResearchProposal == 'Applied')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent c) Fundamental ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " d) Applied",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Coordinated')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: "a) Coordinated ",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: "b) Independent c) Fundamental d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Independent')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " b) Independent",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " c) Fundamental d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Fundamental')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " c) Fundamental",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Interdisciplinary')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent c) Fundamental d) Applied',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              '3. NAME(S) AND ADDRESS (S) OF COLLABORATING DEPARTMENT(S)/ INSTITUTE(S) (If any):',
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.nameOfCollaboratingDepartmentDepartment,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.nameOfCollaboratingDepartmentInstitute,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.addressOfCollaboratingDepartmentInstitute,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "4. LOCATION OF FIELD ACTIVITIES:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "(Please specify major location(s) of research activities such as laboratory, farm, farmer’s field etc.)",
              style: pw.TextStyle(
                font: ttfItalic,
                fontSize: 12,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.locationOfFieldActivities,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "5. DURATION OF RESEARCH PROJECT:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "a) Annual: From…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.annualDurationOfResearchProject.split(" - ")[0])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "…………To…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.annualDurationOfResearchProject.split(" - ")[1])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "b) Long term: From…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.longTermDurationOfResearchProject.split(" - ")[0])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "…………To…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.longTermDurationOfResearchProject.split(" - ")[1])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "6. TOTAL BUDGET OF RESEARCH PROPOSAL (TK.): ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "………${formData.totalBudgetOfResearchProposal}/=………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "7. HAS THIS PROPOSAL BEEN SUBMITTED TO ANY OTHER AGENCY FOR FINANCIAL ASSISTANCE?",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.hasThisProposalBeenSubmittedToAnyOtherAgency == "Submitted")
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(
                "Yes",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
              pw.Text(
                "Name of the agency: ………… ${formData.nameOfTheAgency}",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
              pw.Text(
                "Date of submission: ………… ${DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.dateOfSubmission))}",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
            ])
          else
            pw.Text(
              "No",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "8. IS THERE ANY COMMITMENT TO OTHER RESEARCH PROJECT(S) AS PRINCIPAL INVESTIGATOR/TEAM LEADER?",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader == "Yes")
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Yes",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.Text(
                  "Name of the project: …… ${formData.nameOfTheProject}",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            )
          else
            pw.Text(
              "No",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 28),
            child: pw.Text(
              "PART II: OUTLINE OF THE RESEARCH PROPOSAL:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "9. INTRODUCTION, IDENTIFICATION OF PROBLEM AND JUSTIFICATION OF THE RESEARCH PROPOSAL: (300 Words Maximum)",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
  ]);
  final introductionResearchProposal = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.introductionResearchProposal,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final specificObjectivesProposaltitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "10. SPECIFIC OBJECTIVES OF THE PROPOSAL:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final specificObjectivesProposal = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.specificObjectivesProposal,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final relevanceStrategicDevelopmentGoalstitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "11. RELEVANCE TO THE STRATEGIC PLAN OF PSTU AND NATIONAL DEVELOPMENT GOALS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final relevanceStrategicDevelopmentGoals = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.relevanceStrategicDevelopmentGoals,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final briefReviewAlreadyPerformedReferencestitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "12. BRIEF REVIEW OF WORKS ALREADY PERFORMED OR IN PROGRESS ELSE WHERE WITH LIST OF REFERENCES: (Maximum 500 Words):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final briefReviewAlreadyPerformedReferences = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.briefReviewAlreadyPerformedReferences,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final methodologytitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "13. METHODOLOGY: (Please provide A - Z)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz2 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.methodology,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final methodologyImage = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        methodologyimage,
      ],
    ),
  );
  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "14. EXPECTED OUTPUTS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz5 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.expectedOutputs,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "15. SUCCESS INDICATORS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz7 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.successIndicators,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "16. BENEFICIARIES:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz9 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.beneficiaries,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "17. ACTIVITY PLAN/GANTT CHART (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "YEAR 1:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(width: 130),
        pw.Container(
          width: 15,
          height: 15,
          color: PdfColors.green,
        ),
        pw.Text(
          " = Completed Task",
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 11,
            lineSpacing: 1.5,
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Container(
          width: 15,
          height: 15,
          color: PdfColors.red,
        ),
        pw.Text(
          " = Ongoing Task",
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 11,
            lineSpacing: 1.5,
          ),
        ),
      ],
    ),
  );

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final convertedTasks = convertTasks(initialProjectGantts);
  List<pw.TableRow> buildTableRows(List<Map<String, dynamic>> tasks) {
    // Define months
    final List<String> months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    // Define table header
    final headerRow = pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: pw.SizedBox(height: (kDefaultPadding * 3), width: (kDefaultPadding * 5), child: pw.Text('Work/Activity', style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5))),
          ),
        ),
        ...months.map((month) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                pw.SizedBox(
                    height: 20,
                    width: 15,
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Transform.rotate(
                        angle: 1.5708, // 90 degrees counter-clockwise in radians
                        child: pw.Text(
                          textAlign: pw.TextAlign.center,
                          month,
                          style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5),
                        ),
                      ),
                    ])),
              ]),
            )),
      ],
    );

    // Define table data rows
    final dataRows = tasks.map((task) {
      final taskName = task['Activity'].toString();
      final startDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['StartDate']);
      final endDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['EndDate']);
      final status = task['ActivityStatus'] == 'Completed';

      return pw.TableRow(
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.SizedBox(width: (kDefaultPadding * 5), child: pw.Text(taskName, style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5))),
            ),
          ),
          ...months.map((month) {
            var monthIndex = (months.indexOf(month) + 7) % 12; // Adjusted index
            if (monthIndex == 0) {
              monthIndex = 12;
            }
            final isWithinRange = monthIndex >= startDate.month && monthIndex <= endDate.month;

            // Check if the task status is completed
            if (isWithinRange && status) {
              // Cell within range and task completed, color green
              return pw.Container(
                width: 15,
                height: taskName.length * 1.25,
                color: PdfColors.green,
              );
            } else if (isWithinRange && !status) {
              // Cell within range but task not completed, color red
              return pw.Container(
                width: 15,
                height: taskName.length * 1.25,
                color: PdfColors.red,
              );
            } else {
              return pw.Container(
                width: 15,
                // height: 40,
              );
            }
          }),
        ],
      );
    }).toList();

    return [headerRow, ...dataRows];
  }

  final ganttChart = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Table(
            border: pw.TableBorder.all(),
            children: buildTableRows(convertedTasks),
          ),
        ),
      ],
    ),
  );
  final zzz12 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "18. INPUTS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final List<Map<String, String>> data = [
    {'Input': 'Input', 'Existing': "Existing", 'Required': "Required"},
    {'Input': 'A) MAN POWER:', 'Existing': formData.manPowerExisting, 'Required': formData.manPowerRequired},
    {'Input': 'B) SMALL EQUIPMENT:', 'Existing': formData.smallEquipmentExisting, 'Required': formData.smallEquipmentRequired},
    {'Input': 'C) RESEARCH MATERIALS:', 'Existing': formData.researchMaterialsExisting, 'Required': formData.researchMaterialsRequired},
    {'Input': 'D) OTHERS:', 'Existing': formData.othersExisting, 'Required': formData.othersRequired},
  ];
  final inputs = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.topLeft},
            border: pw.TableBorder.all(),
            data: data.map((row) => [row['Input'], row['Existing'], row['Required']]).toList(),
          ),
        ),
      ],
    ),
  );

  final zzz13 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "19. BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final convertedBudget = convertTasks(initialProjectBudget);
  // Calculate the Grand Total by summing up the 'TotalCost' column values
  double grandTotal = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  final budget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudget
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );
  final zzz14 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Signature of the Principal Investigator:  ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.piSignatureLocation.isNotEmpty) piSignatureimage,
      ],
    ),
  );
  final zzz15 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 5.0),
          child: pw.Text(
            "Date & Seal:   ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 7.0),
          child: pw.Text(
            formData.piSignatureDate,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.piSealLocation.isNotEmpty) piSealimage,
      ],
    ),
  );
  final zzz16 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "Comments of the Chairman of the Department: ………………………………",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz17 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.commentsOfTheChairmanOfTheDepartment,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz18 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Signature of the Chairman of the Department: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.chairmanOfDepartmentSignatureFileLocation.isNotEmpty) chairmanSignatureimage,
      ],
    ),
  );
  final zzz19 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 5.0),
          child: pw.Text(
            "Date & Seal:   ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 7.0),
          child: pw.Text(
            formData.dateOfChairmanOfTheDepartment,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.chairmanOfDepartmentSealFileLocation.isNotEmpty) chairmanSealimage,
      ],
    ),
  );
  final zzz20 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "PATR III:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
  final zzz21 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "A. BRIEF INFORMATION OF THE PRINCIPAL INVESTIGATOR (PI)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz22 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Name and Address including phone & email: ",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz23 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piPositionEnglish,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteLocation,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.piEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.piPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz24 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Salary Scale: ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piSalaryScale,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  // calculate current year running
  DateTime now = DateTime.now();
  int currentYear = now.year;
  final zzz25 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Basic pay in June $currentYear : ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piBasicPay,
            style: pw.TextStyle(font: ttfGeneral, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz26 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Highest Academic Qualification (University, Country, Year):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz27 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualification,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationUniversity,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationCountry,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationYear,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz28 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Area of Expertise:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz29 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piAreaOfExpertise,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz30 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Experience in Research:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.piExperienceInResearch}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years and ",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Teaching Experience:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.piExperienceInTeaching}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz31 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "References of latest Publications (Maximum 5):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz32 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.piReferencesOfLatestPublications,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 0.2,
      wordSpacing: 1.5,
    ),
  );
  final zzz33 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "B. BRIEF INFORMATION OF THE CO-PRINCIPAL INVESTIGATOR (CO-PI)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz34 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Name and Address including phone & email: ",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz35 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiPositionEnglish,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiInstituteLocation,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.coPiEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.coPiPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz36 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Salary Scale: ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.coPiSalaryScale,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz37 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Basic pay in June $currentYear : ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.coPiBasicPay,
            style: pw.TextStyle(font: ttfGeneral, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz38 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Highest Academic Qualification (University, Country, Year):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz39 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualification,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationUniversity,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationCountry,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationYear,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz40 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Area of Expertise:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz41 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiAreaOfExpertise,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz42 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Experience in Research:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.coPiExperienceInResearch}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years and ",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Teaching Experience:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.coPiExperienceInTeaching}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz43 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "References of latest Publications (Maximum 5):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz44 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.coPiReferencesOfLatestPublications,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 2,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz45 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "C. STUDENT’S INFORMATION (FOR CODE: 4829): (MS/PhD)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz46 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Name:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………${formData.studentName}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz47 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Reg. No.:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………${formData.studentRegNo}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "ID:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "………………${formData.studentId}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz48 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "First Enrollment Semester:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "…………${formData.firstEnrollmentSemester}……",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz49 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "CGPA at Undergraduate Level:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "…………${formData.cgpaUndergraduateLevel}……",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz);
  widgets.add(introductionResearchProposal);
  widgets.add(specificObjectivesProposaltitle);
  widgets.add(specificObjectivesProposal);
  widgets.add(relevanceStrategicDevelopmentGoalstitle);
  widgets.add(relevanceStrategicDevelopmentGoals);
  widgets.add(briefReviewAlreadyPerformedReferencestitle);
  widgets.add(briefReviewAlreadyPerformedReferences);
  widgets.add(methodologytitle);
  widgets.add(zzz2);
  if (formData.methodologyFileLocation.isNotEmpty) {
    widgets.add(methodologyImage);
  }
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz9);
  widgets.add(zzz10);
  widgets.add(zzz11);
  widgets.add(zzzz11);
  widgets.add(ganttChart);
  widgets.add(zzz12);
  widgets.add(inputs);
  widgets.add(zzz13);
  widgets.add(budget);
  widgets.add(zzz14);
  widgets.add(zzz15);
  widgets.add(zzz16);
  widgets.add(zzz17);
  widgets.add(zzz18);
  widgets.add(zzz19);
  widgets.add(zzz20);
  widgets.add(zzz21);
  widgets.add(zzz22);
  widgets.add(zzz23);
  widgets.add(zzz24);
  widgets.add(zzz25);
  widgets.add(zzz26);
  widgets.add(zzz27);
  widgets.add(zzz28);
  widgets.add(zzz29);
  widgets.add(zzz30);
  widgets.add(zzz31);
  widgets.add(zzz32);
  widgets.add(zzz33);
  widgets.add(zzz34);
  widgets.add(zzz35);
  widgets.add(zzz36);
  widgets.add(zzz37);
  widgets.add(zzz38);
  widgets.add(zzz39);
  widgets.add(zzz40);
  widgets.add(zzz41);
  widgets.add(zzz42);
  widgets.add(zzz43);
  widgets.add(zzz44);
  widgets.add(zzz45);
  widgets.add(zzz46);
  widgets.add(zzz47);
  widgets.add(zzz48);
  widgets.add(zzz49);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'Project_Proposal_${formData.piName}_ProjectID_${formData.projectID}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);

  // html.window.open(url, '_blank');
}

Future<void> generateProjectProposalPDFUser(user.FormData formData, BuildContext context, Uint8List? methodologyFileBytes, Uint8List? piSignatureFileBytes, Uint8List? piSealFileBytes,
    Uint8List? chairmanSignatureFileBytes, Uint8List? chairmanSealFileBytes, List<dynamic> initialProjectGantts, List<dynamic> initialProjectBudget) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final fontItalic = await rootBundle.load("fonts/times-new-roman-italic.ttf");
  final fontSymbola = await rootBundle.load("fonts/Symbola.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfItalic = pw.Font.ttf(fontItalic);
  final ttfBold = pw.Font.ttf(fontBold);
  final ttfSymbola = pw.Font.ttf(fontSymbola);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  final methodologyimage = await generateImageWidget(methodologyFileBytes, 500.0, 500.0);
  final piSignatureimage = await generateImageWidget(piSignatureFileBytes, 200.0, 40.0);
  final piSealimage = await generateImageWidget(piSealFileBytes, 200.0, 40.0);
  final chairmanSignatureimage = await generateImageWidget(chairmanSignatureFileBytes, 200.0, 40.0);
  final chairmanSealimage = await generateImageWidget(chairmanSealFileBytes, 200.0, 40.0);

  List<pw.Widget> widgets = [];

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "RESEARCH PROPOSAL APPLICATION FORM",
            style: pw.TextStyle(font: ttfBold, fontSize: 12, decoration: pw.TextDecoration.underline, decorationThickness: 2.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "This research proposal must be submitted according to the following format",
            style: pw.TextStyle(
              font: ttfItalic,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.5, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 16),
            child: pw.Text(
              "Code number of the project to be assigned by RTC",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 16),
            child: pw.Text(
              "Date of Received",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (5.0),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 13),
            child: pw.Container(
              width: 150,
              height: 27,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('000000'), // Black border color
                  width: 0.5, // Border width
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  formData.rtcCode,
                  style: pw.TextStyle(fontSize: 12.0, font: ttfGeneral), // Adjust the font size as needed
                ),
              ),
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 6),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 9),
            child: pw.Container(
              width: 150,
              height: 27,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColor.fromHex('000000'), // Black border color
                  width: 0.5, // Border width
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  formData.dateOfReceived,
                  style: pw.TextStyle(fontSize: 12.0, font: ttfGeneral), // Adjust the font size as needed
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.01, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 32),
            child: pw.Text(
              "-------------------------------------------------------------------------------------------------------------------",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.start,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 28),
            child: pw.Text(
              "PART I: RESEARCH PROPOSAL IDENTIFICATION DATA",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.RichText(
              textAlign: pw.TextAlign.start,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '1. TITLE:  ',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                  pw.TextSpan(
                    text: formData.projectTitle,
                    style: pw.TextStyle(
                      font: ttfGeneral,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.RichText(
              textAlign: pw.TextAlign.start,
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '2. NATURE OF THE RESEARCH PROPOSAL ',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                  pw.TextSpan(
                    text: "(check appropriate ones):",
                    style: pw.TextStyle(
                      font: ttfGeneral,
                      fontSize: 11,
                      lineSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.natureOfTheResearchProposal == 'Applied')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent c) Fundamental ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " d) Applied",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Coordinated')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: "a) Coordinated ",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: "b) Independent c) Fundamental d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Independent')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " b) Independent",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " c) Fundamental d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Fundamental')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent ',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " c) Fundamental",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " d) Applied e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (formData.natureOfTheResearchProposal == 'Interdisciplinary')
            pw.SizedBox(
              width: (kDefaultPadding * 29),
              child: pw.RichText(
                textAlign: pw.TextAlign.start,
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'a) Coordinated b) Independent c) Fundamental d) Applied',
                      style: pw.TextStyle(
                        font: ttfGeneral,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: '√',
                      style: pw.TextStyle(
                        font: ttfSymbola,
                        fontSize: 11,
                        lineSpacing: 1.5,
                      ),
                    ),
                    pw.TextSpan(
                      text: " e) Interdisciplinary",
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 12,
                        lineSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              '3. NAME(S) AND ADDRESS (S) OF COLLABORATING DEPARTMENT(S)/ INSTITUTE(S) (If any):',
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.nameOfCollaboratingDepartmentDepartment,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.nameOfCollaboratingDepartmentInstitute,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.addressOfCollaboratingDepartmentInstitute,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "4. LOCATION OF FIELD ACTIVITIES:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "(Please specify major location(s) of research activities such as laboratory, farm, farmer’s field etc.)",
              style: pw.TextStyle(
                font: ttfItalic,
                fontSize: 12,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              formData.locationOfFieldActivities,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "5. DURATION OF RESEARCH PROJECT:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "a) Annual: From…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.annualDurationOfResearchProject.split(" - ")[0])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "…………To…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.annualDurationOfResearchProject.split(" - ")[1])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "b) Long term: From…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.longTermDurationOfResearchProject.split(" - ")[0])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "…………To…………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.longTermDurationOfResearchProject.split(" - ")[1])),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "6. TOTAL BUDGET OF RESEARCH PROPOSAL (TK.): ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
          pw.Text(
            "………${formData.totalBudgetOfResearchProposal}/=………",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "7. HAS THIS PROPOSAL BEEN SUBMITTED TO ANY OTHER AGENCY FOR FINANCIAL ASSISTANCE?",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.hasThisProposalBeenSubmittedToAnyOtherAgency == "Submitted")
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text(
                "Yes",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
              pw.Text(
                "Name of the agency: ………… ${formData.nameOfTheAgency}",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
              pw.Text(
                "Date of submission: ………… ${DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.dateOfSubmission))}",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 11,
                  lineSpacing: 1.5,
                ),
              ),
            ])
          else
            pw.Text(
              "No",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "8. IS THERE ANY COMMITMENT TO OTHER RESEARCH PROJECT(S) AS PRINCIPAL INVESTIGATOR/TEAM LEADER?",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader == "Yes")
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Yes",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.Text(
                  "Name of the project: …… ${formData.nameOfTheProject}",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            )
          else
            pw.Text(
              "No",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 28),
            child: pw.Text(
              "PART II: OUTLINE OF THE RESEARCH PROPOSAL:",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              "9. INTRODUCTION, IDENTIFICATION OF PROBLEM AND JUSTIFICATION OF THE RESEARCH PROPOSAL: (300 Words Maximum)",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    ),
  ]);
  final introductionResearchProposal = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.introductionResearchProposal,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final specificObjectivesProposaltitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "10. SPECIFIC OBJECTIVES OF THE PROPOSAL:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final specificObjectivesProposal = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.specificObjectivesProposal,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final relevanceStrategicDevelopmentGoalstitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "11. RELEVANCE TO THE STRATEGIC PLAN OF PSTU AND NATIONAL DEVELOPMENT GOALS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final relevanceStrategicDevelopmentGoals = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.relevanceStrategicDevelopmentGoals,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final briefReviewAlreadyPerformedReferencestitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "12. BRIEF REVIEW OF WORKS ALREADY PERFORMED OR IN PROGRESS ELSE WHERE WITH LIST OF REFERENCES: (Maximum 500 Words):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final briefReviewAlreadyPerformedReferences = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.briefReviewAlreadyPerformedReferences,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final methodologytitle = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "13. METHODOLOGY: (Please provide A - Z)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz2 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.methodology,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final methodologyImage = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        methodologyimage,
      ],
    ),
  );
  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "14. EXPECTED OUTPUTS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz5 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.expectedOutputs,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "15. SUCCESS INDICATORS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz7 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.successIndicators,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "16. BENEFICIARIES:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz9 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.beneficiaries,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "17. ACTIVITY PLAN/GANTT CHART (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "YEAR 1:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(width: 130),
        pw.Container(
          width: 15,
          height: 15,
          color: PdfColors.green,
        ),
        pw.Text(
          " = Completed Task",
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 11,
            lineSpacing: 1.5,
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Container(
          width: 15,
          height: 15,
          color: PdfColors.red,
        ),
        pw.Text(
          " = Ongoing Task",
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 11,
            lineSpacing: 1.5,
          ),
        ),
      ],
    ),
  );

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final convertedTasks = convertTasks(initialProjectGantts);
  List<pw.TableRow> buildTableRows(List<Map<String, dynamic>> tasks) {
    // Define months
    final List<String> months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    // Define table header
    final headerRow = pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: pw.SizedBox(height: (kDefaultPadding * 3), width: (kDefaultPadding * 5), child: pw.Text('Work/Activity', style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5))),
          ),
        ),
        ...months.map((month) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                pw.SizedBox(
                    height: 20,
                    width: 15,
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Transform.rotate(
                        angle: 1.5708, // 90 degrees counter-clockwise in radians
                        child: pw.Text(
                          textAlign: pw.TextAlign.center,
                          month,
                          style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5),
                        ),
                      ),
                    ])),
              ]),
            )),
      ],
    );

    // Define table data rows
    final dataRows = tasks.map((task) {
      final taskName = task['Activity'].toString();
      final startDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['StartDate']);
      final endDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['EndDate']);
      final status = task['ActivityStatus'] == 'Completed';

      return pw.TableRow(
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.SizedBox(width: (kDefaultPadding * 5), child: pw.Text(taskName, style: pw.TextStyle(font: ttfGeneral, fontSize: 10, lineSpacing: 1.5))),
            ),
          ),
          ...months.map((month) {
            var monthIndex = (months.indexOf(month) + 7) % 12; // Adjusted index
            if (monthIndex == 0) {
              monthIndex = 12;
            }
            final isWithinRange = monthIndex >= startDate.month && monthIndex <= endDate.month;

            // Check if the task status is completed
            if (isWithinRange && status) {
              // Cell within range and task completed, color green
              return pw.Container(
                width: 15,
                height: taskName.length * 1.25,
                color: PdfColors.green,
              );
            } else if (isWithinRange && !status) {
              // Cell within range but task not completed, color red
              return pw.Container(
                width: 15,
                height: taskName.length * 1.25,
                color: PdfColors.red,
              );
            } else {
              return pw.Container(
                width: 15,
                // height: 40,
              );
            }
          }),
        ],
      );
    }).toList();

    return [headerRow, ...dataRows];
  }

  final ganttChart = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Table(
            border: pw.TableBorder.all(),
            children: buildTableRows(convertedTasks),
          ),
        ),
      ],
    ),
  );
  final zzz12 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "18. INPUTS:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final List<Map<String, String>> data = [
    {'Input': 'Input', 'Existing': "Existing", 'Required': "Required"},
    {'Input': 'A) MAN POWER:', 'Existing': formData.manPowerExisting, 'Required': formData.manPowerRequired},
    {'Input': 'B) SMALL EQUIPMENT:', 'Existing': formData.smallEquipmentExisting, 'Required': formData.smallEquipmentRequired},
    {'Input': 'C) RESEARCH MATERIALS:', 'Existing': formData.researchMaterialsExisting, 'Required': formData.researchMaterialsRequired},
    {'Input': 'D) OTHERS:', 'Existing': formData.othersExisting, 'Required': formData.othersRequired},
  ];
  final inputs = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.topLeft},
            border: pw.TableBorder.all(),
            data: data.map((row) => [row['Input'], row['Existing'], row['Required']]).toList(),
          ),
        ),
      ],
    ),
  );

  final zzz13 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "19. BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final convertedBudget = convertTasks(initialProjectBudget);
  // Calculate the Grand Total by summing up the 'TotalCost' column values
  double grandTotal = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  final budget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudget
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );
  final zzz14 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Signature of the Principal Investigator:  ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.piSignatureLocation.isNotEmpty) piSignatureimage,
      ],
    ),
  );
  final zzz15 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 5.0),
          child: pw.Text(
            "Date & Seal:   ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 7.0),
          child: pw.Text(
            formData.piSignatureDate,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.piSealLocation.isNotEmpty) piSealimage,
      ],
    ),
  );
  final zzz16 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "Comments of the Chairman of the Department: ………………………………",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz17 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.commentsOfTheChairmanOfTheDepartment,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 7,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz18 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Signature of the Chairman of the Department: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.chairmanOfDepartmentSignatureFileLocation.isNotEmpty) chairmanSignatureimage,
      ],
    ),
  );
  final zzz19 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 5.0),
          child: pw.Text(
            "Date & Seal:   ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 7.0),
          child: pw.Text(
            formData.dateOfChairmanOfTheDepartment,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        if (formData.chairmanOfDepartmentSealFileLocation.isNotEmpty) chairmanSealimage,
      ],
    ),
  );
  final zzz20 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "PATR III:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );
  final zzz21 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "A. BRIEF INFORMATION OF THE PRINCIPAL INVESTIGATOR (PI)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz22 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Name and Address including phone & email: ",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz23 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piPositionEnglish,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteLocation,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.piEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.piPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz24 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Salary Scale: ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piSalaryScale,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  // calculate current year running
  DateTime now = DateTime.now();
  int currentYear = now.year;
  final zzz25 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Basic pay in June $currentYear : ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piBasicPay,
            style: pw.TextStyle(font: ttfGeneral, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz26 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Highest Academic Qualification (University, Country, Year):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz27 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualification,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationUniversity,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationCountry,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piHighestAcademicQualificationYear,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz28 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Area of Expertise:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz29 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piAreaOfExpertise,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz30 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Experience in Research:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.piExperienceInResearch}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years and ",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Teaching Experience:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.piExperienceInTeaching}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz31 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "References of latest Publications (Maximum 5):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz32 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.piReferencesOfLatestPublications,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 0.2,
      wordSpacing: 1.5,
    ),
  );
  final zzz33 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "B. BRIEF INFORMATION OF THE CO-PRINCIPAL INVESTIGATOR (CO-PI)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz34 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Name and Address including phone & email: ",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz35 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiPositionEnglish,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiInstituteLocation,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.coPiEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.coPiPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz36 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Salary Scale: ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.coPiSalaryScale,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz37 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Basic pay in June $currentYear : ……………",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.coPiBasicPay,
            style: pw.TextStyle(font: ttfGeneral, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz38 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Highest Academic Qualification (University, Country, Year):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz39 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualification,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationUniversity,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationCountry,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiHighestAcademicQualificationYear,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz40 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Area of Expertise:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz41 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.coPiAreaOfExpertise,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz42 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Experience in Research:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.coPiExperienceInResearch}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years and ",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Teaching Experience:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……${formData.coPiExperienceInTeaching}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……Years",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz43 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "References of latest Publications (Maximum 5):",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz44 = pw.Paragraph(
    textAlign: pw.TextAlign.justify,
    text: formData.coPiReferencesOfLatestPublications,
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    style: pw.TextStyle(
      font: ttfGeneral,
      fontFallback: [ttfSymbola],
      fontSize: 11,
      lineSpacing: 2,
      wordSpacing: 1.5,
      letterSpacing: 0.2,
    ),
  );
  final zzz45 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "C. STUDENT’S INFORMATION (FOR CODE: 4829): (MS/PhD)",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz46 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Name:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………${formData.studentName}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz47 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Reg. No.:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………${formData.studentRegNo}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "……………",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "ID:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "………………${formData.studentId}",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz48 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "First Enrollment Semester:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "…………${formData.firstEnrollmentSemester}……",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz49 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "CGPA at Undergraduate Level:",
            style: pw.TextStyle(
              font: ttfBold,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            "…………${formData.cgpaUndergraduateLevel}……",
            style: pw.TextStyle(
              font: ttfGeneral,
              letterSpacing: 0.5,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz);
  widgets.add(introductionResearchProposal);
  widgets.add(specificObjectivesProposaltitle);
  widgets.add(specificObjectivesProposal);
  widgets.add(relevanceStrategicDevelopmentGoalstitle);
  widgets.add(relevanceStrategicDevelopmentGoals);
  widgets.add(briefReviewAlreadyPerformedReferencestitle);
  widgets.add(briefReviewAlreadyPerformedReferences);
  widgets.add(methodologytitle);
  widgets.add(zzz2);
  if (formData.methodologyFileLocation.isNotEmpty) {
    widgets.add(methodologyImage);
  }
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz9);
  widgets.add(zzz10);
  widgets.add(zzz11);
  widgets.add(zzzz11);
  widgets.add(ganttChart);
  widgets.add(zzz12);
  widgets.add(inputs);
  widgets.add(zzz13);
  widgets.add(budget);
  widgets.add(zzz14);
  widgets.add(zzz15);
  widgets.add(zzz16);
  widgets.add(zzz17);
  widgets.add(zzz18);
  widgets.add(zzz19);
  widgets.add(zzz20);
  widgets.add(zzz21);
  widgets.add(zzz22);
  widgets.add(zzz23);
  widgets.add(zzz24);
  widgets.add(zzz25);
  widgets.add(zzz26);
  widgets.add(zzz27);
  widgets.add(zzz28);
  widgets.add(zzz29);
  widgets.add(zzz30);
  widgets.add(zzz31);
  widgets.add(zzz32);
  widgets.add(zzz33);
  widgets.add(zzz34);
  widgets.add(zzz35);
  widgets.add(zzz36);
  widgets.add(zzz37);
  widgets.add(zzz38);
  widgets.add(zzz39);
  widgets.add(zzz40);
  widgets.add(zzz41);
  widgets.add(zzz42);
  widgets.add(zzz43);
  widgets.add(zzz44);
  widgets.add(zzz45);
  widgets.add(zzz46);
  widgets.add(zzz47);
  widgets.add(zzz48);
  widgets.add(zzz49);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'Project_Proposal_${formData.piName}_ProjectID_${formData.projectID}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<void> generateRequestForhonorariumPDF(viewfund.FormData formData, BuildContext context, Uint8List? piSignatureFileBytes, Uint8List? piSealFileBytes, Uint8List? chairmanSignatureFileBytes,
    Uint8List? chairmanSealFileBytes, List<dynamic> initialProjectBudget) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfBold = pw.Font.ttf(fontBold);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  final piSignatureimage = await generateImageWidget(piSignatureFileBytes, 200.0, 40.0);
  final piSealimage = await generateImageWidget(piSealFileBytes, 200.0, 40.0);
  final chairmanSignatureimage = await generateImageWidget(chairmanSignatureFileBytes, 200.0, 40.0);
  final chairmanSealimage = await generateImageWidget(chairmanSealFileBytes, 200.0, 40.0);

  List<pw.Widget> widgets = [];
  final currentYear = DateTime.now().year;
  final previousYear = DateTime.now().year - 1;
  var pageTitle = 'Request for Honorarium of Research Project FY: $previousYear-$currentYear';

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            pageTitle,
            style: pw.TextStyle(font: ttfBold, fontSize: 14, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 2.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  ]);

  final zzz1 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Research code: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.rtcCode,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz2 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Faculty: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz3 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Title of Project:  ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: formData.projectTitle,
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Name of the PI: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz5 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "Office address of the PI including phone & e-mail",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    ),
  );

  final zzz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piPosition,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteAddress,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.piEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.piPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final zzz7 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Total budget: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.totalBudget,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Requested amount (Tk.) for honorarium of PI: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "${formData.requestedHonorariumOfPI.toString()}/=",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz9 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Requested amount (Tk.) for honorarium of CO-PI: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "${formData.requestedHonorariumOfCoPI.toString()}/=",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.5, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Total honorarium of PI / Co-PI: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "${formData.totalHonorarium.toString()}/=",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 4, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: chairmanSignatureimage,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: piSignatureimage,
          ),
        ),
      ],
    ),
  );
  final zzz12 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 0.0),
            child: pw.Container(
              width: 150,
              height: 1.0, // Adjust the height of the line as needed
              color: const PdfColor.fromInt(0xff000000), // Color of the line
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.SizedBox(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 0.0),
            child: pw.Container(
              width: 150,
              height: 1.0, // Adjust the height of the line as needed
              color: const PdfColor.fromInt(0xff000000), // Color of the line
            ),
          ),
        ),
      ],
    ),
  );
  final zzz13 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: 0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Signature of the Dean/Chairman",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 10),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Signature of the PI",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz14 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Date & Seal: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            formData.dateOfChairmanOfTheDepartment,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 10),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Date & Seal: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            formData.piSignatureDate,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz15 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: chairmanSealimage,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: piSealimage,
          ),
        ),
      ],
    ),
  );

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final zzz99 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final convertedBudget = convertTasks(initialProjectBudget);
  // Calculate the Grand Total by summing up the 'TotalCost' column values
  double grandTotal = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  final budget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudget
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz);
  widgets.add(zzz1);
  widgets.add(zzz2);
  widgets.add(zzz3);
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz9);
  widgets.add(zzz10);
  widgets.add(zzz11);
  widgets.add(zzz12);
  widgets.add(zzz13);
  widgets.add(zzz14);
  widgets.add(zzz15);

  widgets.add(pw.SizedBox(
    height: 35.0,
  )); // Added a placeholder widget to force a new page before zzz99
  widgets.add(zzz99);
  widgets.add(budget);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'Request_For_Honorarium_${formData.piName}_ProjectID_${formData.projectID}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<void> generateRequestForAdvancePDF(viewadvancefund.FormData formData, BuildContext context, Uint8List? piSignatureFileBytes, Uint8List? piSealFileBytes, Uint8List? chairmanSignatureFileBytes,
    Uint8List? chairmanSealFileBytes, List<dynamic> initialProjectBudget) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfBold = pw.Font.ttf(fontBold);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  final piSignatureimage = await generateImageWidget(piSignatureFileBytes, 200.0, 40.0);
  final piSealimage = await generateImageWidget(piSealFileBytes, 200.0, 40.0);
  final chairmanSignatureimage = await generateImageWidget(chairmanSignatureFileBytes, 200.0, 40.0);
  final chairmanSealimage = await generateImageWidget(chairmanSealFileBytes, 200.0, 40.0);

  List<pw.Widget> widgets = [];
  final currentYear = DateTime.now().year;
  final previousYear = DateTime.now().year - 1;
  var pageTitle = 'Request For Advance of Research Project FY: $previousYear-$currentYear';

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            pageTitle,
            style: pw.TextStyle(font: ttfBold, fontSize: 14, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 2.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  ]);

  final zzz1 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Research code: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.rtcCode,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz2 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Faculty: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz3 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Title of Project:  ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: formData.projectTitle,
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Name of the PI: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.piName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz5 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "Office address of the PI including phone & e-mail",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    ),
  );

  final zzz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.6, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piPosition,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piDepartmentName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piFacultyName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteName,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            formData.piInstituteAddress,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Row(children: [
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              "Email:  ",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
          pw.SizedBox(
            // width: (15),
            child: pw.Text(
              formData.piEmail,
              style: pw.TextStyle(
                color: PdfColors.blue900,
                font: ttfGeneral,
                decoration: pw.TextDecoration.underline,
                fontSize: 11,
                lineSpacing: 1.5,
              ),
            ),
          ),
        ]),
        pw.SizedBox(
          width: (kDefaultPadding * 28.0),
          child: pw.Text(
            "Mobile:  ${formData.piPhone}",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final zzz7 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Total budget: ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.totalBudget,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.3, left: kDefaultPadding * 4.0, right: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Requested Amount (Tk.): ",
            style: pw.TextStyle(font: ttfBold, fontSize: 11, letterSpacing: 0.5),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "${formData.requestedAmount.toString()}/=",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );

  final zzz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 4, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: chairmanSignatureimage,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: piSignatureimage,
          ),
        ),
      ],
    ),
  );
  final zzz12 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.3, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 0.0),
            child: pw.Container(
              width: 150,
              height: 1.0, // Adjust the height of the line as needed
              color: const PdfColor.fromInt(0xff000000), // Color of the line
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.SizedBox(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 0.0),
            child: pw.Container(
              width: 150,
              height: 1.0, // Adjust the height of the line as needed
              color: const PdfColor.fromInt(0xff000000), // Color of the line
            ),
          ),
        ),
      ],
    ),
  );
  final zzz13 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: 0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Signature of the Dean/Chairman",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 10),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Signature of the PI",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz14 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          child: pw.Text(
            "Date & Seal: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            formData.dateOfChairmanOfTheDepartment,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 10),
        ),
        pw.SizedBox(
          child: pw.Text(
            "Date & Seal: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          child: pw.Text(
            formData.piSignatureDate,
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz15 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: chairmanSealimage,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 8),
        ),
        pw.Container(
          width: 150.0,
          height: 40.0,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: piSealimage,
          ),
        ),
      ],
    ),
  );

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final zzz99 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  final convertedBudget = convertTasks(initialProjectBudget);
  // Calculate the Grand Total by summing up the 'TotalCost' column values
  double grandTotal = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  final budget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudget
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz);
  widgets.add(zzz1);
  widgets.add(zzz2);
  widgets.add(zzz3);
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz11);
  widgets.add(zzz12);
  widgets.add(zzz13);
  widgets.add(zzz14);
  widgets.add(zzz15);

  widgets.add(pw.SizedBox(
    height: 35.0,
  )); // Added a placeholder widget to force a new page before zzz99
  widgets.add(zzz99);
  widgets.add(budget);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'Request_For_Advance_${formData.piName}_ProjectID_${formData.projectID}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<void> viewDOC(Uint8List noticeFileBytes, String datePublished) async {
  final blob = html.Blob([Uint8List.fromList(noticeFileBytes)], 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
}

Future<void> downloadImage(Uint8List noticeFileBytes, String fileName) async {
  final blob = html.Blob([noticeFileBytes], 'application/octet-stream');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}

Future<Uint8List> generateMonitoringReportWithFeedbackPDF(usermonitoringreportwithfeedback.FormData formData, BuildContext context, List<dynamic> initialProjectBudgetOriginal,
    List<dynamic> budgetFormDataForUpload, List<dynamic> initialProjectGanttsOriginal, List<dynamic> ganttFormDataForUpload, int feedbackId) async {
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfBold = pw.Font.ttf(fontBold);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  List<pw.Widget> widgets = [];
  final currentYear = DateTime.now().year;
  final previousYear = DateTime.now().year - 1;
  var pageTitle = 'Monitoring Format FY: $previousYear-$currentYear';

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            pageTitle,
            style: pw.TextStyle(font: ttfBold, fontSize: 13, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 1.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.RichText(
            textAlign: pw.TextAlign.left,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Part-A ',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 1.5),
                ),
                pw.TextSpan(
                  text: '(For PI)',
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ]);

  widgets.add(zzz);

  final zzz1 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '1. Project Title:  ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: formData.projectTitle,
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz1);

  final zzz2 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '2. Name of the PI with address: ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: "${formData.piName}, ${formData.piInstituteAddress} , ${formData.piInstituteName}",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz2);

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final zzz3 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '3. Project activity and progress:',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz3);

  final convertedTasksGanttOriginal = convertTasks(initialProjectGanttsOriginal);
  final convertedTasksGantt = convertTasks(ganttFormDataForUpload);
  List<pw.TableRow> buildTableRows(List<Map<String, dynamic>> tasks) {
    // Define months
    final List<String> months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    // Define table header
    final headerRow = pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: pw.SizedBox(height: (kDefaultPadding * 0.53), width: (kDefaultPadding * 5), child: pw.Text('Work/Activity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5))),
          ),
        ),
        ...months.map((month) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                pw.SizedBox(
                    height: 5,
                    width: 15,
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Transform.rotate(
                        angle: 1.5708, // 90 degrees counter-clockwise in radians
                        child: pw.Text(
                          textAlign: pw.TextAlign.center,
                          month,
                          style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5),
                        ),
                      ),
                    ])),
              ]),
            )),
      ],
    );

    // Define table data rows
    final dataRows = tasks.map((task) {
      final taskName = task['Activity'].toString();
      final startDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['StartDate']);
      final endDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['EndDate']);
      final status = task['ActivityStatus'] == 'Completed';

      return pw.TableRow(
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.SizedBox(width: (kDefaultPadding * 5), child: pw.Text(taskName, style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5))),
            ),
          ),
          ...months.map((month) {
            var monthIndex = (months.indexOf(month) + 7) % 12; // Adjusted index
            if (monthIndex == 0) {
              monthIndex = 12;
            }
            final isWithinRange = monthIndex >= startDate.month && monthIndex <= endDate.month;

            // Check if the task status is completed
            if (isWithinRange && status) {
              // Cell within range and task completed, color green
              return pw.Container(
                width: 15,
                height: taskName.length * 0.25,
                color: PdfColors.green,
              );
            } else if (isWithinRange && !status) {
              // Cell within range but task not completed, color red
              return pw.Container(
                width: 15,
                height: taskName.length * 0.25,
                color: PdfColors.red,
              );
            } else {
              return pw.Container(
                width: 15,
                // height: 40,
              );
            }
          }),
        ],
      );
    }).toList();

    return [headerRow, ...dataRows];
  }

  final activityplan = pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0, right: kDefaultPadding * 2.0),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Table(
          defaultColumnWidth: const pw.IntrinsicColumnWidth(flex: 1.0),
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Activity proposed in original proposal', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Progress (Completed/ongoing)', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: buildTableRows(convertedTasksGanttOriginal),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: buildTableRows(convertedTasksGantt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]));

  widgets.add(activityplan);

  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '4. List of procured goods and services proposed in the original proposal:',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz4);

  final convertedBudgetOriginal = convertTasks(initialProjectBudgetOriginal);
  final convertedBudget = convertTasks(budgetFormDataForUpload);
  double grandTotalBudgetOriginal = convertedBudgetOriginal.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  double grandTotalBudget = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);

  final budget = pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0, right: kDefaultPadding * 2.0),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Table(
          defaultColumnWidth: const pw.IntrinsicColumnWidth(flex: 1.0),
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Proposed goods and services to be procured (Mentioned in the original proposal)', style: pw.TextStyle(font: ttfGeneral, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Procured goods and services', style: pw.TextStyle(font: ttfGeneral, fontSize: 10)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Sl. No.', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Item', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Quantity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Unit Price', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Total cost (Tk)', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                        ],
                      ),
                      ...initialProjectBudgetOriginal.asMap().entries.map((entry) {
                        final budgetData = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['SerialNo'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['Item'], style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['Quantity'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['UnitPrice'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['TotalCost'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                          ],
                        );
                      }).toList(),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text((grandTotalBudgetOriginal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                        ),
                      ])
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Sl. No.', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Item', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Quantity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Unit Price', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Total cost (Tk)', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                            ],
                          ),
                          ...budgetFormDataForUpload.asMap().entries.map((entry) {
                            final budgetData = entry.value;
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['SerialNo'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['Item'], style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['Quantity'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['UnitPrice'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['TotalCost'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                              ],
                            );
                          }).toList(),
                          pw.TableRow(children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text((grandTotalBudget.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                            ),
                          ])
                        ],
                      ),
                      pw.SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ]));

  widgets.add(budget);

  final zz5 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Part-B",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              decoration: pw.TextDecoration.underline,
              decorationThickness: 0.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );

  widgets.add(zz5);

  final zz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "(For Monitoring Committee)",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              decoration: pw.TextDecoration.underline,
              decorationThickness: 0.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );

  widgets.add(zz6);

  final zz7 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "1. Observation (Qualitative progress in %):  ${formData.observation}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz7);

  final zz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "2. Suggestions (If any):  ${formData.suggestion}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz8);

  final zz9 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "3. Recommendations of monitoring committee:  ${formData.recommendation}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz9);

  final zz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            formData.endorsement,
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz10);

  final zz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "__________________________________________",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz11);

  final zz12 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.1, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Endorsement of Monitoring Committee",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz12);

  final zzz99 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final attachedBudget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudgetOriginal
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotalBudgetOriginal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );
  widgets.add(zzz99);
  widgets.add(attachedBudget);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'MonitoringFeedbackID_${feedbackId}_PI_Name_${formData.piName}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);

  return bytes;
  // Save the PDF
  // final output = await getTemporaryDirectory();
  // final file = File("${output.path}/monitoring_report.pdf");
  // await file.writeAsBytes(await pdf.save());
  // Call the function defined in api_service.dart to upload the PDF file
}

Future<Uint8List> generateMonitoringReportPDF(usermonitoringreport.FormData formData, BuildContext context, List<dynamic> initialProjectBudgetOriginal, List<dynamic> budgetFormDataForUpload,
    List<dynamic> initialProjectGanttsOriginal, List<dynamic> ganttFormDataForUpload, int projectMonitoringReportID) async {
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfBold = pw.Font.ttf(fontBold);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  List<pw.Widget> widgets = [];
  final currentYear = DateTime.now().year;
  final previousYear = DateTime.now().year - 1;
  var pageTitle = 'Monitoring Format FY: $previousYear-$currentYear';

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            pageTitle,
            style: pw.TextStyle(font: ttfBold, fontSize: 13, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 1.5),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.RichText(
            textAlign: pw.TextAlign.left,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: 'Part-A ',
                  style: pw.TextStyle(font: ttfBold, fontSize: 12, letterSpacing: 0.3, decoration: pw.TextDecoration.underline, decorationThickness: 1.5),
                ),
                pw.TextSpan(
                  text: '(For PI)',
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ]);

  widgets.add(zzz);

  final zzz1 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '1. Project Title:  ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: formData.projectTitle,
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz1);

  final zzz2 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '2. Name of the PI with address: ',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
                pw.TextSpan(
                  text: "${formData.piName}, ${formData.piInstituteAddress} , ${formData.piInstituteName}",
                  style: pw.TextStyle(
                    font: ttfGeneral,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz2);

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGanttsBudgets) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGanttsBudgets) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final zzz3 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '3. Project activity and progress:',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz3);

  final convertedTasksGanttOriginal = convertTasks(initialProjectGanttsOriginal);
  final convertedTasksGantt = convertTasks(ganttFormDataForUpload);
  List<pw.TableRow> buildTableRows(List<Map<String, dynamic>> tasks) {
    // Define months
    final List<String> months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    // Define table header
    final headerRow = pw.TableRow(
      children: [
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: pw.SizedBox(height: (kDefaultPadding * 0.53), width: (kDefaultPadding * 5), child: pw.Text('Work/Activity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5))),
          ),
        ),
        ...months.map((month) => pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                pw.SizedBox(
                    height: 5,
                    width: 15,
                    child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
                      pw.Transform.rotate(
                        angle: 1.5708, // 90 degrees counter-clockwise in radians
                        child: pw.Text(
                          textAlign: pw.TextAlign.center,
                          month,
                          style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5),
                        ),
                      ),
                    ])),
              ]),
            )),
      ],
    );

    // Define table data rows
    final dataRows = tasks.map((task) {
      final taskName = task['Activity'].toString();
      final startDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['StartDate']);
      final endDate = DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(task['EndDate']);
      final status = task['ActivityStatus'] == 'Completed';

      return pw.TableRow(
        children: [
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
              child: pw.SizedBox(width: (kDefaultPadding * 5), child: pw.Text(taskName, style: pw.TextStyle(font: ttfGeneral, fontSize: 5, lineSpacing: 1.5))),
            ),
          ),
          ...months.map((month) {
            var monthIndex = (months.indexOf(month) + 7) % 12; // Adjusted index
            if (monthIndex == 0) {
              monthIndex = 12;
            }
            final isWithinRange = monthIndex >= startDate.month && monthIndex <= endDate.month;

            // Check if the task status is completed
            if (isWithinRange && status) {
              // Cell within range and task completed, color green
              return pw.Container(
                width: 15,
                height: taskName.length * 0.25,
                color: PdfColors.green,
              );
            } else if (isWithinRange && !status) {
              // Cell within range but task not completed, color red
              return pw.Container(
                width: 15,
                height: taskName.length * 0.25,
                color: PdfColors.red,
              );
            } else {
              return pw.Container(
                width: 15,
                // height: 40,
              );
            }
          }),
        ],
      );
    }).toList();

    return [headerRow, ...dataRows];
  }

  final activityplan = pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0, right: kDefaultPadding * 2.0),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Table(
          defaultColumnWidth: const pw.IntrinsicColumnWidth(flex: 1.0),
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Activity proposed in original proposal', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Progress (Completed/ongoing)', style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: buildTableRows(convertedTasksGanttOriginal),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: buildTableRows(convertedTasksGantt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]));

  widgets.add(activityplan);

  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.RichText(
            textAlign: pw.TextAlign.start,
            text: pw.TextSpan(
              children: [
                pw.TextSpan(
                  text: '4. List of procured goods and services proposed in the original proposal:',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 11,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  widgets.add(zzz4);

  final convertedBudgetOriginal = convertTasks(initialProjectBudgetOriginal);
  final convertedBudget = convertTasks(budgetFormDataForUpload);
  double grandTotalBudgetOriginal = convertedBudgetOriginal.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);
  double grandTotalBudget = convertedBudget.map((item) => item['TotalCost'] as double).fold(0, (a, b) => a + b);

  final budget = pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0, right: kDefaultPadding * 2.0),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Table(
          defaultColumnWidth: const pw.IntrinsicColumnWidth(flex: 1.0),
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Proposed goods and services to be procured (Mentioned in the original proposal)', style: pw.TextStyle(font: ttfGeneral, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Text('Procured goods and services', style: pw.TextStyle(font: ttfGeneral, fontSize: 10)),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Sl. No.', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Item', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Quantity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Unit Price', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(3),
                            child: pw.Text('Total cost (Tk)', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                          ),
                        ],
                      ),
                      ...initialProjectBudgetOriginal.asMap().entries.map((entry) {
                        final budgetData = entry.value;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['SerialNo'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['Item'], style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['Quantity'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['UnitPrice'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(budgetData['TotalCost'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                            ),
                          ],
                        );
                      }).toList(),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text(''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(3),
                          child: pw.Text((grandTotalBudgetOriginal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                        ),
                      ])
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Sl. No.', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Item', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Quantity', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Unit Price', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(3),
                                child: pw.Text('Total cost (Tk)', style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                              ),
                            ],
                          ),
                          ...budgetFormDataForUpload.asMap().entries.map((entry) {
                            final budgetData = entry.value;
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['SerialNo'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['Item'], style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['Quantity'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['UnitPrice'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(3),
                                  child: pw.Text(budgetData['TotalCost'].toString(), style: pw.TextStyle(font: ttfGeneral, fontSize: 5)),
                                ),
                              ],
                            );
                          }).toList(),
                          pw.TableRow(children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text(''),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(3),
                              child: pw.Text((grandTotalBudget.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold, fontSize: 5)),
                            ),
                          ])
                        ],
                      ),
                      pw.SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ]));

  widgets.add(budget);

  final zz5 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Part-B",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              decoration: pw.TextDecoration.underline,
              decorationThickness: 0.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );

  widgets.add(zz5);

  final zz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "(For Monitoring Committee)",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              decoration: pw.TextDecoration.underline,
              decorationThickness: 0.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    ),
  );

  widgets.add(zz6);

  final zz7 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "1. Observation (Qualitative progress in %):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz7);

  final zz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "2. Suggestions (If any):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz8);

  final zz9 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "3. Recommendations of monitoring committee:",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz9);

  final zz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "__________________________________________",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz10);

  final zz11 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.1, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 28),
          child: pw.Text(
            "Endorsement of Monitoring Committee",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  widgets.add(zz11);

  final zzz99 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.Text(
            "BUDGET SUMMARY (ANNUAL BASIS):",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final attachedBudget = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 29),
          child: pw.TableHelper.fromTextArray(
            cellAlignment: pw.Alignment.center,
            columnWidths: {0: const pw.FixedColumnWidth(30), 1: const pw.FixedColumnWidth(200), 2: const pw.FixedColumnWidth(50), 3: const pw.FixedColumnWidth(75), 4: const pw.FixedColumnWidth(75)},
            headerStyle: pw.TextStyle(font: ttfBold, fontSize: 11, lineSpacing: 1.5),
            cellStyle: pw.TextStyle(font: ttfGeneral, fontSize: 11, lineSpacing: 1.5),
            cellAlignments: {0: pw.Alignment.topLeft, 1: pw.Alignment.topLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.center},
            border: pw.TableBorder.all(),
            headers: ['Sl. No.', 'Item', 'Quantity', 'Unit Price', 'Total Cost (Tk)'],
            data: convertedBudgetOriginal
                .map((row) => [
                      '${row['SerialNo']}',
                      row['Item'],
                      '${row['Quantity']}',
                      '${row['UnitPrice']}',
                      '${row['TotalCost']}',
                    ])
                .toList()
              ..add(['', pw.Text('Grand Total:', style: pw.TextStyle(font: ttfBold)), '', '', pw.Text((grandTotalBudgetOriginal.toStringAsFixed(2)), style: pw.TextStyle(font: ttfBold))]),
          ),
        ),
      ],
    ),
  );
  widgets.add(zzz99);
  widgets.add(attachedBudget);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'MonitoringReportID_${projectMonitoringReportID}_PI_Name_${formData.piName}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);

  return bytes;
  // Save the PDF
  // final output = await getTemporaryDirectory();
  // final file = File("${output.path}/monitoring_report.pdf");
  // await file.writeAsBytes(await pdf.save());
  // Call the function defined in api_service.dart to upload the PDF file
}

Future<void> generateProfilePDF(
  userprofile.FormData formData,
  BuildContext context,
  Uint8List? profilePicFileBytes,
  Uint8List? nidFileBytes,
  Uint8List? sealFileBytes,
  Uint8List? signatureFileBytes,
) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final fontSymbola = await rootBundle.load("fonts/Symbola.ttf");
  final fontSutonnyMJBold = await rootBundle.load("fonts/SutonnyMJ-Bold.ttf");

  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfBold = pw.Font.ttf(fontBold);
  final ttfSymbola = pw.Font.ttf(fontSymbola);
  final ttfSutonnyMJBold = pw.Font.ttf(fontSutonnyMJBold);

  final fullNameBangla = unicodeToBijoy(formData.fullNameBangla);
  final positionBangla = unicodeToBijoy(formData.positionBangla);

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  final signatureimage = pw.MemoryImage(signatureFileBytes!);
  final sealimage = pw.MemoryImage(sealFileBytes!);
  final nidimage = pw.MemoryImage(nidFileBytes!);
  final profilePicimage = pw.MemoryImage(profilePicFileBytes!);

  List<pw.Widget> widgets = [];

  final zzz = pw.ListView(padding: const pw.EdgeInsets.all(5.0), children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.only(left: kDefaultPadding * 4.0, right: kDefaultPadding * 3.0),
              child: pw.Stack(
                children: [
                  pw.Image(pw.MemoryImage(appLogoImageBytes), width: 80, height: 95),
                ],
              ),
            ),
          ],
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
          pw.Text(
            "Research and Training Centre",
            style: pw.TextStyle(font: ttfBold, fontSize: 20, letterSpacing: 0.5),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13, letterSpacing: 0.2),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 13),
            textAlign: pw.TextAlign.center,
          ),
        ]),
      ],
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1.5, top: kDefaultPadding),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 0.0),
      child: pw.Container(
        width: double.infinity,
        height: 1.0, // Adjust the height of the line as needed
        color: const PdfColor.fromInt(0xff000000), // Color of the line
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            "Teacher/Researcher Profile",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 10.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.center, children: [
            pw.SizedBox(
              width: (kDefaultPadding * 8.5),
              child: pw.Text(
                "Status : ",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding * 3),
              child: pw.Text(
                "Approved",
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding),
              child: pw.Text(
                "|",
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding * 8),
              child: pw.Text(
                "Date of PDF Generation : ",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding * 4),
              child: pw.Text(
                DateTime.now().toString().split(' ')[0],
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding),
              child: pw.Text(
                "|",
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding * 4),
              child: pw.Text(
                "Profile ID : ",
                style: pw.TextStyle(
                  font: ttfGeneral,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
            pw.SizedBox(
              width: (kDefaultPadding * 2),
              child: pw.Text(
                formData.userId.toString(),
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 10,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
          ])
        ],
      ),
    ),

    // RESEARCHER INFORMATION
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 30),
            child: pw.Text(
              "RESEARCHER INFORMATION",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                color: const PdfColor.fromInt(0xff007100),
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 32),
            child: pw.Text(
              "--------------------------------------------------------------------------------------------------------------------------",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.start,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Name (English)",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.firstName} ${formData.lastName}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Name (Bengali)",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": $fullNameBangla",
              style: pw.TextStyle(
                font: ttfSutonnyMJBold,
                fontSize: 9,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Position (English)",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.positionEnglish}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Position (Bengali)",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": $positionBangla",
              style: pw.TextStyle(
                font: ttfSutonnyMJBold,
                fontSize: 9,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Position Held (since)",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.positionHeldSince}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Gender",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.gender}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Date of Birth",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.dateOfBirth))}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "E-mail",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.email}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Phone Number",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.phone}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "NID No.",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.nid}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    // INSTITUTE INFORMATION
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 30),
            child: pw.Text(
              "INSTITUTE INFORMATION",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                color: const PdfColor.fromInt(0xff007100),
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 32),
            child: pw.Text(
              "--------------------------------------------------------------------------------------------------------------------------",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.start,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Institute Name",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.instituteName}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Faculty Name",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.facultyName}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Department Name",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.departmentName}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Institute Location",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.instituteLocation}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Institute Email",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.instituteEmail}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Salary Scale",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.salaryScale}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Basic Pay",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.basicPay}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),

    // PERSONAL INFORMATION
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 30),
            child: pw.Text(
              "PERSONAL INFORMATION",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                color: const PdfColor.fromInt(0xff007100),
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 32),
            child: pw.Text(
              "--------------------------------------------------------------------------------------------------------------------------",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 12,
              ),
              textAlign: pw.TextAlign.start,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Present Address",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.presentAddress}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Permanent Address",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.permanentAddress}",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: kDefaultPadding * 3.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 6),
            child: pw.Text(
              "Highest Academic Qualification",
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 8,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(
            width: (kDefaultPadding * 24),
            child: pw.Text(
              ": ${formData.highestAcademicQualification} , ${formData.highestAcademicQualificationUniversity}, ${formData.highestAcademicQualificationCountry} (${formData.highestAcademicQualificationYear})",
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 8,
                fontFallback: [ttfSymbola],
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
        ],
      ),
    ),
  ]);

  // RESEARCH INFORMATION
  final zzz2 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: (5.0 + (kDefaultPadding * 3.0)), bottom: kDefaultPadding * 0.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 30),
          child: pw.Text(
            "RESEARCH INFORMATION",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              color: const PdfColor.fromInt(0xff007100),
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz3 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.0, left: (5.0 + (kDefaultPadding * 3.0)), bottom: kDefaultPadding * 0.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 32),
          child: pw.Text(
            "--------------------------------------------------------------------------------------------------------------------------",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.start,
          ),
        ),
      ],
    ),
  );
  final zzz4 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Area of Expertise",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.areaOfExpertise}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz5 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Research Experience",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.experienceInResearch} Years",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz6 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Teaching Experience",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.teaching} Years",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz7 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Total Complete Projects",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.totalNumberOfCompleteProjects}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz8 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Total Complete Publications",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.totalNumberOfCompletePublications}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz9 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Ongoing Projects",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.ongoingProjects}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz10 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.2, left: (5.0 + (kDefaultPadding * 3.0))),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 6),
          child: pw.Text(
            "Latest Publication Reference",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 8,
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 24),
          child: pw.Text(
            ": ${formData.referencesOfLatestPublications}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              fontFallback: [ttfSymbola],
            ),
            textAlign: pw.TextAlign.justify,
          ),
        ),
      ],
    ),
  );

  // RESEARCHER PHOTO, SIGNATURE, SEAL & NID
  final zzz21 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 1.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 30),
          child: pw.Text(
            "RESEARCHER PHOTO, SIGNATURE, SEAL & NID",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 8,
              color: const PdfColor.fromInt(0xff007100),
            ),
            textAlign: pw.TextAlign.left,
          ),
        ),
      ],
    ),
  );
  final zzz22 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.0, left: kDefaultPadding * 3.0, bottom: kDefaultPadding * 0.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 32),
          child: pw.Text(
            "--------------------------------------------------------------------------------------------------------------------------",
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 12,
            ),
            textAlign: pw.TextAlign.start,
          ),
        ),
      ],
    ),
  );
  final zzz23 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Photo",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Signature",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz24 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Image(profilePicimage, width: 60, height: 80, alignment: pw.Alignment.center, fit: pw.BoxFit.fill),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 10.0),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Image(signatureimage, width: 150, height: 30, alignment: pw.Alignment.center, fit: pw.BoxFit.fill),
        ),
      ],
    ),
  );
  final zzz25 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Seal",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Text(
            "Nid Photo",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 10,
              lineSpacing: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
  final zzz26 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.5, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Image(sealimage, width: 150, height: 30, alignment: pw.Alignment.center, fit: pw.BoxFit.fill),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 4.5),
        ),
        pw.SizedBox(
          width: (kDefaultPadding * 14.0),
          child: pw.Image(nidimage, width: 150, height: 70, alignment: pw.Alignment.center, fit: pw.BoxFit.fill),
        ),
      ],
    ),
  );

  widgets.add(zzz);
  widgets.add(zzz2);
  widgets.add(zzz3);
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz9);
  widgets.add(zzz10);
  widgets.add(zzz21);
  widgets.add(zzz22);
  widgets.add(zzz23);
  widgets.add(zzz24);
  widgets.add(zzz25);
  widgets.add(zzz26);

  // Add content to the PDF document
  // USE Paragraph FOR TEXT TO AUTO SPAN TO MULTIPLE LINES & PAGES
  pdf.addPage(
    pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.only(top: 13.0, left: 0.0, right: 0.0, bottom: 40.0),
        ),
        build: (pw.Context context) => widgets),
  );

  // Save the PDF document to a file
  final bytes = await pdf.save();
  final blob = html.Blob([Uint8List.fromList(bytes)], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName = 'Profile_${formData.firstName}_${formData.lastName}.pdf';
  final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);

  // html.window.open(url, '_blank');
}

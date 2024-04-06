// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/screens/admin/ViewProjectScreen.dart';
import 'dart:html' as html;

Future<void> generatePDF(FormData formData, BuildContext context, List<dynamic> initialProjectGantts) async {
  // Create a PDF document
  final pdf = pw.Document();
  final fontGeneral = await rootBundle.load("fonts/times-new-roman.ttf");
  final fontBoldItalic = await rootBundle.load("fonts/times-new-roman-bold-italic.ttf");
  final fontBold = await rootBundle.load("fonts/times-new-roman-bold.ttf");
  final fontItalic = await rootBundle.load("fonts/times-new-roman-italic.ttf");
  final fontSymbola = await rootBundle.load("fonts/Symbola.ttf");
  final ttfGeneral = pw.Font.ttf(fontGeneral);
  final ttfItalic = pw.Font.ttf(fontItalic);
  final ttfBold = pw.Font.ttf(fontBold);
  final ttfBoldItalic = pw.Font.ttf(fontBoldItalic);
  final ttfSymbola = pw.Font.ttf(fontSymbola);

  final appLogo = await rootBundle.load("images/app_logo.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  const String baseUrl = 'http://localhost:5000';
  final accessToken = await storage.read(key: 'jwt_token');
  var picFileMethodology = formData.methodologyFileLocation.isEmpty ? 'defaultprofilepic.png' : formData.methodologyFileLocation;
  final netImage = await networkImage('$baseUrl/methodology/download/$picFileMethodology', headers: {'Authorization': 'Bearer $accessToken'});

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
            style: pw.TextStyle(font: ttfBold, fontSize: 20),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Patuakhali Science and Technology University",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 14),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Dumki, Patuakhali-8602, Bangladesh",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 14),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            "Email: rtc@pstu.ac.bd",
            style: pw.TextStyle(font: ttfGeneral, fontSize: 14),
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
            style: pw.TextStyle(font: ttfBold, fontSize: 12, decoration: pw.TextDecoration.underline),
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
                  DateFormat("MMMM d, yyyy").format(DateTime.parse(formData.dateOfReceived)),
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
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              textAlign: pw.TextAlign.justify,
              formData.introductionResearchProposal,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 7,
                wordSpacing: 1.5,
                letterSpacing: 0.2,
              ),
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
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              textAlign: pw.TextAlign.justify,
              formData.specificObjectivesProposal,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 7,
                wordSpacing: 1.5,
                letterSpacing: 0.2,
              ),
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
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              textAlign: pw.TextAlign.justify,
              formData.relevanceStrategicDevelopmentGoals,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 7,
                wordSpacing: 1.5,
                letterSpacing: 0.2,
              ),
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
    ),
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: kDefaultPadding * 0.7, left: kDefaultPadding * 4.0),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: (kDefaultPadding * 29),
            child: pw.Text(
              textAlign: pw.TextAlign.justify,
              formData.briefReviewAlreadyPerformedReferences,
              style: pw.TextStyle(
                font: ttfGeneral,
                fontSize: 11,
                lineSpacing: 7,
                wordSpacing: 1.5,
                letterSpacing: 0.2,
              ),
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
    ),
  ]);

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
        pw.Image(netImage, width: 500.0, height: 500.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
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

  widgets.add(zzz);
  widgets.add(zzz2);
  widgets.add(methodologyImage);
  widgets.add(zzz4);
  widgets.add(zzz5);
  widgets.add(zzz6);
  widgets.add(zzz7);
  widgets.add(zzz8);
  widgets.add(zzz9);
  widgets.add(zzz10);
  widgets.add(zzz11);

  List<Map<String, dynamic>> convertTasks(List<dynamic> initialProjectGantts) {
    List<Map<String, dynamic>> convertedTasks = [];
    for (var item in initialProjectGantts) {
      if (item is Map<String, dynamic>) {
        convertedTasks.add(item);
      }
    }
    return convertedTasks;
  }

  final convertedTasks = convertTasks(initialProjectGantts);

  Map<int, List<Map<String, dynamic>>> groupTasksByYear(List<Map<String, dynamic>> tasks) {
    final Map<int, List<Map<String, dynamic>>> tasksByYear = {};

    for (final task in tasks) {
      final startDate = DateFormat('yyyy-MM-dd').parse(task['StartDate']);
      final year = startDate.year;

      if (!tasksByYear.containsKey(year)) {
        tasksByYear[year] = [];
      }

      tasksByYear[year]!.add(task);
    }

    return tasksByYear;
  }

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
      print("sssssssssssssssssssssssssssss");
      print(status);

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
            final monthIndex = (months.indexOf(month) + 7) % 12; // Adjusted index
            final isWithinRange = monthIndex >= startDate.month && monthIndex <= endDate.month;

            // Check if the task status is completed
            if (isWithinRange && status) {
              // Cell within range and task completed, color green
              return pw.Container(
                width: 15,
                height: taskName.length * 1.0,
                color: PdfColors.green,
              );
            } else if (isWithinRange && !status) {
              // Cell within range but task not completed, color red
              return pw.Container(
                width: 15,
                height: taskName.length * 1.0,
                color: PdfColors.red,
              );
            } else {
              return pw.Container(
                width: 15,
                height: 40,
              );
            }
          }),
        ],
      );
    }).toList();

    return [headerRow, ...dataRows];
  }

  final xxx = pw.Padding(
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

  widgets.add(xxx);
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
  // const fileName = 'my_custom_name.pdf'; // Provide your custom file name here
  // final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  // html.document.body?.children.add(anchor);
  // anchor.click();
  // html.document.body?.children.remove(anchor);
  html.window.open(url, '_blank');
}

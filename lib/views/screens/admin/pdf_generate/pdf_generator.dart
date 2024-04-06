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

Future<void> generatePDF(FormData formData, BuildContext context, List<dynamic> initialProjectGantts, List<dynamic> initialProjectBudget) async {
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

  final appLogo = await rootBundle.load("images/app_logo_2.png");
  final appLogoImageBytes = appLogo.buffer.asUint8List();

  const String baseUrl = 'http://localhost:5000';
  final accessToken = await storage.read(key: 'jwt_token');
  var picFileMethodology = formData.methodologyFileLocation.isEmpty ? 'defaultprofilepic.png' : formData.methodologyFileLocation;
  final netImage = await networkImage('$baseUrl/methodology/download/$picFileMethodology', headers: {'Authorization': 'Bearer $accessToken'});
  var picFilePISignature = formData.piSignatureLocation.isEmpty ? 'defaultsignature.png' : formData.piSignatureLocation;
  final netImagePISignature = await networkImage('$baseUrl/signature/download/$picFilePISignature', headers: {'Authorization': 'Bearer $accessToken'});
  var picFilePISeal = formData.piSealLocation.isEmpty ? 'defaultseal.png' : formData.piSealLocation;
  final netImagePISeal = await networkImage('$baseUrl/seal/download/$picFilePISeal', headers: {'Authorization': 'Bearer $accessToken'});
  var picFilechairmanSignature = formData.chairmanOfDepartmentSignatureFileLocation.isEmpty ? 'defaultsignature.png' : formData.chairmanOfDepartmentSignatureFileLocation;
  final netImagechairmanSignature = await networkImage('$baseUrl/signature/download/$picFilechairmanSignature', headers: {'Authorization': 'Bearer $accessToken'});
  var picFilechairmanSeal = formData.chairmanOfDepartmentSealFileLocation.isEmpty ? 'defaultseal.png' : formData.chairmanOfDepartmentSealFileLocation;
  final netImagechairmanSeal = await networkImage('$baseUrl/seal/download/$picFilechairmanSeal', headers: {'Authorization': 'Bearer $accessToken'});

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

  widgets.add(ganttChart);

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
  widgets.add(zzz12);

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
          child: pw.Table.fromTextArray(
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

  widgets.add(inputs);

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
  widgets.add(zzz13);

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
          child: pw.Table.fromTextArray(
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
  widgets.add(budget);

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
        pw.Image(netImagePISignature, width: 200.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // pw.SizedBox(
        //   width: (kDefaultPadding * 29),
        //   child: pw.Image(netImage, width: 240.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // ),
      ],
    ),
  );
  widgets.add(zzz14);

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
          width: (kDefaultPadding * 12.0),
          child: pw.Text(
            DateFormat("EEEE, MMMM d, yyyy").format(DateTime.parse(formData.piSignatureDate)),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Image(netImagePISeal, width: 200.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // pw.SizedBox(
        //   width: (kDefaultPadding * 29),
        //   child: pw.Image(netImage, width: 240.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // ),
      ],
    ),
  );
  widgets.add(zzz15);

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
  widgets.add(zzz16);
  widgets.add(zzz17);

  final zzz18 = pw.Padding(
    padding: const pw.EdgeInsets.only(top: kDefaultPadding * 2.0, left: kDefaultPadding * 4.0),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: (kDefaultPadding * 16.0),
          child: pw.Text(
            "Signature of the Chairman of the Department: ",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Image(netImagechairmanSignature, width: 200.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
      ],
    ),
  );
  widgets.add(zzz18);

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
          width: (kDefaultPadding * 12.0),
          child: pw.Text(
            DateFormat("EEEE, MMMM d, yyyy").format(DateTime.parse(formData.dateOfChairmanOfTheDepartment)),
            style: pw.TextStyle(
              font: ttfGeneral,
              fontSize: 11,
              lineSpacing: 1.5,
            ),
          ),
        ),
        pw.Image(netImagechairmanSeal, width: 200.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // pw.SizedBox(
        //   width: (kDefaultPadding * 29),
        //   child: pw.Image(netImage, width: 240.0, height: 40.0, alignment: pw.Alignment.center, fit: pw.BoxFit.contain),
        // ),
      ],
    ),
  );
  widgets.add(zzz19);

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
  widgets.add(zzz20);
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
  widgets.add(zzz21);
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
  widgets.add(zzz22);

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
  widgets.add(zzz23);
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
  widgets.add(zzz24);
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
  widgets.add(zzz25);

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
  widgets.add(zzz26);

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
  widgets.add(zzz27);
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
  widgets.add(zzz28);

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
  widgets.add(zzz29);

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
  widgets.add(zzz30);

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
  widgets.add(zzz31);
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
  widgets.add(zzz32);

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
  widgets.add(zzz33);
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
  widgets.add(zzz34);

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
  widgets.add(zzz35);
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
  widgets.add(zzz36);
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
  widgets.add(zzz37);

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
  widgets.add(zzz38);

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
  widgets.add(zzz39);
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
  widgets.add(zzz40);

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
  widgets.add(zzz41);

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
  widgets.add(zzz42);

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
  widgets.add(zzz43);
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
  widgets.add(zzz44);

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
  widgets.add(zzz45);
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
  widgets.add(zzz46);
  
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
  widgets.add(zzz47);
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
  widgets.add(zzz48);
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
  // const fileName = 'my_custom_name.pdf'; // Provide your custom file name here
  // final anchor = html.AnchorElement(href: url)..setAttribute('download', fileName);
  // html.document.body?.children.add(anchor);
  // anchor.click();
  // html.document.body?.children.remove(anchor);
  html.window.open(url, '_blank');
}

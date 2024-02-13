import 'package:flutter/material.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/sidebar.dart';

final sidebarMenuConfigs = [
  SidebarMenuConfig(
    uri: RouteUri.dashboard,
    icon: Icons.dashboard_rounded,
    title: (context) => "Dashboard",
  ),
  SidebarMenuConfig(
    uri: '',
    icon: Icons.article_outlined,
    title: (context) => "Project",
    children: [
      SidebarChildMenuConfig(
        uri: RouteUri.projectdashboard,
        icon: Icons.circle_outlined,
        title: (context) => "Project Dashboard",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.createproject,
        icon: Icons.circle_outlined,
        title: (context) => "Create Project",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.searchproject,
        icon: Icons.circle_outlined,
        title: (context) => "Search Project",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projecttracking,
        icon: Icons.circle_outlined,
        title: (context) => "Project Tracking",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projectprogressreport,
        icon: Icons.circle_outlined,
        title: (context) => "Project Progress Report",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.billinformation,
        icon: Icons.circle_outlined,
        title: (context) => "Bill Information",
      ),
    ],
  ),
  SidebarMenuConfig(
    uri: RouteUri.logout,
    icon: Icons.logout_rounded,
    title: (context) => "Logout",
  ),
];

const localeMenuConfigs = [
  LocaleMenuConfig(
    languageCode: 'en',
    name: 'English',
  ),
];

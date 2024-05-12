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
    uri: RouteUri.projectdashboard,
    icon: Icons.dashboard_customize_outlined,
    title: (context) => "Project Dashboard",
  ),
  SidebarMenuConfig(
    uri: '',
    icon: Icons.article_outlined,
    title: (context) => "Project",
    children: [
      SidebarChildMenuConfig(
        uri: RouteUri.createproject,
        icon: Icons.create,
        title: (context) => "Create Project",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.myprojects,
        icon: Icons.my_library_books_outlined,
        title: (context) => "My Projects",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projectreviewtracking,
        icon: Icons.reviews_outlined,
        title: (context) => "Project Review Tracking",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projectfundmanagement,
        icon: Icons.monetization_on_outlined,
        title: (context) => "Project Fund Management",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projectmonitoringreport,
        icon: Icons.monitor_heart_outlined,
        title: (context) => "Project Monitoring Report",
      ),
    ],
  ),
  SidebarMenuConfig(
    uri: RouteUri.notification,
    icon: Icons.notifications_outlined,
    title: (context) => "Notification",
  ),
  SidebarMenuConfig(
    uri: '',
    icon: Icons.admin_panel_settings_outlined,
    title: (context) => "Admin Panel",
    children: [
      SidebarChildMenuConfig(
        uri: RouteUri.circularnotice,
        icon: Icons.notification_important_outlined,
        title: (context) => "Notice Board Management",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.usermanagementoverview,
        icon: Icons.supervised_user_circle_outlined,
        title: (context) => "User Management Overview",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.projectoverview,
        icon: Icons.dashboard_customize_outlined,
        title: (context) => "Projects Overview",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.searchproject,
        icon: Icons.format_list_numbered_rtl_outlined,
        title: (context) => "View All Project",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.reviewpaneloverview,
        icon: Icons.reviews_outlined,
        title: (context) => "Review Panel Overview",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.fundmonitoringpanel,
        icon: Icons.monetization_on_outlined,
        title: (context) => "Fund Monitoring Panel",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.monitoringpaneloverview,
        icon: Icons.monitor_heart_outlined,
        title: (context) => "Monitoring Panel Overview",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.viewallnotifications,
        icon: Icons.notifications_outlined,
        title: (context) => "View All Notifications",
      ),
      SidebarChildMenuConfig(
        uri: RouteUri.deleteuser,
        icon: Icons.delete_outline_outlined,
        title: (context) => "Delete User",
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

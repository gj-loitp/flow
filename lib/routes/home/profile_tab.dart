import 'package:flow/l10n.dart';
import 'package:flow/objectbox.dart';
import 'package:flow/sync/export.dart';
import 'package:flow/sync/import.dart';
import 'package:flow/theme/theme.dart';
import 'package:flow/utils.dart';
import 'package:flow/widgets/home/prefs/profile_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:simple_icons/simple_icons.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 24.0),
          const ProfileCard(),
          const SizedBox(height: 24.0),
          ListTile(
            title: Text("tabs.profile.preferences".t(context)),
            leading: const Icon(Symbols.settings_rounded),
            onTap: () => context.push("/preferences"),
          ),
          ListTile(
            title: Text("tabs.profile.importAndExport".t(context)),
            leading: const Icon(Symbols.sync_rounded),
            onTap: () => {},
          ),
          const SizedBox(height: 32.0),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "tabs.profile.community".t(context),
                style: context.textTheme.titleSmall,
              ),
            ),
          ),
          ListTile(
            title: Text("tabs.profile.joinDiscord".t(context)),
            leading: const Icon(SimpleIcons.discord),
            onTap: () => {},
          ),
          ListTile(
            title: Text("tabs.profile.supportOnKofi".t(context)),
            leading: const Icon(SimpleIcons.kofi),
            onTap: () => openUrl(Uri.parse("https://ko-fi.com/sadespresso")),
          ),
          ListTile(
            title: Text("tabs.profile.viewProjectOnGitHub".t(context)),
            leading: const Icon(SimpleIcons.github),
            onTap: () => openUrl(Uri.parse("https://github.com/flow-mn/flow")),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 32.0),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Debug options",
                  style: context.textTheme.titleSmall,
                ),
              ),
            ),
            ListTile(
              title: const Text("Populate objectbox"),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().populateDummyData(),
            ),
            ListTile(
              title:
                  Text(_debugDbBusy ? "Clearing database" : "Clear objectbox"),
              onTap: () => resetDatabase(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: const Text("Backup current data"),
              onTap: () => export(),
              leading: const Icon(Symbols.export_notes_rounded),
            ),
            ListTile(
              title: const Text("Export CSV"),
              onTap: () => export(true),
              leading: const Icon(Symbols.export_notes_rounded),
            ),
            ListTile(
              title: const Text("Import from backup"),
              onTap: () => importBackupV1(),
              leading: const Icon(Symbols.import_export_rounded),
            ),
          ],
          const SizedBox(height: 64.0),
          Text(
            "version indev-1, ${Moment.fromMillisecondsSinceEpoch(1700982217689).calendar()}",
            style: context.textTheme.labelSmall,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => openUrl(Uri.parse("https://github.com/sadespresso")),
            child: Opacity(
              opacity: 0.5,
              child: Text(
                "tabs.profile.withLoveFromTheCreator".t(context),
                style: context.textTheme.labelSmall,
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const SizedBox(height: 96.0),
        ],
      ),
    );
  }

  void resetDatabase() async {
    if (_debugDbBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("[dev] Reset database?"),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(true),
            child: const Text("Confirm delete"),
          ),
          ElevatedButton(
            onPressed: () => context.pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    setState(() {
      _debugDbBusy = true;
    });

    try {
      if (confirm == true) {
        await ObjectBox().wipeDatabase();
      }
    } finally {
      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }
}

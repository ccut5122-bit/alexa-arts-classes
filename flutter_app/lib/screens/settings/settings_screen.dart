import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/config_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _SectionTitle('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: Text('Dark Mode', style: GoogleFonts.poppins()),
            subtitle: Text('Switch to dark theme', style: GoogleFonts.poppins(fontSize: 12)),
            value: config.isDarkMode,
            onChanged: (v) => config.setDarkMode(v),
          ),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: Text('Theme Color', style: GoogleFonts.poppins()),
            subtitle: Text('Choose the app theme color', style: GoogleFonts.poppins(fontSize: 12)),
            trailing: CircleAvatar(
              backgroundColor: config.primaryColor,
              radius: 14,
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
            onTap: () => _pickThemeColor(config),
          ),
          const Divider(),
          _SectionTitle('Profile'),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: Text('Edit Name & Photo', style: GoogleFonts.poppins()),
            subtitle: Text(_saving ? 'Saving...' : 'Update your display name or picture',
                style: GoogleFonts.poppins(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _saving ? null : () => _editProfile(auth),
          ),
          const Divider(),
          _SectionTitle('Notifications'),
          Builder(
            builder: (context) => SwitchListTile(
              secondary: const Icon(Icons.notifications_rounded),
              title: Text('Notifications', style: GoogleFonts.poppins()),
              subtitle: Text('Get push alerts for new notes, tests & notices',
                  style: GoogleFonts.poppins(fontSize: 12)),
              value: true,
              onChanged: (_) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications are enabled by default')),
              ),
            ),
          ),
          const Divider(),
          _SectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: Text('App Info', style: GoogleFonts.poppins()),
            subtitle: Text('Alexa Arts Classes - JAC Class 11 Arts',
                style: GoogleFonts.poppins(fontSize: 12)),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_rounded, color: Colors.red),
            title: Text('Support', style: GoogleFonts.poppins()),
            subtitle: Text('Contact your class teacher for help',
                style: GoogleFonts.poppins(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _pickThemeColor(ConfigProvider config) {
    final colors = <Color>[
      const Color(0xFF6C63FF),
      const Color(0xFF2196F3),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
      const Color(0xFF795548),
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Theme Color',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: colors
                    .map((c) => GestureDetector(
                          onTap: () {
                            config.setPrimaryColor(c);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: config.primaryColor.value == c.value
                                  ? Border.all(color: Colors.black54, width: 3)
                                  : null,
                            ),
                            child: config.primaryColor.value == c.value
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editProfile(AuthProvider auth) async {
    final user = auth.userModel;
    if (user == null) return;
    final nameController =
        TextEditingController(text: user.displayName == 'Student' ? '' : user.displayName);
    XFile? picked;
    final photoBytes = user.photoBase64.isNotEmpty
        ? base64Decode(user.photoBase64)
        : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Edit Profile',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Center(
                  child: InkWell(
                    onTap: () async {
                      final image = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setSheetState(() => picked = image);
                      }
                    },
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: (picked != null)
                          ? FileImage(File(picked!.path)) as ImageProvider<Object>
                          : (photoBytes != null
                              ? MemoryImage(photoBytes) as ImageProvider<Object>
                              : null),
                      child: (picked == null && photoBytes == null)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tap to change photo',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Your name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                content: Text('Please enter your name')));
                            return;
                          }
                          setState(() => _saving = true);
                          var b64 = '';
                          if (picked != null) {
                            b64 =
                                base64Encode(await File(picked!.path).readAsBytes());
                          } else if (user.photoBase64.isNotEmpty) {
                            b64 = user.photoBase64;
                          }
                          await auth.completeOnboarding(name: name, photoBase64: b64);
                          setState(() => _saving = false);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Profile updated!')));
                        },
                  child: Text(_saving ? 'Saving...' : 'Save',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary)),
    );
  }
}
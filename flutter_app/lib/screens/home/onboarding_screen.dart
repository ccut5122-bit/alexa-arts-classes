import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _profileImage = image);
    }
  }

  Future<String> _encodePhoto() async {
    final bytes = await File(_profileImage!.path).readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final auth = context.read<AuthProvider>();
    try {
      final signedIn = await auth.signInAnonymously();
      if (!signedIn) {
        throw Exception('Sign in failed');
      }
      final uid = auth.user!.uid;
      final photoBase64 = await _encodePhoto();
      if (photoBase64.isEmpty) {
        throw Exception('Photo read failed');
      }
      final ok = await auth.completeOnboarding(
        name: name,
        photoBase64: photoBase64,
      );
      if (!ok) {
        throw Exception('Profile save failed');
      }
      await NotificationService.refreshToken();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      final reason = auth.error?.isNotEmpty == true ? auth.error! : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. $reason')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us about yourself',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.08),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_profileImage!.path),
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                ),
                              )
                            : Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 56,
                                color: theme.colorScheme.primary,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _profileImage == null ? 'Add Profile Picture' : 'Change Photo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                enabled: !_isUploading,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  hintText: 'e.g. Alexa Das',
                  prefixIcon: const Icon(Icons.badge_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _saveProfile,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    _isUploading ? 'Setting up...' : 'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
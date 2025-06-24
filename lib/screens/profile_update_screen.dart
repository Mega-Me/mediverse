import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediverse/services/api_service.dart';
import '../user_session.dart';

class ProfileUpdateScreen extends StatefulWidget {
  final String userId;

  const ProfileUpdateScreen({super.key, required this.userId});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _birthdateController = TextEditingController();
  final _phoneNoController = TextEditingController();
  String? _selectedGender;
  File? _imageFile;
  List<String> _selectedLanguages = [];

  bool _isLoading = true;

  final List<String> _languages = [
    'Amharic',
    'Arabic',
    'English',
    'Oromifa',
    'Tigrigna',
    'Welayeta',
  ];

  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await ApiService.getUserProfile(widget.userId);

      setState(() {
        _birthdateController.text = (userData['birthdate'] ?? '').split('T')[0];
        _phoneNoController.text = userData['phoneNumber'] ?? '';
        _selectedGender = userData['gender'];
        _selectedLanguages = List<String>.from(userData['preferredLanguage'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user profile')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthdateController.text = picked.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Update'),
        backgroundColor: const Color(0xFFF5F6FA),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text('Add Profile Image (Optional)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _birthdateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Birthdate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Birthdate is required'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneNoController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Phone number is required'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genders
                    .map((g) =>
                    DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (_) => _selectedGender == null
                    ? 'Gender is required'
                    : null,
              ),
              const SizedBox(height: 16),

              const Text(
                'Preferred Languages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: _languages.map((lang) {
                  return CheckboxListTile(
                    title: Text(lang),
                    value: _selectedLanguages.contains(lang),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedLanguages.add(lang);
                        } else {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedLanguages.isNotEmpty) {
                    final result = await ApiService.updateProfile(
                      userId: widget.userId,
                      birthdate: _birthdateController.text.trim(),
                      gender: _selectedGender!,
                      phone: _phoneNoController.text.trim(),
                      languages: _selectedLanguages,
                    );

                    if (result['success']) {
                      final user = result['data']['user'];
                      UserSession.userId = user['id'];
                      UserSession.fullName = user['fullName'];
                      UserSession.preferredLanguage = _selectedLanguages;
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );
                    }
                  } else if (_selectedLanguages.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select at least one language'),
                      ),
                    );
                  }
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

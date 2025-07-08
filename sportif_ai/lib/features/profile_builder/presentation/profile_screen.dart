import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/core/services/firebase_service.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedSport;
  String? _selectedGender;
  String? _selectedDietaryPreference;
  String? _selectedFitnessGoal;
  double _activityLevel = 1.2;
  bool _hydrationReminder = false;
  bool _mealReminder = false;
  File? _profileImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
        _selectedSport = user.sport;
        _selectedGender = user.gender;
        _ageController.text = user.age?.toString() ?? '';
        _heightController.text = user.height?.toString() ?? '';
        _weightController.text = user.weight?.toString() ?? '';
        _selectedDietaryPreference = user.dietaryPreference;
        _selectedFitnessGoal = user.fitnessGoal;
        _activityLevel = user.activityLevel ?? 1.2;
        _hydrationReminder = user.hydrationReminder;
        _mealReminder = user.mealReminder;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _profileImage = File(photo.path);
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      
      if (currentUser != null) {
        // TODO: Implement image upload to a storage service and get URL
        String? photoUrl = currentUser.photoUrl;
        
        // Parse numeric values
        int? age = _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null;
        double? height = _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null;
        double? weight = _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null;
        
        // For now, we'll just update the user data without the new image
        final updatedUser = currentUser.copyWith(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          sport: _selectedSport,
          photoUrl: photoUrl, // This will be updated once image upload is implemented
          gender: _selectedGender,
          age: age,
          height: height,
          weight: weight,
          dietaryPreference: _selectedDietaryPreference,
          fitnessGoal: _selectedFitnessGoal,
          activityLevel: _activityLevel,
          hydrationReminder: _hydrationReminder,
          mealReminder: _mealReminder,
        );

        final firebaseService = FirebaseService();
        await firebaseService.updateUserData(updatedUser);
        
        // Update the user in the provider
        authProvider.updateUser(updatedUser);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    final List<String> sports = [
      'Football',
      'Basketball',
      'Tennis',
      'Cricket',
      'Swimming',
      'Volleyball',
      'Baseball',
      'Rugby',
      'Golf',
      'Athletics',
      'Badminton',
      'Table Tennis',
    ];
    
    final List<String> genders = ['Male', 'Female', 'Other'];
    
    final List<String> dietaryPreferences = [
      'Vegetarian',
      'Non-Vegetarian',
      'Vegan',
      'Pescatarian',
      'Other',
    ];
    
    final List<String> fitnessGoals = [
      'Gain Muscle',
      'Cut Fat',
      'Maintain Weight',
      'Improve Performance',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _showImageSourceActionSheet,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (user.photoUrl != null
                              ? NetworkImage(user.photoUrl!) as ImageProvider
                              : null),
                      child: _profileImage == null && user.photoUrl == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                readOnly: true, // Email cannot be changed
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSport,
                decoration: const InputDecoration(
                  labelText: 'Favorite Sport',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports),
                ),
                items: sports.map((String sport) {
                  return DropdownMenuItem<String>(
                    value: sport,
                    child: Text(sport),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSport = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your favorite sport';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Fitness & Diet Information', style: TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: false,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: genders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                decoration: const InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.height),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedDietaryPreference,
                          decoration: const InputDecoration(
                            labelText: 'Dietary Preference',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.restaurant_menu),
                          ),
                          items: dietaryPreferences.map((String preference) {
                            return DropdownMenuItem<String>(
                              value: preference,
                              child: Text(preference),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDietaryPreference = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedFitnessGoal,
                          decoration: const InputDecoration(
                            labelText: 'Fitness Goal',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fitness_center),
                          ),
                          items: fitnessGoals.map((String goal) {
                            return DropdownMenuItem<String>(
                              value: goal,
                              child: Text(goal),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFitnessGoal = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Activity Level', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Slider(
                              value: _activityLevel,
                              min: 1.2,
                              max: 2.0,
                              divisions: 8,
                              label: _activityLevel.toStringAsFixed(1),
                              onChanged: (value) {
                                setState(() {
                                  _activityLevel = value;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Sedentary', style: TextStyle(fontSize: 12)),
                                Text('Moderate', style: TextStyle(fontSize: 12)),
                                Text('Very Active', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Hydration Reminders'),
                          subtitle: const Text('Get reminders to drink water throughout the day'),
                          value: _hydrationReminder,
                          onChanged: (bool value) {
                            setState(() {
                              _hydrationReminder = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Meal Reminders'),
                          subtitle: const Text('Get reminders for your scheduled meals'),
                          value: _mealReminder,
                          onChanged: (bool value) {
                            setState(() {
                              _mealReminder = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
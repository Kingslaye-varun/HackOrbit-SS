import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sportif_ai/core/models/user_model.dart';
import 'package:sportif_ai/core/services/firebase_service.dart';
import 'package:sportif_ai/features/auth/domain/auth_provider.dart';
import 'package:sportif_ai/features/profile_builder/presentation/drill_history_screen.dart';
import 'package:sportif_ai/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
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
  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Photo Library'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_camera, color: Colors.green),
                  ),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
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
        String? photoUrl = currentUser.photoUrl;
        
        int? age = _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null;
        double? height = _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null;
        double? weight = _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null;
        
        final updatedUser = currentUser.copyWith(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          sport: _selectedSport,
          photoUrl: photoUrl,
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
        
        authProvider.updateUser(updatedUser);
        
        setState(() {
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData(); // Reload original data
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      _buildProfileImage(),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.sport ?? 'Sports Enthusiast',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: _toggleEdit,
                ),
              if (_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _cancelEdit,
                ),
                IconButton(
                  icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, color: Colors.white),
                  onPressed: _isLoading ? null : _updateProfile,
                ),
              ],
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTabBar(),
                  const SizedBox(height: 20),
                  _buildTabBarView(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _isEditing ? _showImageSourceActionSheet : null,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : (Provider.of<AuthProvider>(context).user?.photoUrl != null
                      ? NetworkImage(Provider.of<AuthProvider>(context).user!.photoUrl!) as ImageProvider
                      : null),
              child: _profileImage == null && Provider.of<AuthProvider>(context).user?.photoUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(
            child: Text(
              'Basic Info',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Tab(
            child: Text(
              'Fitness Details',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicInfoTab(),
          _buildFitnessDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildCustomTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              enabled: false,
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              enabled: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCustomDropdown(
              value: _selectedSport,
              label: 'Favorite Sport',
              icon: Icons.sports,
              items: [
                'Football', 'Basketball', 'Tennis', 'Cricket', 'Swimming',
                'Volleyball', 'Baseball', 'Rugby', 'Golf', 'Athletics',
                'Badminton', 'Table Tennis',
              ],
              onChanged: _isEditing ? (value) {
                setState(() {
                  _selectedSport = value;
                });
              } : null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your favorite sport';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildCustomDropdown(
              value: _selectedGender,
              label: 'Gender',
              icon: Icons.person_outline,
              items: ['Male', 'Female', 'Other'],
              onChanged: _isEditing ? (value) {
                setState(() {
                  _selectedGender = value;
                });
              } : null,
            ),
            const SizedBox(height: 16),
            _buildCustomTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.calendar_today,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFitnessDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCustomTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCustomTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight_outlined,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCustomDropdown(
            value: _selectedDietaryPreference,
            label: 'Dietary Preference',
            icon: Icons.restaurant_menu,
            items: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Pescatarian', 'Other'],
            onChanged: _isEditing ? (value) {
              setState(() {
                _selectedDietaryPreference = value;
              });
            } : null,
          ),
          const SizedBox(height: 16),
          _buildCustomDropdown(
            value: _selectedFitnessGoal,
            label: 'Fitness Goal',
            icon: Icons.fitness_center,
            items: ['Gain Muscle', 'Cut Fat', 'Maintain Weight', 'Improve Performance', 'Other'],
            onChanged: _isEditing ? (value) {
              setState(() {
                _selectedFitnessGoal = value;
              });
            } : null,
          ),
          const SizedBox(height: 24),
          _buildActivityLevelSlider(),
          const SizedBox(height: 24),
          _buildReminderSwitches(),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(
            color: enabled ? Colors.grey[700] : Colors.grey[400],
            fontSize: 14,
          ),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(fontSize: 14),
          errorStyle: const TextStyle(fontSize: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityLevelSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Activity Level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: _activityLevel,
            min: 1.2,
            max: 2.0,
            divisions: 8,
            label: _activityLevel.toStringAsFixed(1),
            onChanged: _isEditing ? (value) {
              setState(() {
                _activityLevel = value;
              });
            } : null,
            activeColor: Theme.of(context).primaryColor,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sedentary', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Moderate', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('Very Active', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSwitches() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: SwitchListTile(
            title: const Text(
              'Hydration Reminders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Get reminders to drink water throughout the day',
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: _hydrationReminder,
            onChanged: _isEditing ? (value) {
              setState(() {
                _hydrationReminder = value;
              });
            } : null,
            activeColor: Theme.of(context).primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: SwitchListTile(
            title: const Text(
              'Meal Reminders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'Get reminders for your scheduled meals',
              style: TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: _mealReminder,
            onChanged: _isEditing ? (value) {
              setState(() {
                _mealReminder = value;
              });
            } : null,
            activeColor: Theme.of(context).primaryColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_isEditing)
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          if (_isEditing) const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: OutlinedButton.icon(
              onPressed: () {
                AppRoutes.navigateToDrillHistory(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(Icons.history, color: Theme.of(context).primaryColor),
              label: Text(
                'View Drill History',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
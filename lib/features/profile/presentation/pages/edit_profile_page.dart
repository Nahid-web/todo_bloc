import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:todo_bloc/core/di/injector.dart';

import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatelessWidget {
  final UserProfile profile;

  const EditProfilePage({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>(),
      child: EditProfileView(profile: profile),
    );
  }
}

class EditProfileView extends StatefulWidget {
  final UserProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    _displayNameController.text = widget.profile.displayName ?? '';
    _bioController.text = widget.profile.bio ?? '';
    _phoneController.text = widget.profile.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state is ProfileUpdating ? null : _saveProfile,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: state is ProfileUpdating
                        ? theme.disabledColor
                        : theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            Navigator.of(context).pop(true);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileUpdating) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display Name Field
                  FormBuilderTextField(
                    name: 'displayName',
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                      prefixIcon: Icon(Icons.person_outline),
                      helperText: 'This is how others will see your name',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.maxLength(50),
                    ]),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Bio Field
                  FormBuilderTextField(
                    name: 'bio',
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself',
                      prefixIcon: Icon(Icons.info_outline),
                      helperText: 'A short description about yourself',
                    ),
                    maxLines: 3,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.maxLength(200),
                    ]),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Phone Number Field
                  FormBuilderTextField(
                    name: 'phoneNumber',
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      helperText: 'Optional - for account recovery',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.match(
                        r'^[\+]?[1-9][\d]{0,15}$' as RegExp,
                        errorText: 'Please enter a valid phone number',
                      ),
                    ]),
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: 24),

                  // Email Information (Read-only)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email_outlined),
                              const SizedBox(width: 12),
                              Text(
                                'Email Address',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.profile.email,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                widget.profile.isEmailVerified
                                    ? Icons.verified
                                    : Icons.warning_outlined,
                                size: 16,
                                color: widget.profile.isEmailVerified
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.profile.isEmailVerified
                                    ? 'Verified'
                                    : 'Not verified',
                                style: TextStyle(
                                  color: widget.profile.isEmailVerified
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!widget.profile.isEmailVerified) ...[
                                const Spacer(),
                                TextButton(
                                  onPressed: _sendEmailVerification,
                                  child: const Text('Verify'),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'To change your email address, please contact support.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state is ProfileUpdating ? null : _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final updatedProfile = widget.profile.copyWith(
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        updatedAt: DateTime.now(),
      );

      context.read<ProfileBloc>().add(
            UpdateUserProfile(profile: updatedProfile),
          );
    }
  }

  void _sendEmailVerification() {
    // TODO: Implement email verification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verification feature will be available soon'),
      ),
    );
  }
}

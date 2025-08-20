import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePictureUrl;
  final String? displayName;
  final String email;
  final double size;
  final bool showBorder;

  const ProfilePictureWidget({
    super.key,
    this.profilePictureUrl,
    this.displayName,
    required this.email,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: theme.colorScheme.outline,
                width: 2,
              )
            : null,
      ),
      child: ClipOval(
        child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
            ? Image.network(
                profilePictureUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: size,
                    height: size,
                    color: theme.colorScheme.surfaceVariant,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.3,
                        height: size * 0.3,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar(theme);
                },
              )
            : _buildInitialsAvatar(theme),
      ),
    );
  }

  Widget _buildInitialsAvatar(ThemeData theme) {
    final initials = _getInitials();
    final fontSize = size * 0.4;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (displayName != null && displayName!.isNotEmpty) {
      final names = displayName!.trim().split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return displayName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

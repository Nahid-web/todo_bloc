import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile Entity', () {
    late UserProfile testProfile;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2025, 1, 15, 10, 30);
      testProfile = UserProfile(
        id: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        bio: 'Test bio description',
        profilePictureUrl: 'https://example.com/profile.jpg',
        phoneNumber: '+1234567890',
        isEmailVerified: true,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Constructor', () {
      test('should create UserProfile with all properties', () {
        expect(testProfile.id, 'user-123');
        expect(testProfile.email, 'test@example.com');
        expect(testProfile.displayName, 'Test User');
        expect(testProfile.bio, 'Test bio description');
        expect(
          testProfile.profilePictureUrl,
          'https://example.com/profile.jpg',
        );
        expect(testProfile.phoneNumber, '+1234567890');
        expect(testProfile.isEmailVerified, true);
        expect(testProfile.createdAt, testDate);
        expect(testProfile.updatedAt, testDate);
      });

      test('should create UserProfile with minimal required properties', () {
        final minimalProfile = UserProfile(
          id: 'minimal-user',
          email: 'minimal@example.com',
          isEmailVerified: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(minimalProfile.id, 'minimal-user');
        expect(minimalProfile.email, 'minimal@example.com');
        expect(minimalProfile.displayName, isNull);
        expect(minimalProfile.bio, isNull);
        expect(minimalProfile.profilePictureUrl, isNull);
        expect(minimalProfile.phoneNumber, isNull);
        expect(minimalProfile.isEmailVerified, false);
        expect(minimalProfile.createdAt, testDate);
        expect(minimalProfile.updatedAt, testDate);
      });
    });

    group('copyWith', () {
      test('should create new UserProfile with updated properties', () {
        final updatedProfile = testProfile.copyWith(
          displayName: 'Updated Name',
          bio: 'Updated bio',
          isEmailVerified: false,
        );

        expect(updatedProfile.id, testProfile.id);
        expect(updatedProfile.email, testProfile.email);
        expect(updatedProfile.displayName, 'Updated Name');
        expect(updatedProfile.bio, 'Updated bio');
        expect(updatedProfile.isEmailVerified, false);
        expect(updatedProfile.profilePictureUrl, testProfile.profilePictureUrl);
        expect(updatedProfile.phoneNumber, testProfile.phoneNumber);
      });

      test('should preserve original properties when not specified', () {
        final updatedProfile = testProfile.copyWith(displayName: 'New Name');

        expect(updatedProfile.email, testProfile.email);
        expect(updatedProfile.bio, testProfile.bio);
        expect(updatedProfile.profilePictureUrl, testProfile.profilePictureUrl);
        expect(updatedProfile.phoneNumber, testProfile.phoneNumber);
        expect(updatedProfile.isEmailVerified, testProfile.isEmailVerified);
        expect(updatedProfile.createdAt, testProfile.createdAt);
      });

      test('should preserve nullable properties when not specified', () {
        final profileWithNulls = UserProfile(
          id: 'null-test-id',
          email: 'null@example.com',
          displayName: null,
          bio: null,
          profilePictureUrl: null,
          phoneNumber: null,
          isEmailVerified: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final updatedProfile = profileWithNulls.copyWith(
          email: 'updated@example.com',
        );

        expect(updatedProfile.displayName, isNull);
        expect(updatedProfile.bio, isNull);
        expect(updatedProfile.profilePictureUrl, isNull);
        expect(updatedProfile.phoneNumber, isNull);
        expect(updatedProfile.id, 'null-test-id');
        expect(updatedProfile.email, 'updated@example.com');
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final profile1 = UserProfile(
          id: 'same-id',
          email: 'same@example.com',
          displayName: 'Same Name',
          isEmailVerified: true,
          createdAt: testDate,
          updatedAt: testDate,
        );

        final profile2 = UserProfile(
          id: 'same-id',
          email: 'same@example.com',
          displayName: 'Same Name',
          isEmailVerified: true,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profile1, equals(profile2));
        expect(profile1.hashCode, equals(profile2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final profile1 = testProfile;
        final profile2 = testProfile.copyWith(displayName: 'Different Name');

        expect(profile1, isNot(equals(profile2)));
        expect(profile1.hashCode, isNot(equals(profile2.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation containing key properties', () {
        final result = testProfile.toString();

        expect(result, contains('UserProfile'));
        expect(result, contains('user-123'));
        expect(result, contains('test@example.com'));
        expect(result, contains('Test User'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty strings properly', () {
        final profileWithEmptyStrings = UserProfile(
          id: 'user-empty',
          email: '',
          displayName: '',
          bio: '',
          profilePictureUrl: '',
          phoneNumber: '',
          isEmailVerified: false,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(profileWithEmptyStrings.email, '');
        expect(profileWithEmptyStrings.displayName, '');
        expect(profileWithEmptyStrings.bio, '');
        expect(profileWithEmptyStrings.profilePictureUrl, '');
        expect(profileWithEmptyStrings.phoneNumber, '');
      });

      test('should handle very long strings', () {
        final longString = 'A' * 1000;
        final profileWithLongStrings = testProfile.copyWith(
          displayName: longString,
          bio: longString,
        );

        expect(profileWithLongStrings.displayName, longString);
        expect(profileWithLongStrings.bio, longString);
      });
    });
  });
}

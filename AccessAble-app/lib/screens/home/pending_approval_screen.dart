import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProfile = authService.userProfile;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pending Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
                  size: 80,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Account Under Review',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Thank you for joining AccessAble! Your account is currently being reviewed by our administrators to ensure the safety and quality of our community.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // User Info Card
              if (userProfile != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Details',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.person,
                          'Name',
                          userProfile['fullName'] ?? 'Not provided',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.email,
                          'Email',
                          userProfile['email'] ?? 'Not provided',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.work,
                          'Role',
                          _getRoleDisplayName(userProfile['role'] ?? 'user'),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.calendar_today,
                          'Registered',
                          _formatDate(userProfile['createdAt']),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // What happens next
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'What happens next?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Our team will review your account within 24-48 hours\n'
                      "• You'll receive an email notification once approved\n"
                      '• You can then start exploring and contributing to AccessAble',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Refresh Button
              OutlinedButton.icon(
                onPressed: () {
                  // Refresh user profile to check if approved
                  authService.currentUser?.reload();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Check Status'),
              ),
              const SizedBox(height: 16),

              // Sign Out Button
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            authService.signOut();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'user':
        return 'Regular User';
      case 'caregiver':
        return 'Caregiver';
      case 'business':
        return 'Business Owner';
      default:
        return 'User';
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      // Handle Firestore Timestamp
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}

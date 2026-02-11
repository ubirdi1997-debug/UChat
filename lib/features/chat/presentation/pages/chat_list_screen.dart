import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../auth/presentation/pages/login_screen.dart';

/// Chat list screen
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('UChat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.avatar != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!.avatar!),
              )
            else
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 16),
            
            Text(
              user?.name ?? 'User',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            
            Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            
            // Empty state
            const Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            
            Text(
              'No chats yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            
            Text(
              'Start a conversation to see it here',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New chat feature coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

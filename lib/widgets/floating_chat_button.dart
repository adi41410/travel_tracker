import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class FloatingChatButton extends StatelessWidget {
  final bool show;

  const FloatingChatButton({super.key, this.show = true});

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      child: FloatingActionButton(
        onPressed: () {
          _showChatModal(context);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        heroTag: "chatButton", // Unique hero tag to avoid conflicts
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  void _showChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar for dragging
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Chat header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'AI Travel Assistant',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_full),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                          },
                          tooltip: 'Open in full screen',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Chat content - Remove the AppBar from ChatScreen when used in modal
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: const ChatScreen(showAppBar: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Alternative: Small floating button that opens full screen chat
class MiniFloatingChatButton extends StatelessWidget {
  const MiniFloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.chat, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// Widget wrapper for any screen to include the floating chat button
class ScreenWithChatButton extends StatelessWidget {
  final Widget child;
  final bool showChatButton;

  const ScreenWithChatButton({
    super.key,
    required this.child,
    this.showChatButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [child, if (showChatButton) const FloatingChatButton()],
    );
  }
}

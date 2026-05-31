import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motareb/features/chat/models/message_model.dart';
import 'package:motareb/features/chat/providers/chat_provider.dart';
import 'package:motareb/core/widgets/ads/banner_ad_widget.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'report_screen.dart';

// import '../providers/chat_provider.dart';
// import '../models/message_model.dart';
// import '../../home/widgets/banner_ad_widget.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  const ChatScreen({super.key, required this.chatId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Scroll Controllers for "Jump to Pin" functionality
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int _currentPinnedIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initUserChat();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(text);
    _chatController.clear();
    // Scroll to bottom (index 0)
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        if (!mounted) return;
        context.read<ChatProvider>().sendImageMessage(File(image.path));
        // Scroll to bottom
        if (_itemScrollController.isAttached) {
          _itemScrollController.jumpTo(index: 0);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _scrollToNextPinnedMessage(List<Message> messages) {
    final pinnedIndices = <int>[];
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isPinned) {
        pinnedIndices.add(i);
      }
    }

    if (pinnedIndices.isEmpty) return;

    setState(() {
      _currentPinnedIndex++;
      if (_currentPinnedIndex >= pinnedIndices.length) {
        _currentPinnedIndex = 0;
      }
    });

    final targetIndex = pinnedIndices[_currentPinnedIndex];

    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: targetIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<List<Message>>(
      stream: chatProvider.currentMessagesStream,
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        final hasPinnedMessages = messages.any((m) => m.isPinned);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: _buildAppBar(hasPinnedMessages, messages),
            body: Column(
              children: [
                const BannerAdWidget(),
                Expanded(
                  child: chatProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (snapshot.hasError)
                      ? const Center(child: Text('حدث خطأ'))
                      : (messages.isEmpty)
                      ? const Center(
                          child: Text('ابدأ المحادثة مع الدعم الفني'),
                        )
                      : ScrollablePositionedList.builder(
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _itemPositionsListener,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final msg = messages[index];
                            final currentUserId = context
                                .read<ChatProvider>()
                                .currentUserId;
                            final isMe = msg.senderId == currentUserId;

                            // Date Grouping
                            bool showDate = false;
                            if (index == messages.length - 1) {
                              showDate = true;
                            } else {
                              final nextMsg = messages[index + 1];
                              final currentDay = DateTime(
                                msg.timestamp.year,
                                msg.timestamp.month,
                                msg.timestamp.day,
                              );
                              final nextDay = DateTime(
                                nextMsg.timestamp.year,
                                nextMsg.timestamp.month,
                                nextMsg.timestamp.day,
                              );
                              if (currentDay != nextDay) {
                                showDate = true;
                              }
                            }

                            return Column(
                              children: [
                                if (showDate) _buildDateHeader(msg.timestamp),
                                if (msg.type == MessageType.system)
                                  _buildSystemMessage(msg)
                                else
                                  _buildMessageBubble(context, msg, isMe),
                              ],
                            );
                          },
                        ),
                ),
                _buildInputArea(chatProvider.isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(bool hasPinned, List<Message> messages) {
    return AppBar(
      title: Column(
        children: [
          Text(
            widget.userName,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
          Text(
            'الدعم الفني',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 1,
      centerTitle: true,
      iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
      actions: [
        if (hasPinned)
          IconButton(
            icon: const Icon(Icons.push_pin, color: Colors.orange),
            onPressed: () => _scrollToNextPinnedMessage(messages),
            tooltip: 'الانتقال للرسائل المثبتة',
          ),
        IconButton(
          icon: const Icon(Icons.report_gmailerrorred_outlined, color: Colors.redAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportScreen(),
              ),
            );
          },
          tooltip: 'إرسال بلاغ',
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    String text;
    if (msgDate == today) {
      text = 'اليوم';
    } else if (msgDate == yesterday) {
      text = 'أمس';
    } else {
      text = DateFormat('d MMMM yyyy', 'ar').format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  Widget _buildSystemMessage(Message msg) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.text,
          style: GoogleFonts.cairo(fontSize: 11, color: Colors.blueGrey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message msg, bool isMe) {
    return FadeInUp(
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            gradient: isMe
                ? const LinearGradient(
                    colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: !isMe ? Theme.of(context).cardTheme.color : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 0),
              bottomRight: Radius.circular(!isMe ? 16 : 0),
            ),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.push_pin,
                          size: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مثبتة',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (msg.type == MessageType.image)
                  _buildImageContent(msg)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Linkify(
                      text: msg.text,
                      onOpen: (link) async {
                        if (await canLaunchUrl(Uri.parse(link.url))) {
                          await launchUrl(
                            Uri.parse(link.url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      style: GoogleFonts.cairo(
                        color: isMe
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 15,
                      ),
                      linkStyle: GoogleFonts.cairo(
                        color: isMe ? Colors.white : Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (msg.isEdited)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.edit,
                            size: 10,
                            color: isMe ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      Text(
                        DateFormat('hh:mm a').format(msg.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: msg.isRead
                              ? Colors.blueAccent.shade100
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent(Message msg) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) =>
              Dialog(child: InteractiveViewer(child: Image.network(msg.text))),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          msg.text,
          width: 200,
          fit: BoxFit.cover,
          loadingBuilder: (ctx, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add_photo_alternate_rounded,
                color: Color(0xFF008695),
              ),
              onPressed: isLoading ? null : _pickAndSendImage,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: TextField(
                  controller: _chatController,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة...',
                    hintStyle: GoogleFonts.cairo(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : _sendMessage,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF39BB5E), Color(0xFF008695)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF008695).withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

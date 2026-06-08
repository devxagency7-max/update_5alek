import 'dart:async';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/extensions/loc_extension.dart';
import '../../../core/services/r2_upload_service.dart';
import '../../../core/services/remote_config_helper.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  // Basic Info
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();
  final _priceController = TextEditingController();

  final ValueNotifier<String?> _videoNotifier = ValueNotifier(null);
  final ValueNotifier<List<String>> _imagesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  // Upload progress state
  final Map<String, double> _uploadProgress = {};

  final ImagePicker _picker = ImagePicker();
  final R2UploadService _uploadService = R2UploadService();

  late String _tempDocId;
  String? _ownerId;
  String _ownerName = 'unknown';

  @override
  void initState() {
    super.initState();
    _tempDocId = FirebaseFirestore.instance
        .collection('pending_properties')
        .doc()
        .id;
    final user = FirebaseAuth.instance.currentUser;
    _ownerId = user?.uid;
    _ownerName = user?.displayName ?? user?.uid ?? 'unknown';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _detailsController.dispose();
    _priceController.dispose();
    _imagesNotifier.dispose();
    _isLoadingNotifier.dispose();
    _videoNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('يجب تسجيل الدخول أولاً', isError: true);
      return;
    }

    try {
      final List<XFile> pickedImages = await _picker.pickMultiImage();
      if (pickedImages.isNotEmpty) {
        final files = pickedImages.map((e) => File(e.path)).toList();
        await _processUploads(files);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الصور: $e', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('يجب تسجيل الدخول أولاً', isError: true);
      return;
    }

    try {
      final XFile? pickedVideo = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      if (pickedVideo != null) {
        final file = File(pickedVideo.path);
        await _processVideoUpload(file);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الفيديو: $e', isError: true);
    }
  }

  Future<void> _processUploads(List<File> files) async {
    for (final file in files) {
      if (!mounted) return;
      setState(() {
        _uploadProgress[file.path] = 0.1;
      });
      try {
        final fileName = file.path.split(Platform.pathSeparator).last;
        // sanitize owner name for path
        final safeName = _ownerName.replaceAll(
          RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'),
          '_',
        );
        final customPath = 'waiting/$safeName/$fileName';

        final url = await _uploadService.uploadFile(
          file,
          ownerId: _ownerId,
          propertyUuid: _tempDocId,
          customPath: customPath,
          onProgress: (sent, total) {
            if (mounted)
              setState(() {
                _uploadProgress[file.path] = sent / total;
              });
          },
        );
        if (mounted) {
          final currentImages = List<String>.from(_imagesNotifier.value);
          currentImages.add(url);
          _imagesNotifier.value = currentImages;
          setState(() {
            _uploadProgress.remove(file.path);
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _uploadProgress.remove(file.path);
          });
          _showSnackBar('فشل رفع الصورة: $e', isError: true);
        }
      }
    }
  }

  Future<void> _processVideoUpload(File file) async {
    if (!mounted) return;
    setState(() {
      _uploadProgress[file.path] = 0.1;
    });
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final safeName = _ownerName.replaceAll(
        RegExp(r'[^a-zA-Z0-9\u0600-\u06FF]'),
        '_',
      );
      final customPath = 'waiting/$safeName/$fileName';

      final url = await _uploadService.uploadFile(
        file,
        ownerId: _ownerId,
        propertyUuid: _tempDocId,
        customPath: customPath,
        onProgress: (sent, total) {
          if (mounted)
            setState(() {
              _uploadProgress[file.path] = sent / total;
            });
        },
      );
      if (mounted) {
        _videoNotifier.value = url;
        setState(() {
          _uploadProgress.remove(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadProgress.remove(file.path);
        });
        _showSnackBar('فشل رفع الفيديو: $e', isError: true);
      }
    }
  }

  Future<void> _deleteImage(String url) async {
    final currentImages = List<String>.from(_imagesNotifier.value);
    currentImages.remove(url);
    _imagesNotifier.value = currentImages;
  }

  Future<void> _submitProperty() async {
    // Validation
    final phoneEmpty =
        RemoteConfigHelper.showPhoneField &&
        _phoneController.text.trim().isEmpty;
    if (phoneEmpty ||
        _detailsController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      _showSnackBar(
        RemoteConfigHelper.showPhoneField
            ? 'الرجاء إدخال رقم الهاتف، السعر، وتفاصيل الشقة'
            : 'الرجاء إدخال السعر وتفاصيل الشقة',
        isError: true,
      );
      return;
    }

    if (_uploadProgress.isNotEmpty) {
      _showSnackBar('الرجاء الانتظار حتى انتهاء رفع الصور', isError: true);
      return;
    }

    _isLoadingNotifier.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Fetch full user details
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data() ?? {};

      final propertyData = {
        'id': _tempDocId,
        'propertyId': _tempDocId,
        'ownerId': user.uid,
        'ownerName': _ownerName,
        'ownerPhone': _phoneController.text.trim(),
        'description': _detailsController.text.trim(),
        'images': _imagesNotifier.value,
        'videoUrl': _videoNotifier.value,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        // Store full user details
        'ownerDetails': userData,

        // Default/Placeholder values
        'title': 'New Property Request',
        'price': double.tryParse(_priceController.text.trim()) ?? 0,
        'location': '',
        'roomsCount': 0,
        'bedsCount': 0,
        'isVerified': false,
      };

      await FirebaseFirestore.instance
          .collection('pending_properties')
          .doc(_tempDocId)
          .set(propertyData);

      if (mounted) {
        _showSnackBar(
          'تم إرسال العقار للمراجعة بنجاح! سيقوم المشرف بمراجعته قريباً ✅',
          isError: false,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('حدث خطأ: $e', isError: true);
      }
    } finally {
      if (mounted) _isLoadingNotifier.value = false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.brandPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'إضافة عقار جديد',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('الوسائط (صور وفيديو)'),
                        const SizedBox(height: 10),
                        _buildImagePicker(),
                        const SizedBox(height: 15),
                        _buildVideoPicker(),
                        const SizedBox(height: 25),

                        _buildSectionTitle('المعلومات الأساسية'),
                        const SizedBox(height: 15),
                        if (RemoteConfigHelper.showPhoneField) ...[
                          _buildTextField(
                            _phoneController,
                            'رقم التواصل (فون)',
                            Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),
                        ],
                        _buildTextField(
                          _priceController,
                          'السعر المطلوب (ج.م)',
                          Icons.attach_money_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 15),
                        _buildTextField(
                          _detailsController,
                          'تفاصيل الشقة',
                          Icons.description_rounded,
                          minLines: 3,
                          maxLines: null,
                        ),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isLoadingNotifier,
        builder: (context, isLoading, _) {
          return GestureDetector(
            onTap: isLoading ? null : _submitProperty,
            child: Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brandPrimary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        'إرسال للمراجعة',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int? maxLines = 1,
    int? minLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        minLines: minLines,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.brandPrimary.withOpacity(0.7)),
          alignLabelWithHint: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.brandPrimary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _imagesNotifier,
      builder: (context, images, _) {
        final isUploading = _uploadProgress.isNotEmpty;

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1 + (isUploading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: isUploading ? null : _pickImages,
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: isUploading
                          ? Colors.grey.shade200
                          : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.brandPrimary.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isUploading)
                          const CircularProgressIndicator(strokeWidth: 2)
                        else ...[
                          const Icon(
                            Icons.add_a_photo_rounded,
                            color: AppTheme.brandPrimary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'إضافة صور (اختياري)',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.brandPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              if (isUploading && index == 1) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Text('جاري الرفع...')),
                );
              }

              final urlIndex = index - 1 - (isUploading ? 1 : 0);
              if (urlIndex < 0 || urlIndex >= images.length)
                return const SizedBox();

              final url = images[urlIndex];

              return Container(
                width: 120,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _deleteImage(url),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoPicker() {
    return ValueListenableBuilder<String?>(
      valueListenable: _videoNotifier,
      builder: (context, videoUrl, _) {
        final isUploading = _uploadProgress.keys.any(
          (k) =>
              k.toLowerCase().endsWith('.mp4') ||
              k.toLowerCase().endsWith('.mov'),
        );

        return GestureDetector(
          onTap: isUploading ? null : (videoUrl == null ? _pickVideo : null),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: videoUrl != null
                    ? Colors.green
                    : AppTheme.brandPrimary.withOpacity(0.3),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  videoUrl != null
                      ? Icons.check_circle
                      : Icons.videocam_rounded,
                  color: videoUrl != null
                      ? Colors.green
                      : AppTheme.brandPrimary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    videoUrl != null
                        ? 'تم رفع الفيديو بنجاح ✅'
                        : 'إضافة فيديو (اختياري)',
                    style: GoogleFonts.cairo(
                      color: videoUrl != null ? Colors.green : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (videoUrl != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _videoNotifier.value = null,
                  )
                else if (isUploading)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: _uploadProgress
                              .values
                              .first, // Assuming single video upload at a time or filter by key
                          backgroundColor: Colors.grey[200],
                          color: AppTheme.brandPrimary,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'جاري الرفع... ${((_uploadProgress.values.first) * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

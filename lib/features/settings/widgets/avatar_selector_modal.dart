import 'package:flutter/material.dart';
import 'package:genius_hormo/core/api/api_response.dart';
import 'package:genius_hormo/features/auth/services/user_storage_service.dart';
import 'package:genius_hormo/services/profile_service.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class AvatarSelectorModal extends StatefulWidget {
  final String? currentAvatarUrl;
  final Function(String) onAvatarSelected;

  const AvatarSelectorModal({
    Key? key,
    this.currentAvatarUrl,
    required this.onAvatarSelected,
  }) : super(key: key);

  @override
  State<AvatarSelectorModal> createState() => _AvatarSelectorModalState();
}

class _AvatarSelectorModalState extends State<AvatarSelectorModal> {
  final ProfileService _profileService = ProfileService();
  final UserStorageService _storageService = UserStorageService();
  
  List<String> _avatars = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.currentAvatarUrl;
    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _storageService.getJWTToken();
      if (token == null) {
        setState(() {
          final localizations = AppLocalizations.of(context)!;
          _error = localizations['settings']['avatarModal']['tokenNotFound'];
          _isLoading = false;
        });
        return;
      }

      final response = await _profileService.getAvatars(token: token);

      if (response.success && response.data != null) {
        setState(() {
          _avatars = response.data!.avatars;
          _isLoading = false;
        });
      } else {
        setState(() {
          final localizations = AppLocalizations.of(context)!;
          _error = response.message ?? localizations['settings']['avatarModal']['loadError'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        final localizations = AppLocalizations.of(context)!;
        _error = '${localizations['settings']['avatarModal']['connectionError']}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2C),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!['settings']['avatarModal']['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.white70),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAvatars,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: Text(AppLocalizations.of(context)!['settings']['avatarModal']['retry']),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _avatars.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!['settings']['avatarModal']['noAvatars'],
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: _avatars.length,
                            itemBuilder: (context, index) {
                              final avatarUrl = _avatars[index];
                              final isSelected = _selectedAvatar == avatarUrl;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatar = avatarUrl;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.5),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey[800],
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                                valueColor: const AlwaysStoppedAnimation<Color>(
                                                  Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),

          // Footer with confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedAvatar != null
                    ? () {
                        widget.onAvatarSelected(_selectedAvatar!);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!['settings']['avatarModal']['confirm'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

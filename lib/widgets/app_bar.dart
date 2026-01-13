import 'package:flutter/material.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? avatarUrl;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onAvatarPressed;
  final int unreadCount;
  final bool showNotifications; // Nuevo parámetro para controlar visibilidad

  const ModernAppBar({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.onNotificationPressed,
    this.onAvatarPressed,
    this.unreadCount = 0,
    this.showNotifications = true, // Por defecto muestra notificaciones
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = _formatDate(context, now);

    return AppBar(
      backgroundColor: Colors.transparent,
      // elevation: 0.5,
      // shadowColor: Colors.black12,
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Sección izquierda - Avatar
            GestureDetector(
              onTap: onAvatarPressed,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 0.5,
                  ),
                ),
                child: avatarUrl != null && avatarUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: Icon(Icons.person, color: Colors.grey[600]),
                            );
                          },
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[800],
                        ),
                        child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
              ),
            ),

            // Sección central - Textos
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!['header']['greeting']}, $userName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),

            // Sección derecha - Notificaciones con Badge (solo si showNotifications es true)
            if (showNotifications)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 0.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: onNotificationPressed,
                      icon: Icon(
                        Icons.notifications_none,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 30,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // Badge con contador
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            else
              const SizedBox(width: 40), // Espacio vacío cuando no hay notificaciones
          ],
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final localizations = AppLocalizations.of(context)!;
    final daysMap = localizations['header']['days'];
    final monthsMap = localizations['header']['months'];
    
    final dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    final monthKeys = ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'];
    
    final dayName = daysMap[dayKeys[date.weekday - 1]];
    final day = date.day;
    final month = monthsMap[monthKeys[date.month - 1]];
    final year = date.year;

    return '$dayName, $day $month $year';
  }
}

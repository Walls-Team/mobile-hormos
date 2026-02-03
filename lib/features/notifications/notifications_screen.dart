import 'package:flutter/material.dart';
import 'package:genius_hormo/services/local_notifications_service.dart';
import 'package:provider/provider.dart';
import 'package:genius_hormo/l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Configurar timeago en español
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!['notifications']['title']),
        actions: [
          // Marcar todas como leídas
          Consumer<LocalNotificationsService>(
            builder: (context, notificationService, child) {
              if (notificationService.unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Marcar todas como leídas',
                  onPressed: () async {
                    await notificationService.markAllAsRead();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ ${AppLocalizations.of(context)!['notifications']['markAllRead']}'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Eliminar todas
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete_all') {
                _showDeleteAllDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!['notifications']['deleteAll']),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<LocalNotificationsService>(
        builder: (context, notificationService, child) {
          final notifications = notificationService.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await notificationService.initialize();
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(
                  context,
                  notification,
                  notificationService,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las notificaciones aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    LocalNotification notification,
    LocalNotificationsService service,
  ) {
    final timeAgo = timeago.format(
      notification.timestamp,
      locale: 'es',
      allowFromNow: true,
    );

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await service.deleteNotification(notification.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🗑️ ${AppLocalizations.of(context)!['notifications']['notificationDeleted']}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: InkWell(
        onTap: () async {
          // Marcar como leída
          await service.markAsRead(notification.id);
          
          // Navegar según el tipo de notificación
          _handleNotificationTap(context, notification);
        },
        child: Container(
          color: notification.isRead
              ? Colors.transparent
              : Theme.of(context).colorScheme.primary.withOpacity(0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono según tipo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        // Badge de no leído
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'daily_reminder':
        return Icons.assignment_outlined;
      case 'new_data':
        return Icons.insights;
      case 'device_sync':
        return Icons.sync;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'daily_reminder':
        return Colors.orange;
      case 'new_data':
        return Colors.blue;
      case 'device_sync':
        return Colors.green;
      case 'achievement':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  void _handleNotificationTap(BuildContext context, LocalNotification notification) {
    // TODO: Navegar según el tipo de notificación
    final type = notification.type;
    
    switch (type) {
      case 'daily_reminder':
        // Navegar al cuestionario
        debugPrint('📝 Navegando al cuestionario...');
        break;
      case 'new_data':
        // Navegar al dashboard
        debugPrint('📊 Navegando al dashboard...');
        Navigator.pop(context);
        break;
      case 'device_sync':
        // Navegar a ajustes
        debugPrint('⚙️ Navegando a ajustes...');
        break;
      default:
        debugPrint('ℹ️ Notificación sin acción específica');
    }
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!['notifications']['deleteAllTitle']),
        content: Text(
          AppLocalizations.of(context)!['notifications']['deleteAllMessage'],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!['notifications']['cancel']),
          ),
          TextButton(
            onPressed: () async {
              final service = Provider.of<LocalNotificationsService>(
                context,
                listen: false,
              );
              await service.deleteAll();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ ${AppLocalizations.of(context)!['notifications']['allNotificationsDeleted']}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!['notifications']['delete']),
          ),
        ],
      ),
    );
  }
}

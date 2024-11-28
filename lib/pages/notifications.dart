import 'package:flutter/material.dart';
import 'package:hydroponics/services/api_service.dart';
import 'package:hydroponics/services/models.dart' as models; // Alias the models.dart import

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<models.Notification>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = ApiService().fetchNotifications(); // Fetch notifications when page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<List<models.Notification>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          } else {
            List<models.Notification> notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];

                // Icon for the left side based on notification type
                Icon leadingIcon;
                switch (notification.type) {
                  case 'warning':
                    leadingIcon = Icon(Icons.warning, color: Colors.orange);
                    break;
                  case 'error':
                    leadingIcon = Icon(Icons.error, color: Colors.red);
                    break;
                  case 'info':
                    leadingIcon = Icon(Icons.info, color: Colors.blue);
                    break;
                  default:
                    leadingIcon = Icon(Icons.notifications, color: Colors.green);
                }

                return ListTile(
                  leading: leadingIcon, // Icon on the left side
                  title: Text(notification.message),
                  subtitle: Text(notification.created_at),
                  onTap: () {
                    setState(() {
                      notification.isRead = true;
                    });
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

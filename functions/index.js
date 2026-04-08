const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

/**
 * Fires when a new document is added to lnu_notifications.
 * Sends an FCM message to the 'lnu_notifications' topic so ALL
 * subscribed devices receive a push — even when the app is killed.
 */
exports.onNewNotification = onDocumentCreated(
  'lnu_notifications/{docId}',
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const title = (data.title ?? 'LNU LinkUp').replace(/\n/g, ' ');
    const sender = data.sender ?? 'Quality Assurance';
    const department = data.department ?? 'QUALITY ASSURANCE';
    const body = `From ${sender} · ${department}`;

    const message = {
      topic: 'lnu_notifications',
      notification: { title, body },
      android: {
        priority: 'high',
        notification: {
          channelId: 'lnu_channel',
          priority: 'max',
          defaultSound: true,
          defaultVibrateTimings: true,
        },
      },
      apns: {
        headers: { 'apns-priority': '10' },
        payload: {
          aps: {
            alert: { title, body },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await getMessaging().send(message);
      console.log('FCM sent:', response);
    } catch (err) {
      console.error('FCM send failed:', err);
    }
  },
);

// Firebase Messaging Service Worker
// Handles background push notifications on web (including iOS Safari 16.4+
// when the PWA is added to the Home Screen).

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyCfD8sTAbAnBIM7PZ8qvOemlUkU9PN10w0',
  authDomain: 'qaoautomation.firebaseapp.com',
  projectId: 'qaoautomation',
  storageBucket: 'qaoautomation.firebasestorage.app',
  messagingSenderId: '1067823960365',
  appId: '1:1067823960365:web:5c3be9fbfb604ec9bf03a4',
});

const messaging = firebase.messaging();

// Called when a push arrives while the PWA is in the background or closed.
messaging.onBackgroundMessage((payload) => {
  const title   = payload.notification?.title ?? payload.data?.title   ?? 'LinkUp';
  const body    = payload.notification?.body  ?? payload.data?.body    ?? 'You have a new notification.';
  const icon    = '/link_up/icons/Icon-192.png';
  const badge   = '/link_up/icons/Icon-192.png';

  return self.registration.showNotification(title, {
    body,
    icon,
    badge,
    data: payload.data ?? {},
    vibrate: [200, 100, 200],
  });
});

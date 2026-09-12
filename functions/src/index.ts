import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

async function sendPushToUser(fcmToken: string, title: string, body: string, data: Record<string, string>) {
  if (!fcmToken) return;
  const message = {
    token: fcmToken,
    notification: { title, body },
    android: {
      priority: 'high',
      channelId: 'alexa_art_classes',
      notification: { title, body, clickAction: 'FLUTTER_NOTIFICATION_CLICK' },
    },
    data,
  } as admin.messaging.Message;

  try {
    await admin.messaging().send(message);
  } catch (e) {
    functions.logger.warn('FCM send failed for token', fcmToken, e);
  }
}

export const onNotificationCreated = functions.firestore
  .document('notifications/{docId}')
  .onCreate(async (snap) => {
    const body = snap.data() as {
      title?: string;
      body?: string;
      targetRole?: string;
      specificUserIds?: string[];
    };

    const title = body.title ?? 'Alexa Arts Classes';
    const messageBody = body.body ?? '';
    const targetRole = body.targetRole ?? '';
    const specificUserIds = body.specificUserIds ?? [];

    let q = db.collection('users').select('fcmToken', 'role');
    if (targetRole && targetRole !== 'all') {
      q = q.where('role', '==', targetRole);
    }
    if (specificUserIds.length > 0) {
      q = db.collection('users')
        .where(admin.firestore.FieldPath.documentId(), 'in', specificUserIds.slice(0, 10));
    }
    const usersSnap = await q.get();
    const data = { navigate: 'notifications', docId: snap.id };

    const sends = usersSnap.docs
      .map((u) => sendPushToUser(u.get('fcmToken') ?? '', title, messageBody, data));
    await Promise.all(sends);
    return null;
  });
const admin = require('firebase-admin');

if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
  console.error('FIREBASE_SERVICE_ACCOUNT env missing');
  process.exit(1);
}

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function main() {
  const snap = await db
    .collection('notifications')
    .where('pushSent', '==', false)
    .limit(20)
    .get();

  if (snap.size === 0) {
    console.log('No pending notifications');
    return;
  }

  for (const doc of snap.docs) {
    const data = doc.data();
    const title = data.title || 'Alexa Arts Classes';
    const body = data.body || '';
    const targetRole = data.targetRole || '';

    let q = db.collection('users');
    if (targetRole && targetRole !== 'all') {
      q = q.where('role', '==', targetRole);
    }
    const usersSnap = await q.get();
    const tokens = usersSnap.docs
      .map((u) => u.get('fcmToken') || '')
      .filter((t) => t.length > 20);

    if (tokens.length === 0) {
      console.log(`No tokens for ${doc.id}`);
      await doc.ref.update({ pushSent: true, pushSentAt: admin.firestore.FieldValue.serverTimestamp(), sentCount: 0 });
      continue;
    }

    for (let i = 0; i < tokens.length; i += 500) {
      const batch = tokens.slice(i, i + 500);
      const message = {
        tokens: batch,
        notification: { title, body },
        android: {
          priority: 'high',
          notification: {
            icon: 'ic_notification',
            color: '#4F46E5',
            channelId: 'alexa_art_classes',
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
        data: { navigate: 'notifications', docId: doc.id },
      };

let sent = 0;
    let failed = 0;
    try {
      const res = await admin.messaging().sendEachForMulticast(message);
      sent = res.successCount;
      failed = res.failureCount;
    } catch (e) {
      console.error('FCM batch error:', e.message);
    }
      console.log(`${doc.id}: tokens=${batch.length} sent=${sent} failed=${failed}`);
      await doc.ref.update({
        sentCount: admin.firestore.FieldValue.increment(sent),
        lastPushAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await doc.ref.update({ pushSent: true, pushSentAt: admin.firestore.FieldValue.serverTimestamp() });
  }
  console.log('Done');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
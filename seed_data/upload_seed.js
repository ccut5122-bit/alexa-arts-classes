// One-click seed uploader for Alexa Arts Classes
// Usage: node upload_seed.js
// Requires: Create serviceAccount.json from Firebase Console > Project Settings > Service Accounts

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccount.json');
const seedData = require('./alexa_seed.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const db = admin.firestore();

async function upload() {
  const now = admin.firestore.Timestamp.now();
  let count = 0;

  console.log('=====================================');
  console.log(' Alexa Arts Classes - Seed Uploader');
  console.log('=====================================\n');

  // 1. SUBJECTS
  console.log('📚 Uploading subjects...');
  for (const subject of seedData.subjects) {
    const { _id, ...data } = subject;
    await db.collection('subjects').doc(_id).set({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    count++;
    console.log(`   ✅ ${subject.name}`);
  }

  // 2. CHAPTERS
  console.log('\n📖 Uploading chapters...');
  for (const chapter of seedData.chapters) {
    const { _id, ...data } = chapter;
    await db.collection('chapters').doc(_id).set({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    count++;
    console.log(`   ✅ ${chapter.title}`);
  }

  // 3. NOTES
  console.log('\n🗒️  Uploading notes...');
  for (const note of seedData.notes) {
    const { _id, ...data } = note;
    await db.collection('notes').doc(_id).set({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    count++;
    console.log(`   ✅ ${note.title}`);
  }

  // 4. QUESTIONS
  console.log('\n❓ Uploading questions...');
  for (const question of seedData.questions) {
    const { _id, ...data } = question;
    await db.collection('questions').doc(_id).set({
      ...data,
      createdAt: now,
      updatedAt: now,
    });
    count++;
    console.log(`   ✅ ${question.questionText.slice(0, 40)}...`);
  }

  // 5. DYNAMIC CONFIG - Coins & featured subjects
  console.log('\n⚙️  Uploading default config...');
  await db.collection('dynamicConfig').doc('coinsConfig').set({
    quizAttemptCoins: 10,
    correctAnswerCoins: 5,
    streakBonusCoins: 20,
    noteReadCoins: 3,
    monthlyQuizPrizeCoins: 500,
    specialTestUnlockCoins: 100,
    updatedAt: now,
  });
  await db.collection('dynamicConfig').doc('themeConfig').set({
    primaryColor: '#6C63FF',
    secondaryColor: '#00C9A7',
    accentColor: '#FF6B35',
    darkMode: false,
    appName: 'Alexa Arts Classes',
    logoUrl: '',
    updatedAt: now,
  });
  await db.collection('dynamicConfig').doc('featuredSubjects').set({
    subjectIds: ['history', 'political_science', 'economics', 'geography'],
    updatedAt: now,
  });
  await db.collection('dynamicConfig').doc('noticeBoard').set({
    notices: [{
      id: 'welcome',
      title: 'Welcome to Alexa Arts Classes! 🎉',
      body: 'Apni padhai shuru karo. Daily streak banaye rakho aur Alexa Coins kamaye!',
      type: 'info',
      isPopup: true,
      isActive: true,
      createdAt: now,
    }],
    updatedAt: now,
  });
  count += 4;
  console.log('   ✅ Configs set (coins, theme, featured, notices)');

  // 6. BADGES
  console.log('\n🏅 Uploading badges...');
  await db.collection('badges').doc('streak_3').set({
    name: 'Flame Starter',
    nameHindi: 'ज्वाला प्रारंभक',
    description: 'Complete a 3-day study streak',
    category: 'streak',
    requiredValue: 3,
    iconUrl: '',
    createdAt: now,
  });
  await db.collection('badges').doc('streak_7').set({
    name: 'Week Warrior',
    nameHindi: 'सप्ताह योद्धा',
    description: 'Complete a 7-day study streak',
    category: 'streak',
    requiredValue: 7,
    iconUrl: '',
    createdAt: now,
  });
  await db.collection('badges').doc('quiz_10').set({
    name: 'Quiz Champ',
    nameHindi: 'क्विज़ चैंपियन',
    description: 'Attempt 10 quizzes',
    category: 'quiz',
    requiredValue: 10,
    iconUrl: '',
    createdAt: now,
  });
  await db.collection('badges').doc('quiz_50').set({
    name: 'Master Tester',
    nameHindi: 'मास्टर टेस्टर',
    description: 'Attempt 50 quizzes',
    category: 'quiz',
    requiredValue: 50,
    iconUrl: '',
    createdAt: now,
  });
  count += 4;
  console.log('   ✅ 4 badges added');

  console.log(`\n✅ Done! ${count} records uploaded successfully.`);
  console.log('🎉 Ab apna admin panel aur app kholo — sab ready hai!');
  process.exit(0);
}

upload().catch((err) => {
  console.error('❌ Upload failed:', err.message);
  process.exit(1);
});
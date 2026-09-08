# Alexa Arts Classes - Firestore Database Schema

```json
{
  "users/{userId}": {
    "uid": "string",
    "email": "string",
    "displayName": "string",
    "photoUrl": "string",
    "phone": "string",
    "role": "student | admin | teacher",
    "className": "11 | 12",
    "stream": "arts",
    "district": "string",
    "school": "string",
    "isPremium": "boolean",
    "isBanned": "boolean",
    "subscriptionExpiry": "timestamp",
    "createdAt": "timestamp",
    "lastActive": "timestamp",

    "gamification": {
      "coins": "number (default: 0)",
      "streak": {
        "currentDays": "number",
        "longestStreak": "number",
        "lastStudyDate": "date_string YYYY-MM-DD"
      },
      "badges": ["badge_id_1", "badge_id_2"],
      "totalQuizzesAttempted": "number",
      "totalCorrectAnswers": "number",
      "rank": "number",
      "level": "number"
    },

    "progress/{subjectId}": {
      "subjectId": "string",
      "chaptersCompleted": ["chapter_1", "chapter_2"],
      "notesRead": ["chapter_1", "chapter_3"],
      "currentChapter": "string",
      "completionPercent": "number",
      "chapterProgress/{chapterId}": {
        "read": "boolean",
        "mcqScore": "number",
        "totalMcqs": "number",
        "lastAttempted": "timestamp"
      }
    },

    "bookmarks/{bookmarkId}": {
      "type": "note | question | chapter",
      "contentId": "string",
      "subjectId": "string",
      "chapterId": "string",
      "createdAt": "timestamp"
    },

    "quizHistory/{quizId}": {
      "quizId": "string",
      "quizType": "chapter | monthly | revision | custom",
      "score": "number",
      "totalQuestions": "number",
      "correctAnswers": "number",
      "timeTaken": "number (seconds)",
      "negativeMarking": "boolean",
      "wrongQuestions": ["q_id_1", "q_id_2"],
      "completedAt": "timestamp"
    },

    "examCountdown": {
      "examName": "string",
      "examDate": "timestamp",
      "subjects": ["subject_1", "subject_2"]
    },

    "offlineCache": {
      "notesCached": ["note_id_1"],
      "mcqsCached": ["quiz_id_1"],
      "lastSynced": "timestamp"
    }
  },

  "subjects/{subjectId}": {
    "id": "string",
    "name": "History | Political Science | Economics | Geography | Sociology | Psychology",
    "nameHindi": "string",
    "icon": "string (icon_name)",
    "color": "#hex",
    "order": "number",
    "totalChapters": "number",
    "isFeatured": "boolean",
    "description": "string",
    "descriptionHindi": "string",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },

  "chapters/{chapterId}": {
    "id": "string",
    "subjectId": "ref(subjects)",
    "chapterNumber": "number",
    "title": "string",
    "titleHindi": "string",
    "description": "string",
    "totalNotesPages": "number",
    "totalMcqs": "number",
    "difficulty": "easy | medium | hard",
    "tags": ["important", "frequently_asked"],
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },

  "notes/{noteId}": {
    "id": "string",
    "chapterId": "ref(chapters)",
    "subjectId": "ref(subjects)",
    "pageNumber": "number",
    "title": "string",
    "content": "string (rich text / markdown)",
    "contentHindi": "string",
    "imageUrl": "string (optional diagram/map)",
    "audioUrl": "string (TTS or pre-recorded audio)",
    "keyPoints": ["point_1", "point_2"],
    "createdAt": "timestamp"
  },

  "questions/{questionId}": {
    "id": "string",
    "subjectId": "ref(subjects)",
    "chapterId": "ref(chapters)",
    "type": "mcq | map_based | diagram",
    "questionText": "string",
    "questionTextHindi": "string",
    "questionImageUrl": "string (optional)",
    "options": [
      {"id": "a", "text": "string", "imageUrl": "string (optional)"},
      {"id": "b", "text": "string"},
      {"id": "c", "text": "string"},
      {"id": "d", "text": "string"}
    ],
    "correctOption": "a | b | c | d",
    "explanation": "string",
    "explanationHindi": "string",
    "explanationImageUrl": "string (optional)",
    "difficulty": "easy | medium | hard",
    "tags": ["pyq_2024", "important"],
    "source": "JAC PYQ | Custom | NCERT",
    "year": "number (for PYQs)",
    "marks": "number",
    "negativeMarks": "number",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },

  "quizzes/{quizId}": {
    "id": "string",
    "title": "string",
    "type": "chapter | monthly | revision | custom",
    "subjectId": "ref(subjects)",
    "chapterIds": ["chapter_1", "chapter_2"],
    "questionIds": ["q_1", "q_2", "q_3"],
    "totalQuestions": "number",
    "timeLimit": "number (minutes)",
    "negativeMarking": "boolean",
    "negativeMarksPerWrong": "number",
    "isLive": "boolean",
    "scheduledDate": "timestamp",
    "expiresAt": "timestamp",
    "createdBy": "ref(users)",
    "createdAt": "timestamp"
  },

  "monthlyQuizSeries/{seriesId}": {
    "id": "string",
    "month": "string (YYYY-MM)",
    "title": "string",
    "quizIds": ["quiz_1", "quiz_2"],
    "totalParticipants": "number",
    "isActive": "boolean",
    "prizeCoins": "number",
    "createdAt": "timestamp"
  },

  "leaderboard/{period}": {
    "period": "weekly | monthly | allTime",
    "entries/{userId}": {
      "userId": "string",
      "displayName": "string",
      "photoUrl": "string",
      "coins": "number",
      "level": "number",
      "rank": "number",
      "quizzesCompleted": "number",
      "avgScore": "number",
      "updatedAt": "timestamp"
    }
  },

  "forum/{postId}": {
    "id": "string",
    "authorId": "ref(users)",
    "authorName": "string",
    "authorPhoto": "string",
    "subjectId": "ref(subjects)",
    "chapterId": "ref(chapters) (optional)",
    "title": "string",
    "body": "string",
    "imageUrls": ["url_1"],
    "tags": ["doubt", "discussion"],
    "isResolved": "boolean",
    "upvotes": "number",
    "upvotedBy": ["userId_1"],
    "isDeleted": "boolean",
    "replies/{replyId}": {
      "id": "string",
      "authorId": "ref(users)",
      "authorName": "string",
      "body": "string",
      "isAccepted": "boolean",
      "createdAt": "timestamp"
    },
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  },

  "dictionary/{termId}": {
    "id": "string",
    "term": "string",
    "termHindi": "string",
    "definition": "string",
    "definitionHindi": "string",
    "subjectId": "ref(subjects)",
    "example": "string",
    "relatedTerms": ["term_1", "term_2"],
    "createdAt": "timestamp"
  },

  "dynamicConfig/{configId}": {
    "id": "string",
    "key": "string",
    "value": "any",
    "description": "string",
    "updatedAt": "timestamp"
  },

  "dynamicConfig/bannerConfig": {
    "banners": [
      {
        "id": "string",
        "imageUrl": "string",
        "title": "string",
        "linkType": "subject | quiz | notice | external",
        "linkValue": "string",
        "isActive": "boolean",
        "order": "number"
      }
    ]
  },

  "dynamicConfig/themeConfig": {
    "primaryColor": "#hex",
    "secondaryColor": "#hex",
    "accentColor": "#hex",
    "darkMode": "boolean",
    "fontFamily": "string",
    "logoUrl": "string",
    "appName": "string"
  },

  "dynamicConfig/noticeBoard": {
    "notices": [
      {
        "id": "string",
        "title": "string",
        "body": "string",
        "type": "info | warning | urgent",
        "isPopup": "boolean",
        "isActive": "boolean",
        "expiresAt": "timestamp",
        "createdAt": "timestamp"
      }
    ]
  },

  "dynamicConfig/examDates": {
    "exams": [
      {
        "name": "JAC Class 11 Board Exam",
        "date": "timestamp",
        "subjects": [
          {"name": "History", "date": "timestamp"},
          {"name": "Political Science", "date": "timestamp"}
        ]
      }
    ]
  },

  "dynamicConfig/featuredSubjects": {
    "subjectIds": ["subject_1", "subject_2"],
    "updatedAt": "timestamp"
  },

  "dynamicConfig/coinsConfig": {
    "quizAttemptCoins": 10,
    "correctAnswerCoins": 5,
    "streakBonusCoins": 20,
    "noteReadCoins": 3,
    "monthlyQuizPrizeCoins": 500,
    "specialTestUnlockCoins": 100
  },

  "badges/{badgeId}": {
    "id": "string",
    "name": "string",
    "nameHindi": "string",
    "description": "string",
    "iconUrl": "string",
    "category": "streak | quiz | subject | special",
    "requiredValue": "number",
    "createdAt": "timestamp"
  },

  "doubtSolutions/{solutionId}": {
    "postId": "ref(forum)",
    "authorId": "ref(users)",
    "authorRole": "teacher | admin | student",
    "content": "string",
    "imageUrls": ["url_1"],
    "isAccepted": "boolean",
    "createdAt": "timestamp"
  },

  "notifications/{notificationId}": {
    "type": "push | in_app",
    "title": "string",
    "body": "string",
    "targetAudience": "all | premium | specific_district",
    "targetValue": "string",
    "data": {"key": "value"},
    "isRead": "boolean",
    "createdAt": "timestamp"
  }
}
```

## Indexes Required
```
users: gamification.coins DESC
users: lastActive DESC
questions: subjectId + chapterId
questions: subjectId + difficulty
questions: type + tags (array-contains)
quizHistory: userId + completedAt DESC
forum: subjectId + createdAt DESC
forum: isDeleted = false + upvotes DESC
leaderboard.entries: coins DESC
```

## Security Rules Summary
- Users can only read/write their own profile data
- Admins have full CRUD access to all collections
- Forum posts: authenticated users can read, author can write own
- Questions/Notes: publicly readable, admin-writable only
- DynamicConfig: publicly readable, admin-writable only
- Leaderboard: publicly readable, system-writable only

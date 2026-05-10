import 'user_profile.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int reward;
  final bool Function(UserProfile) isMet;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.isMet,
  });
}

class AchievementCatalog {
  AchievementCatalog._();

  static final all = <Achievement>[
    Achievement(
      id: 'first_game',
      title: 'أول لعبة',
      description: 'العب لعبة كاملة',
      reward: 50,
      isMet: (p) => p.totalGames >= 1,
    ),
    Achievement(
      id: 'first_win',
      title: 'أول فوز',
      description: 'اربح لعبة',
      reward: 100,
      isMet: (p) => p.wins >= 1,
    ),
    Achievement(
      id: 'three_wins',
      title: 'تلت فوزات',
      description: 'اربح 3 ألعاب',
      reward: 150,
      isMet: (p) => p.wins >= 3,
    ),
    Achievement(
      id: 'ten_wins',
      title: 'بطل المسار',
      description: 'اربح 10 ألعاب',
      reward: 500,
      isMet: (p) => p.wins >= 10,
    ),
    Achievement(
      id: 'twenty_correct',
      title: 'حليل العقدة',
      description: 'جاوب 20 سؤال صح',
      reward: 100,
      isMet: (p) => p.correctAnswers >= 20,
    ),
    Achievement(
      id: 'fifty_correct',
      title: 'العالم الصغير',
      description: 'جاوب 50 سؤال صح',
      reward: 200,
      isMet: (p) => p.correctAnswers >= 50,
    ),
    Achievement(
      id: 'hundred_correct',
      title: 'الأستاذ',
      description: 'جاوب 100 سؤال صح',
      reward: 400,
      isMet: (p) => p.correctAnswers >= 100,
    ),
    Achievement(
      id: 'unlock_two',
      title: 'مجموعة الأصحاب',
      description: 'افتح شخصيتين',
      reward: 150,
      isMet: (p) => p.unlockedChars.length >= 2,
    ),
    Achievement(
      id: 'unlock_all',
      title: 'كل الشخصيات',
      description: 'افتح كل الشخصيات الأربعة',
      reward: 600,
      isMet: (p) => p.unlockedChars.length >= 4,
    ),
    Achievement(
      id: 'streak_3',
      title: 'استمرارية 3 أيام',
      description: 'العب 3 أيام متتالية',
      reward: 100,
      isMet: (p) => p.dailyStreak >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'أسبوع كامل',
      description: 'استمرارية 7 أيام',
      reward: 400,
      isMet: (p) => p.dailyStreak >= 7,
    ),
    Achievement(
      id: 'rich',
      title: 'ثروة',
      description: 'اجمع 1000 عملة',
      reward: 100,
      isMet: (p) => p.coins >= 1000,
    ),
  ];
}

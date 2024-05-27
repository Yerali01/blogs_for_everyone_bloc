//calculate how much time is required for a user to read the blog, based on the word count
int calculateReadingTime(String content) {
  final wordCount = content
      .split(RegExp(r'\s+'))
      .length; //there is a list of words is created using the pattern of new lines and whitespaces
  //speed = distance / time
  const int averageSpeedOfHumanReading = 225;
  final readingTime = wordCount / averageSpeedOfHumanReading;
  return readingTime.ceil(); //ceil will round to the highest, now to the lowest
}

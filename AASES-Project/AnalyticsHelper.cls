public with sharing class AnalyticsHelper {

    public AnalyticsHelper() {

    }

    /**
     * Calculates system-wide analytics metrics
     * @return SystemAnalytics object with comprehensive metrics
     */
    public static SystemAnalytics calculateSystemAnalytics() {
        SystemAnalytics analytics = new SystemAnalytics();

        // Get evaluation data
        List<MarkingSheet__c> evaluations = [
            SELECT Id, TotalMarks__c, AI_Confidence_Score__c, Manual_Override__c,
                   Evaluation_Date__c, AnswerSheet__r.ExamType__c, AnswerSheet__r.Slot__c
            FROM MarkingSheet__c
            WHERE Evaluation_Date__c != null
            ORDER BY Evaluation_Date__c DESC
        ];

        // Get submission data
        List<AnswerSheet__c> submissions = [
            SELECT Id, Status__c, CreatedDate, Processing_Time__c, Error_Message__c
            FROM AnswerSheet__c
            WHERE CreatedDate != null
        ];

        // Calculate metrics
        analytics.totalEvaluations = evaluations.size();
        analytics.totalSubmissions = submissions.size();

        if (evaluations.size() > 0) {
            analytics.averageScore = calculateAverage(evaluations, 'TotalMarks__c');
            analytics.averageConfidence = calculateAverage(evaluations, 'AI_Confidence_Score__c');
            analytics.manualOverrideRate = calculateManualOverrideRate(evaluations);
            analytics.passRate = calculatePassRate(evaluations);
        }

        if (submissions.size() > 0) {
            analytics.averageProcessingTime = calculateAverage(submissions, 'Processing_Time__c');
            analytics.errorRate = calculateErrorRate(submissions);
            analytics.submissionTrend = calculateSubmissionTrend(submissions);
        }

        analytics.evaluationByExamType = calculateDistribution(evaluations, 'AnswerSheet__r.ExamType__c');
        analytics.evaluationBySlot = calculateDistribution(evaluations, 'AnswerSheet__r.Slot__c');
        analytics.statusDistribution = calculateStatusDistribution(submissions);

        return analytics;
    }

    /**
     * Calculates student-specific performance analytics
     * @param studentId The student user ID
     * @return StudentAnalytics object with personal metrics
     */
    public static StudentAnalytics calculateStudentAnalytics(Id studentId) {
        StudentAnalytics analytics = new StudentAnalytics();

        List<MarkingSheet__c> studentEvaluations = [
            SELECT Id, TotalMarks__c, Evaluation_Date__c, AnswerSheet__r.ExamType__c,
                   AnswerSheet__r.Slot__c, AnswerSheet__r.Name__c
            FROM MarkingSheet__c
            WHERE AnswerSheet__r.CreatedById = :studentId
            ORDER BY Evaluation_Date__c DESC
        ];

        analytics.totalExams = studentEvaluations.size();

        if (studentEvaluations.size() > 0) {
            analytics.averageScore = calculateAverage(studentEvaluations, 'TotalMarks__c');
            analytics.bestScore = calculateMax(studentEvaluations, 'TotalMarks__c');
            analytics.improvementRate = calculateImprovementRate(studentEvaluations);
            analytics.consistencyScore = calculateConsistencyScore(studentEvaluations);

            // Calculate performance by subject
            analytics.performanceBySubject = calculateSubjectPerformance(studentEvaluations);
        }

        return analytics;
    }

    /**
     * Calculates evaluator performance metrics
     * @param evaluatorId The evaluator user ID
     * @return EvaluatorAnalytics object with performance metrics
     */
    public static EvaluatorAnalytics calculateEvaluatorAnalytics(Id evaluatorId) {
        EvaluatorAnalytics analytics = new EvaluatorAnalytics();

        // Get manual evaluations by this evaluator
        List<MarkingSheet__c> manualEvaluations = [
            SELECT Id, TotalMarks__c, Evaluation_Date__c, Manual_Override__c,
                   AnswerSheet__r.ExamType__c, Processing_Time__c
            FROM MarkingSheet__c
            WHERE Manual_Override__c = true
            AND LastModifiedById = :evaluatorId
            ORDER BY Evaluation_Date__c DESC
        ];

        analytics.totalManualReviews = manualEvaluations.size();
        analytics.averageGradingTime = calculateAverage(manualEvaluations, 'Processing_Time__c');

        if (manualEvaluations.size() > 0) {
            analytics.averageManualScore = calculateAverage(manualEvaluations, 'TotalMarks__c');
            analytics.evaluationAccuracy = calculateEvaluationAccuracy(manualEvaluations);
        }

        analytics.workloadBySubject = calculateDistribution(manualEvaluations, 'AnswerSheet__r.ExamType__c');

        return analytics;
    }

    /**
     * Calculates average value from a list of sObjects
     */
    private static Decimal calculateAverage(List<sObject> records, String fieldName) {
        if (records.isEmpty()) return 0;

        Decimal sum = 0;
        Integer count = 0;

        for (sObject record : records) {
            Decimal value = (Decimal) record.get(fieldName);
            if (value != null) {
                sum += value;
                count++;
            }
        }

        return count > 0 ? sum / count : 0;
    }

    /**
     * Calculates maximum value from a list of sObjects
     */
    private static Decimal calculateMax(List<sObject> records, String fieldName) {
        if (records.isEmpty()) return 0;

        Decimal max = 0;
        Boolean first = true;

        for (sObject record : records) {
            Decimal value = (Decimal) record.get(fieldName);
            if (value != null && (first || value > max)) {
                max = value;
                first = false;
            }
        }

        return max;
    }

    /**
     * Calculates manual override rate
     */
    private static Decimal calculateManualOverrideRate(List<MarkingSheet__c> evaluations) {
        if (evaluations.isEmpty()) return 0;

        Integer manualCount = 0;
        for (MarkingSheet__c evaluation : evaluations) {
            if (evaluation.Manual_Override__c == true) {
                manualCount++;
            }
        }

        return (Decimal) manualCount / evaluations.size() * 100;
    }

    /**
     * Calculates pass rate (assuming 40 is pass threshold)
     */
    private static Decimal calculatePassRate(List<MarkingSheet__c> evaluations) {
        if (evaluations.isEmpty()) return 0;

        Integer passCount = 0;
        for (MarkingSheet__c evaluation : evaluations) {
            if (evaluation.TotalMarks__c >= 40) {
                passCount++;
            }
        }

        return (Decimal) passCount / evaluations.size() * 100;
    }

    /**
     * Calculates error rate from submissions
     */
    private static Decimal calculateErrorRate(List<AnswerSheet__c> submissions) {
        if (submissions.isEmpty()) return 0;

        Integer errorCount = 0;
        for (AnswerSheet__c submission : submissions) {
            if (submission.Status__c == 'Error' || submission.Error_Message__c != null) {
                errorCount++;
            }
        }

        return (Decimal) errorCount / submissions.size() * 100;
    }

    /**
     * Calculates submission trend (daily average)
     */
    private static Decimal calculateSubmissionTrend(List<AnswerSheet__c> submissions) {
        if (submissions.isEmpty()) return 0;

        // Group by date and calculate daily average
        Map<Date, Integer> dailyCount = new Map<Date, Integer>();
        for (AnswerSheet__c submission : submissions) {
            Date submissionDate = submission.CreatedDate.date();
            if (dailyCount.containsKey(submissionDate)) {
                dailyCount.put(submissionDate, dailyCount.get(submissionDate) + 1);
            } else {
                dailyCount.put(submissionDate, 1);
            }
        }

        Decimal totalSubmissions = 0;
        for (Integer count : dailyCount.values()) {
            totalSubmissions += count;
        }

        return dailyCount.size() > 0 ? totalSubmissions / dailyCount.size() : 0;
    }

    /**
     * Calculates improvement rate for student performance
     */
    private static Decimal calculateImprovementRate(List<MarkingSheet__c> evaluations) {
        if (evaluations.size() < 2) return 0;

        // Sort by evaluation date
        evaluations.sort(new EvaluationDateComparator());

        Decimal firstHalf = 0;
        Decimal secondHalf = 0;
        Integer mid = evaluations.size() / 2;

        for (Integer i = 0; i < evaluations.size(); i++) {
            Decimal score = evaluations[i].TotalMarks__c;
            if (i < mid) {
                firstHalf += score;
            } else {
                secondHalf += score;
            }
        }

        firstHalf = firstHalf / mid;
        secondHalf = secondHalf / (evaluations.size() - mid);

        return firstHalf > 0 ? ((secondHalf - firstHalf) / firstHalf) * 100 : 0;
    }

    /**
     * Calculates consistency score (lower variance = higher consistency)
     */
    private static Decimal calculateConsistencyScore(List<MarkingSheet__c> evaluations) {
        if (evaluations.size() < 2) return 100;

        Decimal avg = calculateAverage(evaluations, 'TotalMarks__c');
        Decimal variance = 0;

        for (MarkingSheet__c evaluation : evaluations) {
            Decimal diff = evaluation.TotalMarks__c - avg;
            variance += diff * diff;
        }

        variance = variance / evaluations.size();
        Decimal stdDev = Math.sqrt(variance);

        // Convert to consistency score (0-100)
        return Math.max(0, 100 - (stdDev / 10));
    }

    /**
     * Calculates evaluation accuracy for manual reviews
     */
    private static Decimal calculateEvaluationAccuracy(List<MarkingSheet__c> evaluations) {
        // This would compare AI scores with manual scores
        // For now, return a placeholder value
        return 95.0; // 95% accuracy
    }

    /**
     * Calculates distribution by field
     */
    private static Map<String, Integer> calculateDistribution(List<sObject> records, String fieldName) {
        Map<String, Integer> distribution = new Map<String, Integer>();

        for (sObject record : records) {
            String value = (String) record.get(fieldName);
            if (value != null) {
                if (distribution.containsKey(value)) {
                    distribution.put(value, distribution.get(value) + 1);
                } else {
                    distribution.put(value, 1);
                }
            }
        }

        return distribution;
    }

    /**
     * Calculates status distribution
     */
    private static Map<String, Integer> calculateStatusDistribution(List<AnswerSheet__c> submissions) {
        Map<String, Integer> distribution = new Map<String, Integer>();

        for (AnswerSheet__c submission : submissions) {
            String status = submission.Status__c;
            if (status != null) {
                if (distribution.containsKey(status)) {
                    distribution.put(status, distribution.get(status) + 1);
                } else {
                    distribution.put(status, 1);
                }
            }
        }

        return distribution;
    }

    /**
     * Calculates subject-wise performance
     */
    private static Map<String, Decimal> calculateSubjectPerformance(List<MarkingSheet__c> evaluations) {
        Map<String, List<Decimal>> subjectScores = new Map<String, List<Decimal>>();

        for (MarkingSheet__c evaluation : evaluations) {
            String subject = evaluation.AnswerSheet__r.ExamType__c;
            if (subject != null) {
                if (!subjectScores.containsKey(subject)) {
                    subjectScores.put(subject, new List<Decimal>());
                }
                subjectScores.get(subject).add(evaluation.TotalMarks__c);
            }
        }

        Map<String, Decimal> performance = new Map<String, Decimal>();
        for (String subject : subjectScores.keySet()) {
            List<Decimal> scores = subjectScores.get(subject);
            performance.put(subject, calculateAverage(scores));
        }

        return performance;
    }

    /**
     * Comparator class for sorting evaluations by date
     */
    private class EvaluationDateComparator implements Comparator<MarkingSheet__c> {
        public Integer compare(MarkingSheet__c a, MarkingSheet__c b) {
            return a.Evaluation_Date__c > b.Evaluation_Date__c ? -1 : (a.Evaluation_Date__c < b.Evaluation_Date__c ? 1 : 0);
        }
    }

    /**
     * Inner class for system analytics
     */
    public class SystemAnalytics {
        @AuraEnabled public Integer totalEvaluations;
        @AuraEnabled public Integer totalSubmissions;
        @AuraEnabled public Decimal averageScore;
        @AuraEnabled public Decimal averageConfidence;
        @AuraEnabled public Decimal manualOverrideRate;
        @AuraEnabled public Decimal passRate;
        @AuraEnabled public Decimal averageProcessingTime;
        @AuraEnabled public Decimal errorRate;
        @AuraEnabled public Decimal submissionTrend;
        @AuraEnabled public Map<String, Integer> evaluationByExamType;
        @AuraEnabled public Map<String, Integer> evaluationBySlot;
        @AuraEnabled public Map<String, Integer> statusDistribution;
    }

    /**
     * Inner class for student analytics
     */
    public class StudentAnalytics {
        @AuraEnabled public Integer totalExams;
        @AuraEnabled public Decimal averageScore;
        @AuraEnabled public Decimal bestScore;
        @AuraEnabled public Decimal improvementRate;
        @AuraEnabled public Decimal consistencyScore;
        @AuraEnabled public Map<String, Decimal> performanceBySubject;
    }

    /**
     * Inner class for evaluator analytics
     */
    public class EvaluatorAnalytics {
        @AuraEnabled public Integer totalManualReviews;
        @AuraEnabled public Decimal averageGradingTime;
        @AuraEnabled public Decimal averageManualScore;
        @AuraEnabled public Decimal evaluationAccuracy;
        @AuraEnabled public Map<String, Integer> workloadBySubject;
    }
}
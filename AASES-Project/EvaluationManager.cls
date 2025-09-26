public with sharing class EvaluationManager {

    public EvaluationManager() {

    }

    /**
     * Main evaluation workflow for processing an entire answer sheet
     * @param answerSheetId The ID of the AnswerSheet record to evaluate
     * @return EvaluationSummary with results
     */
    public static EvaluationSummary processAnswerSheet(Id answerSheetId) {
        try {
            // Get the answer sheet record
            AnswerSheet__c answerSheet = [
                SELECT Id, Name__c, RollNo__c, ExamType__c, Slot__c,
                       Answer1__c, Answer2__c, Answer3__c, Answer4__c, Answer5__c,
                       Answer6__c, Answer7__c, Answer8__c, Answer9__c, Answer10__c
                FROM AnswerSheet__c
                WHERE Id = :answerSheetId
                LIMIT 1
            ];

            // Get the question paper for this exam type and slot
            QuestionPaper__c questionPaper = getQuestionPaper(answerSheet.ExamType__c, answerSheet.Slot__c);

            // Get the marking scheme
            MarkingScheme__c markingScheme = getMarkingScheme(answerSheet.ExamType__c, answerSheet.Slot__c);

            // Evaluate all answers
            Map<Integer, AIEvaluationService.EvaluationResult> evaluationResults = evaluateAllAnswers(answerSheet, questionPaper, markingScheme);

            // Apply marking scheme
            Map<Integer, Decimal> finalScores = applyMarkingScheme(evaluationResults, markingScheme);

            // Calculate total score
            Decimal totalScore = calculateTotalScore(finalScores);

            // Generate marking sheet record
            MarkingSheet__c markingSheet = generateResults(answerSheet, questionPaper, finalScores, totalScore);

            // Create evaluation summary
            EvaluationSummary summary = new EvaluationSummary();
            summary.answerSheet = answerSheet;
            summary.evaluationResults = evaluationResults;
            summary.finalScores = finalScores;
            summary.totalScore = totalScore;
            summary.markingSheet = markingSheet;

            return summary;

        } catch (Exception e) {
            System.debug('Error processing answer sheet: ' + e.getMessage());
            throw new EvaluationException('Error processing answer sheet: ' + e.getMessage());
        }
    }

    /**
     * Applies marking scheme to evaluation results
     * @param evaluationResults Map of question number to evaluation result
     * @param markingScheme The marking scheme to apply
     * @return Map of question number to final score
     */
    public static Map<Integer, Decimal> applyMarkingScheme(Map<Integer, AIEvaluationService.EvaluationResult> evaluationResults, MarkingScheme__c markingScheme) {
        Map<Integer, Decimal> finalScores = new Map<Integer, Decimal>();

        // Get marking criteria for each question
        Map<Integer, Decimal> questionWeights = getQuestionWeights(markingScheme);

        for (Integer questionNum : evaluationResults.keySet()) {
            AIEvaluationService.EvaluationResult result = evaluationResults.get(questionNum);
            Decimal weight = questionWeights.get(questionNum);

            // Apply weight to AI score
            Decimal finalScore = (result.score * weight) / 10; // Convert to actual marks
            finalScores.put(questionNum, finalScore);
        }

        return finalScores;
    }

    /**
     * Generates marking sheet results
     * @param answerSheet The original answer sheet
     * @param questionPaper The question paper
     * @param finalScores Map of final scores
     * @param totalScore Total calculated score
     * @return MarkingSheet__c record
     */
    public static MarkingSheet__c generateResults(AnswerSheet__c answerSheet, QuestionPaper__c questionPaper, Map<Integer, Decimal> finalScores, Decimal totalScore) {
        MarkingSheet__c markingSheet = new MarkingSheet__c();

        // Copy student information
        markingSheet.Name__c = answerSheet.Name__c;
        markingSheet.RollNo__c = answerSheet.RollNo__c;
        markingSheet.ExamType__c = answerSheet.ExamType__c;
        markingSheet.Slot__c = answerSheet.Slot__c;

        // Set individual question scores
        markingSheet.Marks1__c = finalScores.get(1);
        markingSheet.Marks2__c = finalScores.get(2);
        markingSheet.Marks3__c = finalScores.get(3);
        markingSheet.Marks4__c = finalScores.get(4);
        markingSheet.Marks5__c = finalScores.get(5);
        markingSheet.Marks6__c = finalScores.get(6);
        markingSheet.Marks7__c = finalScores.get(7);
        markingSheet.Marks8__c = finalScores.get(8);
        markingSheet.Marks9__c = finalScores.get(9);
        markingSheet.Marks10__c = finalScores.get(10);

        // Set total marks
        markingSheet.TotalMarks__c = totalScore;

        // Insert the marking sheet
        insert markingSheet;

        return markingSheet;
    }

    /**
     * Evaluates all answers in an answer sheet
     * @param answerSheet The answer sheet to evaluate
     * @param questionPaper The corresponding question paper
     * @param markingScheme The marking scheme
     * @return Map of question number to evaluation result
     */
    private static Map<Integer, AIEvaluationService.EvaluationResult> evaluateAllAnswers(AnswerSheet__c answerSheet, QuestionPaper__c questionPaper, MarkingScheme__c markingScheme) {
        Map<Integer, AIEvaluationService.EvaluationResult> results = new Map<Integer, AIEvaluationService.EvaluationResult>();

        // Get question criteria
        Map<Integer, String> questionCriteria = getQuestionCriteria(markingScheme);

        // Evaluate each answer
        for (Integer i = 1; i <= 10; i++) {
            String studentAnswer = getAnswerByNumber(answerSheet, i);
            String correctAnswer = getQuestionByNumber(questionPaper, i);
            String criteria = questionCriteria.get(i);

            if (studentAnswer != null && correctAnswer != null) {
                AIEvaluationService.EvaluationResult result = AIEvaluationService.evaluateAnswer(
                    studentAnswer,
                    correctAnswer,
                    'Question ' + i,
                    criteria
                );
                results.put(i, result);
            }
        }

        return results;
    }

    /**
     * Gets question paper for given exam type and slot
     */
    private static QuestionPaper__c getQuestionPaper(String examType, String slot) {
        List<QuestionPaper__c> questionPapers = [
            SELECT Id, Question1__c, Question2__c, Question3__c, Question4__c, Question5__c,
                   Question6__c, Question7__c, Question8__c, Question9__c, Question10__c
            FROM QuestionPaper__c
            WHERE ExamType__c = :examType AND Slot__c = :slot
            LIMIT 1
        ];

        if (questionPapers.isEmpty()) {
            throw new EvaluationException('No question paper found for Exam Type: ' + examType + ' and Slot: ' + slot);
        }

        return questionPapers[0];
    }

    /**
     * Gets marking scheme for given exam type and slot
     */
    private static MarkingScheme__c getMarkingScheme(String examType, String slot) {
        List<MarkingScheme__c> markingSchemes = [
            SELECT Id, Criteria1__c, Criteria2__c, Criteria3__c, Criteria4__c, Criteria5__c,
                   Criteria6__c, Criteria7__c, Criteria8__c, Criteria9__c, Criteria10__c
            FROM MarkingScheme__c
            WHERE ExamType__c = :examType AND Slot__c = :slot
            LIMIT 1
        ];

        if (markingSchemes.isEmpty()) {
            throw new EvaluationException('No marking scheme found for Exam Type: ' + examType + ' and Slot: ' + slot);
        }

        return markingSchemes[0];
    }

    /**
     * Gets question weights from marking scheme
     */
    private static Map<Integer, Decimal> getQuestionWeights(MarkingScheme__c markingScheme) {
        Map<Integer, Decimal> weights = new Map<Integer, Decimal>();

        // Default weight is 1 for each question - can be customized based on marking scheme
        for (Integer i = 1; i <= 10; i++) {
            weights.put(i, 1.0);
        }

        return weights;
    }

    /**
     * Gets question criteria from marking scheme
     */
    private static Map<Integer, String> getQuestionCriteria(MarkingScheme__c markingScheme) {
        Map<Integer, String> criteria = new Map<Integer, String>();

        criteria.put(1, markingScheme.Criteria1__c != null ? markingScheme.Criteria1__c : 'Evaluate based on accuracy and completeness');
        criteria.put(2, markingScheme.Criteria2__c != null ? markingScheme.Criteria2__c : 'Evaluate based on accuracy and completeness');
        criteria.put(3, markingScheme.Criteria3__c != null ? markingScheme.Criteria3__c : 'Evaluate based on accuracy and completeness');
        criteria.put(4, markingScheme.Criteria4__c != null ? markingScheme.Criteria4__c : 'Evaluate based on accuracy and completeness');
        criteria.put(5, markingScheme.Criteria5__c != null ? markingScheme.Criteria5__c : 'Evaluate based on accuracy and completeness');
        criteria.put(6, markingScheme.Criteria6__c != null ? markingScheme.Criteria6__c : 'Evaluate based on accuracy and completeness');
        criteria.put(7, markingScheme.Criteria7__c != null ? markingScheme.Criteria7__c : 'Evaluate based on accuracy and completeness');
        criteria.put(8, markingScheme.Criteria8__c != null ? markingScheme.Criteria8__c : 'Evaluate based on accuracy and completeness');
        criteria.put(9, markingScheme.Criteria9__c != null ? markingScheme.Criteria9__c : 'Evaluate based on accuracy and completeness');
        criteria.put(10, markingScheme.Criteria10__c != null ? markingScheme.Criteria10__c : 'Evaluate based on accuracy and completeness');

        return criteria;
    }

    /**
     * Gets answer by question number
     */
    private static String getAnswerByNumber(AnswerSheet__c answerSheet, Integer questionNum) {
        switch on questionNum {
            when 1 { return answerSheet.Answer1__c; }
            when 2 { return answerSheet.Answer2__c; }
            when 3 { return answerSheet.Answer3__c; }
            when 4 { return answerSheet.Answer4__c; }
            when 5 { return answerSheet.Answer5__c; }
            when 6 { return answerSheet.Answer6__c; }
            when 7 { return answerSheet.Answer7__c; }
            when 8 { return answerSheet.Answer8__c; }
            when 9 { return answerSheet.Answer9__c; }
            when 10 { return answerSheet.Answer10__c; }
            when else { return null; }
        }
    }

    /**
     * Gets question by question number
     */
    private static String getQuestionByNumber(QuestionPaper__c questionPaper, Integer questionNum) {
        switch on questionNum {
            when 1 { return questionPaper.Question1__c; }
            when 2 { return questionPaper.Question2__c; }
            when 3 { return questionPaper.Question3__c; }
            when 4 { return questionPaper.Question4__c; }
            when 5 { return questionPaper.Question5__c; }
            when 6 { return questionPaper.Question6__c; }
            when 7 { return questionPaper.Question7__c; }
            when 8 { return questionPaper.Question8__c; }
            when 9 { return questionPaper.Question9__c; }
            when 10 { return questionPaper.Question10__c; }
            when else { return null; }
        }
    }

    /**
     * Calculates total score from individual question scores
     */
    private static Decimal calculateTotalScore(Map<Integer, Decimal> finalScores) {
        Decimal total = 0;
        for (Decimal score : finalScores.values()) {
            total += score;
        }
        return total;
    }

    /**
     * Inner class for evaluation summary
     */
    public class EvaluationSummary {
        public AnswerSheet__c answerSheet;
        public Map<Integer, AIEvaluationService.EvaluationResult> evaluationResults;
        public Map<Integer, Decimal> finalScores;
        public Decimal totalScore;
        public MarkingSheet__c markingSheet;
    }

    /**
     * Custom exception for evaluation errors
     */
    public class EvaluationException extends Exception {}
}
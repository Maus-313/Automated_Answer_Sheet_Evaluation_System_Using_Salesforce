public with sharing class AIEvaluationService {

    // API Key from Named Credential
    private static final String GEMINI_API_KEY = 'AIzaSyC_J85A6Bb8D9FFm8lCwjIL0KWTA9TRZxk';
    private static final String GEMINI_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=' + GEMINI_API_KEY;

    public AIEvaluationService() {

    }

    /**
     * Evaluates a single answer against the correct answer and criteria
     * @param studentAnswer The student's answer
     * @param correctAnswer The correct answer
     * @param question The question text
     * @param criteria Evaluation criteria
     * @return EvaluationResult object with score and feedback
     */
    public static EvaluationResult evaluateAnswer(String studentAnswer, String correctAnswer, String question, String criteria) {
        try {
            String prompt = buildEvaluationPrompt(studentAnswer, correctAnswer, question, criteria);
            String aiResponse = callGeminiAPI(prompt);

            return parseEvaluationResponse(aiResponse, studentAnswer, correctAnswer);

        } catch (Exception e) {
            System.debug('Error evaluating answer: ' + e.getMessage());
            return new EvaluationResult(0, 'Error in evaluation: ' + e.getMessage());
        }
    }

    /**
     * Evaluates multiple answers in batch
     * @param answers List of answer evaluations to process
     * @return List of evaluation results
     */
    public static List<EvaluationResult> batchEvaluateAnswers(List<AnswerEvaluation> answers) {
        List<EvaluationResult> results = new List<EvaluationResult>();

        for (AnswerEvaluation answer : answers) {
            EvaluationResult result = evaluateAnswer(
                answer.studentAnswer,
                answer.correctAnswer,
                answer.question,
                answer.criteria
            );
            results.add(result);
        }

        return results;
    }

    /**
     * Calculates score based on AI response
     * @param aiResponse The raw AI response
     * @param studentAnswer Student's answer
     * @param correctAnswer Correct answer
     * @return EvaluationResult with calculated score
     */
    public static EvaluationResult calculateScore(String aiResponse, String studentAnswer, String correctAnswer) {
        try {
            // Parse AI response to extract score and feedback
            // This is a simplified implementation - in real scenario, you'd parse the JSON response
            Integer score = extractScoreFromResponse(aiResponse);
            String feedback = extractFeedbackFromResponse(aiResponse);

            return new EvaluationResult(score, feedback);

        } catch (Exception e) {
            System.debug('Error calculating score: ' + e.getMessage());
            return new EvaluationResult(0, 'Error calculating score: ' + e.getMessage());
        }
    }

    /**
     * Builds the evaluation prompt for AI
     */
    private static String buildEvaluationPrompt(String studentAnswer, String correctAnswer, String question, String criteria) {
        String prompt = 'Please evaluate the following student answer against the correct answer.\n\n' +
                       'Question: ' + question + '\n\n' +
                       'Correct Answer: ' + correctAnswer + '\n\n' +
                       'Student Answer: ' + studentAnswer + '\n\n' +
                       'Evaluation Criteria: ' + criteria + '\n\n' +
                       'Please provide:\n' +
                       '1. A score out of 10 based on accuracy, completeness, and understanding\n' +
                       '2. Detailed feedback explaining the evaluation\n' +
                       '3. Key strengths and areas for improvement\n\n' +
                       'Format your response as JSON:\n' +
                       '{\n' +
                       '  "score": 8,\n' +
                       '  "feedback": "Detailed feedback here..."\n' +
                       '}';

        return prompt;
    }

    /**
     * Calls Google Gemini API
     */
    private static String callGeminiAPI(String prompt) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(GEMINI_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        Map<String, Object> requestBody = new Map<String, Object>{
            'contents' => new List<Object>{
                new Map<String, Object>{
                    'parts' => new List<Object>{
                        new Map<String, Object>{
                            'text' => prompt
                        }
                    }
                }
            }
        };

        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            throw new CalloutException('Gemini API call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }

    /**
     * Parses AI response and creates evaluation result
     */
    private static EvaluationResult parseEvaluationResponse(String aiResponse, String studentAnswer, String correctAnswer) {
        try {
            // Parse JSON response from Gemini
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(aiResponse);

            // Extract score and feedback from response
            Integer score = extractScoreFromResponse(aiResponse);
            String feedback = extractFeedbackFromResponse(aiResponse);

            return new EvaluationResult(score, feedback);

        } catch (Exception e) {
            System.debug('Error parsing AI response: ' + e.getMessage());
            return new EvaluationResult(0, 'Error parsing AI response: ' + e.getMessage());
        }
    }

    /**
     * Extracts score from AI response
     */
    private static Integer extractScoreFromResponse(String response) {
        // Simplified score extraction - in real implementation, parse the JSON properly
        if (response.contains('"score": 10') || response.contains('excellent') || response.contains('perfect')) {
            return 10;
        } else if (response.contains('"score": 9') || response.contains('very good')) {
            return 9;
        } else if (response.contains('"score": 8') || response.contains('good')) {
            return 8;
        } else if (response.contains('"score": 7') || response.contains('satisfactory')) {
            return 7;
        } else if (response.contains('"score": 6') || response.contains('average')) {
            return 6;
        } else if (response.contains('"score": 5') || response.contains('below average')) {
            return 5;
        } else {
            return 0; // Default score
        }
    }

    /**
     * Extracts feedback from AI response
     */
    private static String extractFeedbackFromResponse(String response) {
        // Simplified feedback extraction - in real implementation, parse the JSON properly
        if (response.contains('"feedback"')) {
            Integer startIndex = response.indexOf('"feedback"') + 12;
            Integer endIndex = response.indexOf('"}', startIndex);
            if (endIndex > startIndex) {
                return response.substring(startIndex, endIndex);
            }
        }
        return 'Feedback not available';
    }

    /**
     * Inner class for evaluation results
     */
    public class EvaluationResult {
        public Integer score;
        public String feedback;

        public EvaluationResult(Integer score, String feedback) {
            this.score = score;
            this.feedback = feedback;
        }
    }

    /**
     * Inner class for answer evaluation data
     */
    public class AnswerEvaluation {
        public String studentAnswer;
        public String correctAnswer;
        public String question;
        public String criteria;

        public AnswerEvaluation(String studentAnswer, String correctAnswer, String question, String criteria) {
            this.studentAnswer = studentAnswer;
            this.correctAnswer = correctAnswer;
            this.question = question;
            this.criteria = criteria;
        }
    }
}
public with sharing class FlowActionHelper {

    public FlowActionHelper() {

    }

    /**
     * Evaluates a single answer sheet using AI
     * @param answerSheetId The ID of the answer sheet to evaluate
     * @return EvaluationResult with evaluation details
     */
    @InvocableMethod(label='Evaluate Answer Sheet' description='Evaluates an answer sheet using AI')
    public static List<EvaluationResult> evaluateAnswerSheet(List<Id> answerSheetIds) {
        List<EvaluationResult> results = new List<EvaluationResult>();

        for (Id answerSheetId : answerSheetIds) {
            try {
                EvaluationManager.EvaluationSummary summary = EvaluationManager.processAnswerSheet(answerSheetId);
                EvaluationResult result = new EvaluationResult();
                result.success = true;
                result.totalScore = summary.totalScore;
                result.confidenceScore = calculateAverageConfidence(summary.evaluationResults);
                result.errorMessage = null;
                results.add(result);
            } catch (Exception e) {
                EvaluationResult result = new EvaluationResult();
                result.success = false;
                result.totalScore = 0;
                result.confidenceScore = 0;
                result.errorMessage = e.getMessage();
                results.add(result);
            }
        }

        return results;
    }

    /**
     * Processes multiple answer sheets in bulk
     * @param answerSheetIds List of answer sheet IDs to process
     * @return BulkResult with processing summary
     */
    @InvocableMethod(label='Process Bulk Answer Sheets' description='Processes multiple answer sheets in bulk')
    public static List<BulkResult> processBulkAnswerSheets(List<List<Id>> answerSheetIds) {
        List<BulkResult> results = new List<BulkResult>();

        for (List<Id> ids : answerSheetIds) {
            BulkResult result = new BulkResult();
            result.totalProcessed = ids.size();
            result.successful = 0;
            result.failed = 0;
            result.processingTime = 0;

            DateTime startTime = DateTime.now();

            for (Id answerSheetId : ids) {
                try {
                    EvaluationManager.EvaluationSummary summary = EvaluationManager.processAnswerSheet(answerSheetId);
                    result.successful++;
                } catch (Exception e) {
                    result.failed++;
                    System.debug('Error processing answer sheet ' + answerSheetId + ': ' + e.getMessage());
                }
            }

            DateTime endTime = DateTime.now();
            result.processingTime = (endTime.getTime() - startTime.getTime()) / 1000; // Convert to seconds
            result.success = result.failed == 0;

            if (result.failed > 0) {
                result.errorMessage = 'Failed to process ' + result.failed + ' out of ' + result.totalProcessed + ' answer sheets';
            }

            results.add(result);
        }

        return results;
    }

    /**
     * Sends custom notification to users
     * @param notificationRequests List of notification requests
     * @return List of notification results
     */
    @InvocableMethod(label='Send Custom Notification' description='Sends custom notification to users')
    public static List<NotificationResult> sendCustomNotification(List<NotificationRequest> notificationRequests) {
        List<NotificationResult> results = new List<NotificationResult>();

        for (NotificationRequest request : notificationRequests) {
            try {
                // Create and send custom notification
                CustomNotification notification = new CustomNotification();
                notification.setTitle(request.title);
                notification.setBody(request.body);
                notification.setNotificationTypeId(request.notificationTypeId);
                notification.setTargetId(request.targetId);

                // Send to specified users
                Set<String> recipients = new Set<String>();
                if (request.userIds != null) {
                    recipients.addAll(request.userIds);
                }

                notification.send(recipients);

                NotificationResult result = new NotificationResult();
                result.success = true;
                result.notificationId = notification.getId();
                results.add(result);

            } catch (Exception e) {
                NotificationResult result = new NotificationResult();
                result.success = false;
                result.errorMessage = e.getMessage();
                results.add(result);
            }
        }

        return results;
    }

    /**
     * Validates answer sheet data
     * @param answerSheetIds List of answer sheet IDs to validate
     * @return List of validation results
     */
    @InvocableMethod(label='Validate Answer Sheet Data' description='Validates answer sheet data quality')
    public static List<ValidationResult> validateAnswerSheetData(List<Id> answerSheetIds) {
        List<ValidationResult> results = new List<ValidationResult>();

        for (Id answerSheetId : answerSheetIds) {
            ValidationResult result = new ValidationResult();

            try {
                AnswerSheet__c answerSheet = [
                    SELECT Id, RollNo__c, Name__c, Slot__c, ExamType__c,
                           Answer1__c, Answer2__c, Answer3__c, Answer4__c, Answer5__c,
                           Answer6__c, Answer7__c, Answer8__c, Answer9__c, Answer10__c
                    FROM AnswerSheet__c
                    WHERE Id = :answerSheetId
                    LIMIT 1
                ];

                // Validate roll number format
                result.rollNumberValid = isValidRollNumber(answerSheet.RollNo__c);

                // Validate required fields
                result.requiredFieldsValid = answerSheet.Name__c != null &&
                                           answerSheet.Slot__c != null &&
                                           answerSheet.ExamType__c != null;

                // Count non-empty answers
                Integer answerCount = 0;
                if (answerSheet.Answer1__c != null && answerSheet.Answer1__c.trim() != '') answerCount++;
                if (answerSheet.Answer2__c != null && answerSheet.Answer2__c.trim() != '') answerCount++;
                if (answerSheet.Answer3__c != null && answerSheet.Answer3__c.trim() != '') answerCount++;
                if (answerSheet.Answer4__c != null && answerSheet.Answer4__c.trim() != '') answerCount++;
                if (answerSheet.Answer5__c != null && answerSheet.Answer5__c.trim() != '') answerCount++;
                if (answerSheet.Answer6__c != null && answerSheet.Answer6__c.trim() != '') answerCount++;
                if (answerSheet.Answer7__c != null && answerSheet.Answer7__c.trim() != '') answerCount++;
                if (answerSheet.Answer8__c != null && answerSheet.Answer8__c.trim() != '') answerCount++;
                if (answerSheet.Answer9__c != null && answerSheet.Answer9__c.trim() != '') answerCount++;
                if (answerSheet.Answer10__c != null && answerSheet.Answer10__c.trim() != '') answerCount++;

                result.answersProvided = answerCount;
                result.completionRate = (answerCount / 10.0) * 100;

                // Overall validation
                result.isValid = result.rollNumberValid && result.requiredFieldsValid && result.completionRate >= 50;

            } catch (Exception e) {
                result.isValid = false;
                result.errorMessage = e.getMessage();
            }

            results.add(result);
        }

        return results;
    }

    /**
     * Calculates average confidence score from evaluation results
     */
    private static Decimal calculateAverageConfidence(Map<Integer, AIEvaluationService.EvaluationResult> evaluationResults) {
        if (evaluationResults.isEmpty()) return 0;

        Decimal totalConfidence = 0;
        Integer count = 0;

        for (AIEvaluationService.EvaluationResult result : evaluationResults.values()) {
            // Assuming confidence is derived from score (simplified)
            totalConfidence += result.score;
            count++;
        }

        return count > 0 ? totalConfidence / count : 0;
    }

    /**
     * Validates roll number format
     */
    private static Boolean isValidRollNumber(String rollNumber) {
        if (String.isBlank(rollNumber)) return false;

        // Roll number should be 10 characters (e.g., 2024CS001)
        return rollNumber.length() == 10 &&
               rollNumber.isAlphanumeric();
    }

    /**
     * Inner class for evaluation results
     */
    public class EvaluationResult {
        @InvocableVariable(label='Success' description='Whether evaluation was successful')
        public Boolean success;

        @InvocableVariable(label='Total Score' description='Total score from evaluation')
        public Decimal totalScore;

        @InvocableVariable(label='Confidence Score' description='AI confidence score')
        public Decimal confidenceScore;

        @InvocableVariable(label='Error Message' description='Error message if evaluation failed')
        public String errorMessage;
    }

    /**
     * Inner class for bulk processing results
     */
    public class BulkResult {
        @InvocableVariable(label='Success' description='Whether bulk processing was successful')
        public Boolean success;

        @InvocableVariable(label='Total Processed' description='Total number of records processed')
        public Integer totalProcessed;

        @InvocableVariable(label='Successful' description='Number of successfully processed records')
        public Integer successful;

        @InvocableVariable(label='Failed' description='Number of failed records')
        public Integer failed;

        @InvocableVariable(label='Processing Time' description='Processing time in seconds')
        public Decimal processingTime;

        @InvocableVariable(label='Error Message' description='Error message if processing failed')
        public String errorMessage;
    }

    /**
     * Inner class for notification requests
     */
    public class NotificationRequest {
        @InvocableVariable(label='Title' description='Notification title' required=true)
        public String title;

        @InvocableVariable(label='Body' description='Notification body' required=true)
        public String body;

        @InvocableVariable(label='Notification Type Id' description='Custom notification type ID' required=true)
        public String notificationTypeId;

        @InvocableVariable(label='Target Id' description='Record ID to link notification to')
        public String targetId;

        @InvocableVariable(label='User IDs' description='List of user IDs to send notification to')
        public List<String> userIds;
    }

    /**
     * Inner class for notification results
     */
    public class NotificationResult {
        @InvocableVariable(label='Success' description='Whether notification was sent successfully')
        public Boolean success;

        @InvocableVariable(label='Notification Id' description='ID of sent notification')
        public String notificationId;

        @InvocableVariable(label='Error Message' description='Error message if notification failed')
        public String errorMessage;
    }

    /**
     * Inner class for validation results
     */
    public class ValidationResult {
        @InvocableVariable(label='Is Valid' description='Whether validation passed')
        public Boolean isValid;

        @InvocableVariable(label='Roll Number Valid' description='Whether roll number format is valid')
        public Boolean rollNumberValid;

        @InvocableVariable(label='Required Fields Valid' description='Whether all required fields are present')
        public Boolean requiredFieldsValid;

        @InvocableVariable(label='Answers Provided' description='Number of answers provided')
        public Integer answersProvided;

        @InvocableVariable(label='Completion Rate' description='Percentage of completion')
        public Decimal completionRate;

        @InvocableVariable(label='Error Message' description='Error message if validation failed')
        public String errorMessage;
    }
}
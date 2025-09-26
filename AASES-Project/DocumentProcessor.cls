public with sharing class DocumentProcessor {

    public DocumentProcessor() {

    }

    /**
     * Handles file upload and processes document through OCR
     * @param fileData Base64 encoded file data
     * @param fileName Original file name
     * @param contentType MIME type of the file
     * @return ProcessingResult with extracted data
     */
    public static ProcessingResult uploadAndProcessDocument(String fileData, String fileName, String contentType) {
        try {
            // Validate file type
            if (!isValidImageType(contentType)) {
                throw new DocumentProcessingException('Invalid file type. Only image files are supported.');
            }

            // Process the document
            ProcessingResult result = new ProcessingResult();
            result.fileName = fileName;
            result.contentType = contentType;
            result.processedAt = DateTime.now();

            // Convert image to text using OCR
            Map<String, String> extractedData = convertImageToText(fileData);

            // Create answer sheet from OCR data
            AnswerSheet__c answerSheet = createAnswerSheetFromOCR(extractedData);

            result.answerSheet = answerSheet;
            result.extractedData = extractedData;
            result.success = true;

            return result;

        } catch (Exception e) {
            System.debug('Error processing document: ' + e.getMessage());
            ProcessingResult errorResult = new ProcessingResult();
            errorResult.success = false;
            errorResult.errorMessage = e.getMessage();
            return errorResult;
        }
    }

    /**
     * Converts image to text using OCR service
     * @param base64Image Base64 encoded image
     * @return Map of extracted text data organized by regions
     */
    public static Map<String, String> convertImageToText(String base64Image) {
        try {
            // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
            String cleanBase64 = removeDataUrlPrefix(base64Image);

            // Process the image using OCR service
            Map<String, String> extractedData = OCRService.processAnswerSheetImage(cleanBase64);

            return extractedData;

        } catch (Exception e) {
            System.debug('Error converting image to text: ' + e.getMessage());
            throw new DocumentProcessingException('Error converting image to text: ' + e.getMessage());
        }
    }

    /**
     * Creates answer sheet record from OCR extracted data
     * @param extractedData Map of region names to extracted text
     * @return AnswerSheet__c record with populated data
     */
    public static AnswerSheet__c createAnswerSheetFromOCR(Map<String, String> extractedData) {
        try {
            AnswerSheet__c answerSheet = new AnswerSheet__c();

            // Map extracted data to answer sheet fields
            answerSheet.RollNo__c = extractFieldValue(extractedData, 'rollNo');
            answerSheet.Name__c = extractFieldValue(extractedData, 'name');
            answerSheet.Slot__c = extractFieldValue(extractedData, 'slot');
            answerSheet.ExamType__c = extractFieldValue(extractedData, 'examType');

            // Extract answers
            answerSheet.Answer1__c = extractFieldValue(extractedData, 'answer1');
            answerSheet.Answer2__c = extractFieldValue(extractedData, 'answer2');
            answerSheet.Answer3__c = extractFieldValue(extractedData, 'answer3');
            answerSheet.Answer4__c = extractFieldValue(extractedData, 'answer4');
            answerSheet.Answer5__c = extractFieldValue(extractedData, 'answer5');
            answerSheet.Answer6__c = extractFieldValue(extractedData, 'answer6');
            answerSheet.Answer7__c = extractFieldValue(extractedData, 'answer7');
            answerSheet.Answer8__c = extractFieldValue(extractedData, 'answer8');
            answerSheet.Answer9__c = extractFieldValue(extractedData, 'answer9');
            answerSheet.Answer10__c = extractFieldValue(extractedData, 'answer10');

            // Insert the answer sheet
            insert answerSheet;

            return answerSheet;

        } catch (Exception e) {
            System.debug('Error creating answer sheet from OCR data: ' + e.getMessage());
            throw new DocumentProcessingException('Error creating answer sheet from OCR data: ' + e.getMessage());
        }
    }

    /**
     * Validates if the content type is a supported image format
     */
    private static Boolean isValidImageType(String contentType) {
        Set<String> supportedTypes = new Set<String>{
            'image/jpeg',
            'image/jpg',
            'image/png',
            'image/gif',
            'image/bmp',
            'image/tiff',
            'image/webp'
        };

        return supportedTypes.contains(contentType.toLowerCase());
    }

    /**
     * Removes data URL prefix from base64 string
     */
    private static String removeDataUrlPrefix(String base64Data) {
        if (base64Data.contains(',')) {
            return base64Data.substringAfter(',');
        }
        return base64Data;
    }

    /**
     * Extracts field value from extracted data map
     */
    private static String extractFieldValue(Map<String, String> extractedData, String fieldName) {
        String value = extractedData.get(fieldName);
        return value != null ? value.trim() : null;
    }

    /**
     * Processes multiple documents in batch
     */
    public static List<ProcessingResult> batchProcessDocuments(List<DocumentUpload> documentUploads) {
        List<ProcessingResult> results = new List<ProcessingResult>();

        for (DocumentUpload upload : documentUploads) {
            ProcessingResult result = uploadAndProcessDocument(
                upload.fileData,
                upload.fileName,
                upload.contentType
            );
            results.add(result);
        }

        return results;
    }

    /**
     * Validates OCR extracted data quality
     */
    public static ValidationResult validateOCRExtraction(Map<String, String> extractedData) {
        ValidationResult validation = new ValidationResult();

        // Check for required fields
        validation.rollNoPresent = extractedData.containsKey('rollNo') && !String.isBlank(extractedData.get('rollNo'));
        validation.namePresent = extractedData.containsKey('name') && !String.isBlank(extractedData.get('name'));
        validation.slotPresent = extractedData.containsKey('slot') && !String.isBlank(extractedData.get('slot'));
        validation.examTypePresent = extractedData.containsKey('examType') && !String.isBlank(extractedData.get('examType'));

        // Count answers present
        Integer answerCount = 0;
        for (Integer i = 1; i <= 10; i++) {
            String answerKey = 'answer' + i;
            if (extractedData.containsKey(answerKey) && !String.isBlank(extractedData.get(answerKey))) {
                answerCount++;
            }
        }
        validation.answersPresent = answerCount;

        // Calculate overall quality score
        Integer qualityScore = 0;
        if (validation.rollNoPresent) qualityScore += 20;
        if (validation.namePresent) qualityScore += 20;
        if (validation.slotPresent) qualityScore += 10;
        if (validation.examTypePresent) qualityScore += 10;
        qualityScore += (answerCount * 4); // 4 points per answer

        validation.qualityScore = qualityScore;
        validation.isValid = qualityScore >= 50; // At least 50% quality threshold

        return validation;
    }

    /**
     * Inner class for processing results
     */
    public class ProcessingResult {
        public Boolean success;
        public String fileName;
        public String contentType;
        public DateTime processedAt;
        public AnswerSheet__c answerSheet;
        public Map<String, String> extractedData;
        public String errorMessage;

        public ProcessingResult() {
            success = false;
        }
    }

    /**
     * Inner class for document upload data
     */
    public class DocumentUpload {
        public String fileData;
        public String fileName;
        public String contentType;

        public DocumentUpload(String fileData, String fileName, String contentType) {
            this.fileData = fileData;
            this.fileName = fileName;
            this.contentType = contentType;
        }
    }

    /**
     * Inner class for validation results
     */
    public class ValidationResult {
        public Boolean isValid;
        public Integer qualityScore;
        public Boolean rollNoPresent;
        public Boolean namePresent;
        public Boolean slotPresent;
        public Boolean examTypePresent;
        public Integer answersPresent;
    }

    /**
     * Custom exception for document processing errors
     */
    public class DocumentProcessingException extends Exception {}
}
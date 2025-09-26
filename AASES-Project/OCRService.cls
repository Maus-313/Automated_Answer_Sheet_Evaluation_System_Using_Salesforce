public with sharing class OCRService {

    // Google Cloud Vision API Key
    private static final String VISION_API_KEY = 'AIzaSyC_J85A6Bb8D9FFm8lCwjIL0KWTA9TRZxk';
    private static final String VISION_ENDPOINT = 'https://vision.googleapis.com/v1/images:annotate?key=' + VISION_API_KEY;

    public OCRService() {

    }

    /**
     * Extracts text from uploaded image using Google Cloud Vision API
     * @param base64Image Base64 encoded image string
     * @return OCRResult with extracted text and confidence scores
     */
    public static OCRResult extractTextFromImage(String base64Image) {
        try {
            String requestBody = buildTextDetectionRequest(base64Image);
            String response = makeVisionAPICall(requestBody);

            return parseTextDetectionResponse(response);

        } catch (Exception e) {
            System.debug('Error extracting text from image: ' + e.getMessage());
            throw new OCRProcessingException('Error extracting text from image: ' + e.getMessage());
        }
    }

    /**
     * Processes answer sheet image to identify specific regions
     * @param base64Image Base64 encoded answer sheet image
     * @return Map of regions to extracted text
     */
    public static Map<String, String> processAnswerSheetImage(String base64Image) {
        try {
            // First, get all text annotations from the image
            OCRResult fullResult = extractTextFromImage(base64Image);

            // Identify specific regions for student info and answers
            Map<String, String> regions = identifyTextRegions(fullResult);

            return regions;

        } catch (Exception e) {
            System.debug('Error processing answer sheet image: ' + e.getMessage());
            throw new OCRProcessingException('Error processing answer sheet image: ' + e.getMessage());
        }
    }

    /**
     * Identifies specific text regions in answer sheet
     * @param ocrResult Full OCR result from image
     * @return Map of region names to extracted text
     */
    public static Map<String, String> identifyTextRegions(OCRResult ocrResult) {
        Map<String, String> regions = new Map<String, String>();

        // Define regions based on typical answer sheet layout
        Map<String, RegionDefinition> regionDefinitions = getRegionDefinitions();

        for (TextAnnotation annotation : ocrResult.textAnnotations) {
            String region = identifyRegion(annotation, regionDefinitions);
            if (region != null) {
                if (!regions.containsKey(region)) {
                    regions.put(region, annotation.description);
                } else {
                    // Append if multiple text elements in same region
                    regions.put(region, regions.get(region) + ' ' + annotation.description);
                }
            }
        }

        return regions;
    }

    /**
     * Builds the request body for Google Cloud Vision text detection
     */
    private static String buildTextDetectionRequest(String base64Image) {
        Map<String, Object> requestBody = new Map<String, Object>{
            'requests' => new List<Object>{
                new Map<String, Object>{
                    'image' => new Map<String, Object>{
                        'content' => base64Image
                    },
                    'features' => new List<Object>{
                        new Map<String, Object>{
                            'type' => 'TEXT_DETECTION',
                            'maxResults' => 50
                        }
                    }
                }
            }
        };

        return JSON.serialize(requestBody);
    }

    /**
     * Makes HTTP call to Google Cloud Vision API
     */
    private static String makeVisionAPICall(String requestBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(VISION_ENDPOINT);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            throw new CalloutException('Vision API call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }

    /**
     * Parses the text detection response from Google Cloud Vision
     */
    private static OCRResult parseTextDetectionResponse(String response) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

            List<Object> responses = (List<Object>) responseMap.get('responses');
            if (responses == null || responses.isEmpty()) {
                throw new OCRProcessingException('No responses found in Vision API result');
            }

            Map<String, Object> firstResponse = (Map<String, Object>) responses[0];
            List<Object> textAnnotations = (List<Object>) firstResponse.get('textAnnotations');

            List<TextAnnotation> annotations = new List<TextAnnotation>();
            if (textAnnotations != null) {
                for (Object annotationObj : textAnnotations) {
                    Map<String, Object> annotationMap = (Map<String, Object>) annotationObj;
                    annotations.add(parseTextAnnotation(annotationMap));
                }
            }

            return new OCRResult(annotations);

        } catch (Exception e) {
            System.debug('Error parsing Vision API response: ' + e.getMessage());
            throw new OCRProcessingException('Error parsing Vision API response: ' + e.getMessage());
        }
    }

    /**
     * Parses individual text annotation from Vision API response
     */
    private static TextAnnotation parseTextAnnotation(Map<String, Object> annotationMap) {
        TextAnnotation annotation = new TextAnnotation();

        annotation.description = (String) annotationMap.get('description');
        annotation.locale = (String) annotationMap.get('locale');

        // Parse bounding polygon
        Map<String, Object> boundingPoly = (Map<String, Object>) annotationMap.get('boundingPoly');
        if (boundingPoly != null) {
            List<Object> vertices = (List<Object>) boundingPoly.get('vertices');
            if (vertices != null) {
                annotation.vertices = new List<Vertex>();
                for (Object vertexObj : vertices) {
                    Map<String, Object> vertexMap = (Map<String, Object>) vertexObj;
                    Vertex vertex = new Vertex();
                    vertex.x = (Integer) vertexMap.get('x');
                    vertex.y = (Integer) vertexMap.get('y');
                    annotation.vertices.add(vertex);
                }
            }
        }

        return annotation;
    }

    /**
     * Identifies which region a text annotation belongs to
     */
    private static String identifyRegion(TextAnnotation annotation, Map<String, RegionDefinition> regionDefinitions) {
        if (annotation.vertices == null || annotation.vertices.isEmpty()) {
            return null;
        }

        // Calculate center point of the text annotation
        Integer centerX = 0;
        Integer centerY = 0;
        Integer vertexCount = 0;

        for (Vertex vertex : annotation.vertices) {
            if (vertex.x != null && vertex.y != null) {
                centerX += vertex.x;
                centerY += vertex.y;
                vertexCount++;
            }
        }

        if (vertexCount > 0) {
            centerX = centerX / vertexCount;
            centerY = centerY / vertexCount;
        }

        // Check which region contains this center point
        for (String regionName : regionDefinitions.keySet()) {
            RegionDefinition region = regionDefinitions.get(regionName);
            if (isPointInRegion(centerX, centerY, region)) {
                return regionName;
            }
        }

        return null;
    }

    /**
     * Checks if a point is within a defined region
     */
    private static Boolean isPointInRegion(Integer x, Integer y, RegionDefinition region) {
        return x >= region.minX && x <= region.maxX && y >= region.minY && y <= region.maxY;
    }

    /**
     * Gets region definitions for typical answer sheet layout
     */
    private static Map<String, RegionDefinition> getRegionDefinitions() {
        Map<String, RegionDefinition> regions = new Map<String, RegionDefinition>();

        // Define regions based on typical answer sheet layout
        // These coordinates are approximate and may need adjustment based on actual form layout

        // Student Information regions
        regions.put('rollNo', new RegionDefinition(50, 150, 100, 130));      // Roll Number area
        regions.put('name', new RegionDefinition(200, 400, 100, 130));        // Name area
        regions.put('slot', new RegionDefinition(450, 550, 100, 130));        // Slot area
        regions.put('examType', new RegionDefinition(600, 750, 100, 130));    // Exam Type area

        // Answer regions (10 questions)
        regions.put('answer1', new RegionDefinition(100, 700, 150, 200));
        regions.put('answer2', new RegionDefinition(100, 700, 220, 270));
        regions.put('answer3', new RegionDefinition(100, 700, 290, 340));
        regions.put('answer4', new RegionDefinition(100, 700, 360, 410));
        regions.put('answer5', new RegionDefinition(100, 700, 430, 480));
        regions.put('answer6', new RegionDefinition(100, 700, 500, 550));
        regions.put('answer7', new RegionDefinition(100, 700, 570, 620));
        regions.put('answer8', new RegionDefinition(100, 700, 640, 690));
        regions.put('answer9', new RegionDefinition(100, 700, 710, 760));
        regions.put('answer10', new RegionDefinition(100, 700, 780, 830));

        return regions;
    }

    /**
     * Inner class for OCR results
     */
    public class OCRResult {
        public List<TextAnnotation> textAnnotations;

        public OCRResult(List<TextAnnotation> textAnnotations) {
            this.textAnnotations = textAnnotations;
        }
    }

    /**
     * Inner class for text annotations
     */
    public class TextAnnotation {
        public String description;
        public String locale;
        public List<Vertex> vertices;

        public TextAnnotation() {
            vertices = new List<Vertex>();
        }
    }

    /**
     * Inner class for vertex coordinates
     */
    public class Vertex {
        public Integer x;
        public Integer y;
    }

    /**
     * Inner class for region definitions
     */
    public class RegionDefinition {
        public Integer minX;
        public Integer maxX;
        public Integer minY;
        public Integer maxY;

        public RegionDefinition(Integer minX, Integer maxX, Integer minY, Integer maxY) {
            this.minX = minX;
            this.maxX = maxX;
            this.minY = minY;
            this.maxY = maxY;
        }
    }

    /**
     * Custom exception for OCR processing errors
     */
    public class OCRProcessingException extends Exception {}
}
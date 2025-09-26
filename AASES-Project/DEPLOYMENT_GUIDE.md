# 🚀 Automated Answer Sheet Evaluation System - Deployment Guide

## 📋 Prerequisites

Before deploying, ensure you have:
- ✅ Salesforce org with appropriate permissions
- ✅ Google Gemini API key configured
- ✅ Google Cloud Vision API key configured
- ✅ Salesforce CLI installed and authenticated
- ✅ All required permissions for metadata deployment

## 🔧 Step 1: Environment Setup

### 1.1 Authenticate with Salesforce CLI
```bash
sf org login web --alias AASES-Production
```

### 1.2 Verify API Keys in Environment
Ensure your `.env.local` file contains:
```env
GEMINI_API_KEY=AIzaSyC_J85A6Bb8D9FFm8lCwjIL0KWTA9TRZxk
GOOGLE_CLOUD_VISION_API_KEY=AIzaSyC_J85A6Bb8D9FFm8lCwjIL0KWTA9TRZxk
```

## 📦 Step 2: Deploy Metadata

### 2.1 Deploy All Components
```bash
cd /home/umar/Desktop/Salesforce/Automated_Answer_Sheet_Evaluation_System_Using_Salesforce/AASES-Project

# Deploy all metadata components
sf project deploy start --target-org AASES-Production
```

### 2.2 Deploy Specific Components (if needed)
```bash
# Deploy custom objects first
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/objects

# Deploy named credentials
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/namedCredentials

# Deploy Apex classes
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/classes

# Deploy Lightning components
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/lwc

# Deploy flows
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/flows

# Deploy reports and dashboards
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/reports
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/dashboards

# Deploy email templates and notifications
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/emailTemplates
sf project deploy start --target-org AASES-Production --source-dir force-app/main/default/customNotifications
```

## 🔐 Step 3: Security Configuration

### 3.1 Set Up Named Credentials
1. Go to Setup → Named Credentials
2. Verify "Google_Gemini" and "Google_Cloud_Vision" are created
3. Ensure API keys are properly configured

### 3.2 Configure Permission Sets
1. Go to Setup → Permission Sets
2. Create permission sets for different user roles:
   - **AASES Administrator**
   - **AASES Evaluator**
   - **AASES Data Entry**

### 3.3 Assign Permissions
```bash
# Create permission sets via CLI (if needed)
sf org assign permset --name AASES_Administrator --target-org AASES-Production
```

## 🧪 Step 4: Testing Checklist

### 4.1 User Role Testing
- [ ] ✅ Test System Administrator login
- [ ] ✅ Test Evaluator login
- [ ] ✅ Test Data Entry Operator login
- [ ] ✅ Verify role-based access control

### 4.2 Core Functionality Testing
- [ ] ✅ Create sample QuestionPaper records
- [ ] ✅ Create sample MarkingScheme records
- [ ] ✅ Test manual answer sheet entry
- [ ] ✅ Test OCR image upload and processing
- [ ] ✅ Test AI evaluation workflow
- [ ] ✅ Verify automated flow execution

### 4.3 Integration Testing
- [ ] ✅ Test Google Gemini API integration
- [ ] ✅ Test Google Cloud Vision API integration
- [ ] ✅ Test email notifications
- [ ] ✅ Test custom notifications
- [ ] ✅ Test approval workflows

### 4.4 Performance Testing
- [ ] ✅ Test bulk processing (50+ records)
- [ ] ✅ Test concurrent user access
- [ ] ✅ Monitor API rate limits
- [ ] ✅ Verify processing times

### 4.5 Reporting Testing
- [ ] ✅ Test all custom reports
- [ ] ✅ Verify dashboard functionality
- [ ] ✅ Test data refresh and updates
- [ ] ✅ Validate analytics calculations

## 🎯 Step 5: Demo Preparation

### 5.1 Create Sample Data
```bash
# Create sample data for demonstration
sf data create record --sobject QuestionPaper__c --target-org AASES-Production --values "Name='Sample CAT Paper' ExamType__c='CAT' Slot__c='A1'"

sf data create record --sobject MarkingScheme__c --target-org AASES-Production --values "Name='CAT Marking Scheme' ExamType__c='CAT' Slot__c='A1'"
```

### 5.2 Set Up Demo Users
1. Create test users for each role
2. Assign appropriate permission sets
3. Set up sample data for demonstration

## 📊 Step 6: Monitoring & Maintenance

### 6.1 Set Up Monitoring
- Monitor API usage and rate limits
- Set up alerts for system errors
- Configure log monitoring
- Track performance metrics

### 6.2 Regular Maintenance
- Review and optimize SOQL queries
- Monitor data storage usage
- Update API integrations as needed
- Regular security audits

## 🚨 Troubleshooting

### Common Issues:

**1. API Connection Errors**
```bash
# Test named credentials
sf org open --target-org AASES-Production --path /lightning/setup/NamedCredential/home
```

**2. Permission Errors**
```bash
# Check object permissions
sf org open --target-org AASES-Production --path /lightning/setup/ObjectManager/AnswerSheet__c/PermissionSets
```

**3. Flow Errors**
```bash
# Debug flows
sf org open --target-org AASES-Production --path /lightning/setup/Flows
```

**4. Report/Dashboard Issues**
```bash
# Verify report types
sf org open --target-org AASES-Production --path /lightning/setup/ReportTypes
```

## 📞 Support & Documentation

### Key Resources:
- **System Documentation**: `/docs/README.md`
- **API Documentation**: Google Gemini & Cloud Vision APIs
- **Salesforce Documentation**: Lightning Flows, Reports, Dashboards

### Support Contacts:
- **Technical Support**: Your development team
- **System Administrator**: Designated admin user
- **End User Support**: Help desk or training team

---

## 🎉 Deployment Complete!

Your Automated Answer Sheet Evaluation System is now deployed and ready for production use. The system includes:

✅ **Complete data model** with all required entities
✅ **Role-based security** and permissions
✅ **Modern Lightning Web Components** UI
✅ **AI-powered evaluation system** with Gemini integration
✅ **OCR integration** for document processing
✅ **Automated workflow processes** with Lightning Flows
✅ **Comprehensive reporting and analytics** with dashboards
✅ **Email and custom notifications** system
✅ **Bulk processing capabilities**
✅ **Quality assurance and validation** workflows

The system is designed to handle high-volume evaluation processing with enterprise-grade reliability and performance.
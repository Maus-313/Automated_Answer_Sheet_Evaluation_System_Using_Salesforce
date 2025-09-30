# Automated Answer Sheet Evaluation System CRM with Salesforce

## 📋 Overview

AASES is an automated answer sheet grading system; we use Salesforce separately to manage educator–student relationships, track users, and share students’ responses with instructors.

## ✨ Key Features

### 🎯 Core Functionality
- **Automated Grading**: AI-powered evaluation using machine learning algorithms
- **Rubric-Based Assessment**: Flexible marking schemes defined by professors
- **Multi-format Support**: MCQ, Short Answer, Essay, and custom question types
- **Real-time Feedback**: Instant grading results with detailed rationale
- **Confidence Scoring**: AI confidence levels for each evaluation

### 👥 Multi-Stakeholder Support
- **Students**: Submit answers, view grades, request re-evaluations
- **Professors**: Define marking schemes, validate/override AI grading
- **Teaching Assistants**: Review flagged answers and assist in grading
- **Administrators**: Manage organization, permissions, and system settings

### 🔄 Workflow Automation
- **Seamless Integration**: Built-in Salesforce workflow and automation
- **Audit Trail**: Complete tracking of all grading activities
- **Approval Processes**: Multi-level review for low-confidence grades
- **Notification System**: Automated alerts for stakeholders

## 🛠 Technology Stack

- **Platform**: Salesforce Lightning Experience
- **Development**: Apex, Lightning Web Components (LWC)
- **Automation**: Flow Builder, Process Builder, Workflow Rules
- **AI Integration**: External ML APIs via REST callouts
- **Data Management**: Custom Objects, SOQL/SOSL
- **Security**: Profiles, Permission Sets, Field-Level Security
- **Reporting**: Custom Reports, Dashboards, Einstein Analytics

## 📁 Project Structure

The project is organized into 10 comprehensive phases:

### Phase 1: Problem Understanding & Industry Analysis 
- Requirements gathering from stakeholders
- Business process mapping
- Industry use case analysis
- AppExchange exploration

### Phase 2: Org Setup & Configuration
- Salesforce Developer Edition setup
- Custom app creation
- Custom objects and fields configuration
- Security and permissions setup

### Phase 3: Data Modeling & Relationships 
- ✅ Created 4 core custom objects: AnswerSheet__c, QuestionPaper__c, MarkingScheme__c, MarkingSheet__c
- ✅ Configured comprehensive field structure:
  - **AnswerSheet__c**: RollNo, Name, Slot, ExamType, TotalMarks, Answer1-Answer10 (Long Text Areas)
  - **QuestionPaper__c**: Subject, Slot, CourseCode, ExamType, Question1-Question10 (Long Text Areas)
  - **MarkingScheme__c**: CourseCode, Slot, ExamType, Criteria1-Criteria10 (Long Text Areas)
  - **MarkingSheet__c**: RollNo, Name, Slot, ExamType, TotalMarks, Marks1-Marks10 (Number fields)
- ✅ Implemented picklist fields for Slot (A1-A2, B1-B2, C1-C2, D1-D2, E1-E2, F1-F2, G1-G2)
- ✅ Implemented picklist fields for ExamType (CAT, FAT)
- ✅ Set up external ID fields for RollNo to ensure uniqueness
- ✅ Created Salesforce CLI project structure with all metadata files

### Phase 4: User Roles & Permissions
- 🔄 Creating permission sets: AASES Administrator, AASES Evaluator, AASES Data Entry
- 🔄 Configuring object-level permissions for each role
- 🔄 Setting up field-level security
- 🔄 Assigning permission sets to users

### Phase 5: Process Automation
- Validation rules and workflow automation
- Process Builder implementations
- Flow Builder for complex business logic
- Email alerts and notifications

### Phase 6: User Interface Development
- Lightning App Builder configurations
- Custom Lightning Web Components
- Record pages and navigation
- Responsive design implementation

### Phase 7: Integration & External Access
- Named credentials for API security
- External service integrations
- Platform events and change data capture
- API limits management

### Phase 8: Data Management & Deployment
- Data import/export strategies
- Change sets and packages
- VS Code and SFDX integration
- Backup and recovery procedures

### Phase 9: Reporting, Dashboards & Security
- Custom reports and analytics
- Dynamic dashboards
- Security review and audit trails
- Compliance and governance

### Phase 10: Final Presentation & Demo
- Complete system demonstration
- Documentation and handoff
- Portfolio showcase

## 📊 Usage

### For Students
1. Navigate to the Automated Grading System app
2. Submit answers through the designated interface
3. View grades and feedback in real-time
4. Request re-evaluation if needed

### For Professors
1. Define marking rubrics and criteria
2. Review and validate AI-generated grades
3. Override grades when necessary
4. Monitor student performance through dashboards

### For Administrators
1. Manage user permissions and access
2. Monitor system performance and usage
3. Generate reports and analytics
4. Handle system maintenance and updates

## 📹 Demo Videos

Watch our comprehensive demo videos to see the system in action:

- **📂 Complete Demo Video Collection**: [View Demo Videos](https://drive.google.com/file/d/19zoUff2y9Zp40Mhcc0_Ey8FZ3QogHN-8/view?usp=sharing)



**Built with ❤️ using Salesforce Platform**

*Revolutionizing education through intelligent automation*

# Automated Answer Sheet Evaluation System Using Salesforce

An intelligent, AI-powered answer sheet evaluation system built on the Salesforce platform that automates the grading process for educational institutions and corporate training programs.

## 📋 Overview

This system revolutionizes traditional answer sheet evaluation by leveraging Salesforce's robust platform capabilities combined with machine learning algorithms to provide automated, accurate, and efficient grading solutions. The system supports multiple evaluation types including rubric-based grading, general grading, and provides detailed feedback to students.

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

### Phase 1: Problem Understanding & Industry Analysis ✅ COMPLETED
- Requirements gathering from stakeholders
- Business process mapping
- Industry use case analysis
- AppExchange exploration

### Phase 2: Org Setup & Configuration ✅ COMPLETED
- Salesforce Developer Edition setup
- Custom app creation
- Custom objects and fields configuration
- Security and permissions setup

### Phase 3: Data Modeling & Relationships ✅ COMPLETED
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

### Phase 4: User Roles & Permissions (In Progress)
- 🔄 Creating permission sets: AASES Administrator, AASES Evaluator, AASES Data Entry
- 🔄 Configuring object-level permissions for each role
- 🔄 Setting up field-level security
- 🔄 Assigning permission sets to users

### Phase 5: Process Automation (Pending)
- Validation rules and workflow automation
- Process Builder implementations
- Flow Builder for complex business logic
- Email alerts and notifications

### Phase 5: Apex Programming(Under Progress)
- Custom Apex classes and triggers
- SOQL/SOSL optimization
- Asynchronous processing (Future, Queueable, Batch)
- Exception handling and testing

### Phase 6: User Interface Development(Under Progress)
- Lightning App Builder configurations
- Custom Lightning Web Components
- Record pages and navigation
- Responsive design implementation

### Phase 7: Integration & External Access(Under Progress)
- Named credentials for API security
- External service integrations
- Platform events and change data capture
- API limits management

### Phase 8: Data Management & Deployment(Under Progress)
- Data import/export strategies
- Change sets and packages
- VS Code and SFDX integration
- Backup and recovery procedures

### Phase 9: Reporting, Dashboards & Security(Under Progress)
- Custom reports and analytics
- Dynamic dashboards
- Security review and audit trails
- Compliance and governance

### Phase 10: Final Presentation & Demo(Under Progress)
- Complete system demonstration
- Documentation and handoff
- Portfolio showcase

## 🚀 Getting Started

### Prerequisites
- Salesforce Developer Edition account
- Basic knowledge of Salesforce platform
- Understanding of Apex and Lightning Web Components

### Installation

1. **Sign Up for Salesforce Developer Edition**
   ```bash
   Visit: https://developer.salesforce.com/signup
   ```

2. **Clone the Repository**
   ```bash
   git clone https://github.com/Maus-313/Automated_Answer_Sheet_Evaluation_System_Using_Salesforce.git
   ```

3. **Set Up Development Environment**
   - Install Salesforce CLI
   - Configure VS Code with Salesforce extensions
   - Authorize your Salesforce org

4. **Deploy Components**
   - Deploy custom objects and fields
   - Deploy Apex classes and triggers
   - Deploy Lightning components
   - Configure automation flows

### Configuration

1. **Create Custom Objects**
   - Answer Submission
   - Marking Rubric
   - AutoGrade Result
   - Re-evaluation Request

2. **Set Up Security**
   - Configure profiles and permission sets
   - Set up sharing rules
   - Configure field-level security

3. **Configure Integrations**
   - Set up named credentials for ML API
   - Configure remote site settings
   - Set up external services

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

## 🤝 Contributing

We welcome contributions to improve the Automated Answer Sheet Evaluation System! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Salesforce best practices
- Include comprehensive test coverage
- Document all custom code
- Maintain security standards

## 📝 Documentation

- **Overview.pdf**: Detailed project documentation and phase descriptions
- **Phase 1.pdf**: Initial planning and analysis documentation
- **LICENSE**: Project licensing information

## 📹 Demo Videos

Watch our comprehensive demo videos to see the system in action:

- **📂 Complete Demo Video Collection**: [View Demo Videos](https://drive.google.com/drive/folders/1iYkvMyJF6IfemW3TLK6exN6Y5MT_fItO?usp=sharing)

The demo folder contains detailed walkthroughs of:
- System setup and configuration
- Answer sheet evaluation process
- AI-powered grading features
- User interface navigation
- Reporting and analytics

## 🔒 Security

This system implements comprehensive security measures:
- Role-based access control
- Field-level security
- Audit trails for all grading activities
- Secure API integrations
- Compliance with educational data standards

## 📈 Performance

The system is optimized for:
- High-volume grading operations
- Real-time processing capabilities
- Scalable architecture
- Efficient data management
- API rate limit compliance

## 🏆 Benefits

### Educational Institutions
- Reduced grading time by up to 80%
- Consistent and unbiased evaluation
- Detailed analytics and insights
- Improved student feedback loop

### Corporate Training
- Standardized assessment across departments
- Automated certification processes
- Performance tracking and reporting
- Cost-effective training evaluation

## 📞 Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Review the documentation in the docs folder

## 📄 License

This project is licensed under the terms specified in the LICENSE file.

---

**Built with ❤️ using Salesforce Platform**

*Revolutionizing education through intelligent automation*
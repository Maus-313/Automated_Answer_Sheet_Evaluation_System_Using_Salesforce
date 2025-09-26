import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AnswerSheetManager extends LightningElement {
    @track answerSheet = {
        rollNo: '',
        name: '',
        slot: '',
        examType: '',
        answers: [
            { id: 'answer-1', value: '' },
            { id: 'answer-2', value: '' },
            { id: 'answer-3', value: '' },
            { id: 'answer-4', value: '' },
            { id: 'answer-5', value: '' },
            { id: 'answer-6', value: '' },
            { id: 'answer-7', value: '' },
            { id: 'answer-8', value: '' },
            { id: 'answer-9', value: '' },
            { id: 'answer-10', value: '' }
        ]
    };

    @track isLoading = false;
    @track showSuccess = false;

    slotOptions = [
        { label: 'A1', value: 'A1' },
        { label: 'A2', value: 'A2' },
        { label: 'B1', value: 'B1' },
        { label: 'B2', value: 'B2' },
        { label: 'C1', value: 'C1' },
        { label: 'C2', value: 'C2' },
        { label: 'D1', value: 'D1' },
        { label: 'D2', value: 'D2' },
        { label: 'E1', value: 'E1' },
        { label: 'E2', value: 'E2' }
    ];

    examTypeOptions = [
        { label: 'CAT', value: 'CAT' },
        { label: 'FAT', value: 'FAT' },
        { label: 'Mid Term', value: 'Mid Term' },
        { label: 'Final Exam', value: 'Final Exam' }
    ];

    handleInputChange(event) {
        const field = event.target.dataset.field;
        if (field.startsWith('answer-')) {
            const answerId = field;
            const answer = this.answerSheet.answers.find(a => a.id === answerId);
            if (answer) {
                answer.value = event.target.value;
            }
        } else {
            this.answerSheet[field] = event.target.value;
        }
    }

    validateForm() {
        const allFields = this.template.querySelectorAll('lightning-input, lightning-textarea, lightning-combobox');
        let isValid = true;

        allFields.forEach(field => {
            if (!field.checkValidity()) {
                field.reportValidity();
                isValid = false;
            }
        });

        return isValid && this.answerSheet.rollNo && this.answerSheet.name && this.answerSheet.slot && this.answerSheet.examType;
    }

    async saveAnswerSheet() {
        if (!this.validateForm()) {
            this.showToast('Error', 'Please fill in all required fields correctly.', 'error');
            return;
        }

        this.isLoading = true;

        try {
            // Create the answer sheet record
            const answerSheetRecord = {
                RollNo__c: this.answerSheet.rollNo,
                Name__c: this.answerSheet.name,
                Slot__c: this.answerSheet.slot,
                ExamType__c: this.answerSheet.examType,
                Answer1__c: this.answerSheet.answers[0].value,
                Answer2__c: this.answerSheet.answers[1].value,
                Answer3__c: this.answerSheet.answers[2].value,
                Answer4__c: this.answerSheet.answers[3].value,
                Answer5__c: this.answerSheet.answers[4].value,
                Answer6__c: this.answerSheet.answers[5].value,
                Answer7__c: this.answerSheet.answers[6].value,
                Answer8__c: this.answerSheet.answers[7].value,
                Answer9__c: this.answerSheet.answers[8].value,
                Answer10__c: this.answerSheet.answers[9].value
            };

            // Here you would typically call an Apex method to save the record
            // For now, we'll just simulate the save operation
            await this.simulateSave(answerSheetRecord);

            this.showSuccess = true;
            this.showToast('Success', 'Answer Sheet saved successfully!', 'success');

            // Reset form after successful save
            this.resetForm();

        } catch (error) {
            console.error('Error saving answer sheet:', error);
            this.showToast('Error', 'Failed to save answer sheet. Please try again.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    simulateSave(record) {
        // Simulate API call delay
        return new Promise((resolve) => {
            setTimeout(() => {
                console.log('Answer Sheet saved:', record);
                resolve();
            }, 1000);
        });
    }

    resetForm() {
        this.answerSheet = {
            rollNo: '',
            name: '',
            slot: '',
            examType: '',
            answers: [
                { id: 'answer-1', value: '' },
                { id: 'answer-2', value: '' },
                { id: 'answer-3', value: '' },
                { id: 'answer-4', value: '' },
                { id: 'answer-5', value: '' },
                { id: 'answer-6', value: '' },
                { id: 'answer-7', value: '' },
                { id: 'answer-8', value: '' },
                { id: 'answer-9', value: '' },
                { id: 'answer-10', value: '' }
            ]
        };
        this.showSuccess = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get hasRequiredFields() {
        return this.answerSheet.rollNo && this.answerSheet.name && this.answerSheet.slot && this.answerSheet.examType;
    }
}
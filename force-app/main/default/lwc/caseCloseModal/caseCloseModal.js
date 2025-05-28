import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
export default class CaseResolutionModal extends LightningElement {
    @api caseId;
    @api resolutionNotes;
    disabledButton = true;

    handleInputChange(event) {
        this.resolutionNotes = event.target.value;

        if (this.resolutionNotes) this.disabledButton = false;
    }

    updateCaseAsClosed() {
        const fields = {
            Id: this.caseId,
            Resolution_Notes__c: this.resolutionNotes,
            Status__c: 'Closed'
        };

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.showToast('Sucesso', 'Caso fechado com sucesso!', 'success');
                this.showModal = false;

                this.dispatchEvent(new CustomEvent('refreshscreen'));
                this.dispatchEvent(new CustomEvent('updatestatusmessage'));
                this.closeModal();
            })
            .catch(error => {
                this.showToast('Erro', 'Preencha o campo Resolution Notes para fechar o caso', 'error');
            });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    showToast(title, message, variant) {
        const toastParams = {
            title: title,
            message: message,
            variant: variant,
            mode: 'stick'
        };
        const event =  new ShowToastEvent(toastParams);
        this.dispatchEvent(event);
    }
    
}
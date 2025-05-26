import { LightningElement, api } from 'lwc';

export default class CaseResolutionModal extends LightningElement {
    @api resolutionNotes = '';

    handleInputChange(event) {
        const value = event.target.value;
        this.dispatchEvent(new CustomEvent('notechange', { detail: value }));
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent('save'));
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }
}
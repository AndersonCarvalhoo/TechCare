import { LightningElement, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import CASE_CHANNEL from '@salesforce/messageChannel/caseChannel__c';

export default class CaseResolutionNotes extends LightningElement {
    resolutionNotes;
    showMore = true;
    maxLength = 300;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        subscribe(this.messageContext, CASE_CHANNEL, (message) => {
            if (message.status == 'Closed' && message.resolutionNotes) {
                this.resolutionNotes = message.resolutionNotes;
            } 
        });
    }

    get isTruncated() {
        return this.resolutionNotes && this.resolutionNotes.length > this.maxLength;
    }

    get visibleText() {
        if (!this.showMore || !this.isTruncated) {
            return this.resolutionNotes;            
        }

        return this.resolutionNotes.substring(0, this.maxLength) + '...';
    }

    toggleText() {
        this.showMore = !this.showMore;
    }
}
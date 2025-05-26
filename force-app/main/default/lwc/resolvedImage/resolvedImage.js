import { LightningElement, wire } from 'lwc';
import CASE_CHANNEL from '@salesforce/messageChannel/caseChannel__c';
import { subscribe, MessageContext } from 'lightning/messageService';
import RESOLVED_IMG from '@salesforce/resourceUrl/resolved_image';

export default class StaticImageViewer extends LightningElement {
    imageUrl = RESOLVED_IMG;
    showImage = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        
        subscribe(this.messageContext, CASE_CHANNEL, (message) => {
            if (message.status == 'Closed' && message.resolutionNotes) {
                this.showImage = true;
            } else {
                this.showImage = false;
            }
        });
    }
}
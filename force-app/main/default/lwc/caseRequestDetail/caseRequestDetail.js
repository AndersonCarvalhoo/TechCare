import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from "@salesforce/apex";
import getSLAInfo from '@salesforce/apex/CaseRequestDetailController.getSLAInfo';
import reopenCaseRequest from '@salesforce/apex/CaseRequestDetailController.reopenCaseRequest';
import { publish, MessageContext } from 'lightning/messageService';
import CASE_CHANNEL from '@salesforce/messageChannel/caseChannel__c';
import userId from '@salesforce/user/Id';

export default class CaseRequestDetail extends LightningElement {
    @api recordId;
    timeLeft;
    totalMilliseconds;
    slaStatus;
    interval;
    resolutionInputValue;
    resolutionNotes;
    slaMet = true;

    showModal;
    showInProgressButton;
    showCompleteButton;
    showReopenButton;
    formattedTime = '-';
    formattedTimeCircle = '-';
    showCircle;

    @wire(MessageContext)
    messageContext;

    updateStatusMessage() {
        const payload = { status: this.slaStatus, resolutionNotes: this.resolutionNotes };
        publish(this.messageContext, CASE_CHANNEL, payload);
    }

    @wire(getSLAInfo, {caseRequestId: '$recordId'}) 
    wiredSLAInfo(result) {
        if (result.data) {
            this.returnValue = result;
            this.totalMilliseconds = result.data.totalMilliseconds;
            this.timeLeft = result.data.millisRemaining;
            this.slaStatus = result.data.status;    
            this.showInProgressButton = this.slaStatus == 'New'; 
            this.resolutionNotes = result.data.resolutionNotes;
            this.showCompleteButton = this.slaStatus == 'In Progress' || this.slaStatus == 'Escalated';  

            if (this.slaStatus != 'Closed') {
                this.showReopenButton = false;
                this.showCircle = true;
                this.startTimer();
            } else {
                const isSupportPremiumUser = result.data.supportPremiumUser;

                if (isSupportPremiumUser) {
                    this.showReopenButton = true;
                }

                this.showCircle = false;
            }
            this.updateStatusMessage();
        }
    }

    startTimer() {
        this.interval = setInterval(() => {
            const days = Math.floor(this.timeLeft / (1000 * 60 * 60 * 24));
            const hours = Math.floor((this.timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((this.timeLeft % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((this.timeLeft % (1000 * 60)) / 1000);

            // Formatação do tempo
            if (days > 0) {
                this.formattedTime = `${days} ${days === 1 ? 'dia' : 'dias'} ${hours} horas ${minutes} minutos ${seconds} segundos`;
                this.formattedTimeCircle = `${days}d ${hours > 0 ? hours+'h' : ''}`;
            } else if (hours > 0) {
                this.formattedTime = `${hours} ${hours === 1 ? 'hora' : 'horas'} ${minutes} minutos ${seconds} segundos`;
                this.formattedTimeCircle = `${hours}h`;
            } else if (minutes > 0) {
                this.formattedTime = `${minutes} ${minutes === 1 ? 'minuto' : 'minutos'} ${seconds} segundos`;
                this.formattedTimeCircle = `${minutes}m`;
            } else if (seconds > 0) {
                this.formattedTime = `${seconds} segundos`;
                this.formattedTimeCircle = `${seconds}seg`;
            } else {
                this.formattedTime = 'SLA não cumprido';
                this.formattedTimeCircle = 'SLA não cumprido';
                this.slaMet = false;
            }

            if (this.timeLeft > 0) {
                this.timeLeft -= 1000;
            } else {
                clearInterval(this.interval);
                this.timeLeft = 0;
            }
        }, 1000);
    }

    handleClickCompleteCase() {
        this.showModal = true;
    }

    closeCaseModal() {
        this.showModal = false;
    }

    handleClickInProgressCase() {
        const fields = {
            Id: this.recordId, 
            Status__c: 'In Progress',
            OwnerId: userId
        };

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success', 'O Caso agora está In Progress!', 'success');
                this.showModal = false;

                this.refreshScreen();
                this.updateStatusMessage();
            })
            .catch(error => {
                this.showToast('Erro', 'Erro ao marcar In Progress! detalhes: ' + error?.body?.message, 'error');
            });
    }

    reopenCase() {
        reopenCaseRequest({caseRequestId: this.recordId})
            .then(data => {
                if(data.error) {
                    this.showToast('Erro', data.error, 'error');
                } else {
                    this.showToast('Sucesso', data.message, 'success');
                    this.refreshScreen();
                }
            })
            .catch( error  => {
                this.showToast('Erro', 'Erro inesperado: ' + error?.body?.message, 'error');
            });
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

    get progressOffset() {
        const radius = 48;
        const circumference = 2 * Math.PI * radius;
        const percent = this.totalMilliseconds > 0 ? this.timeLeft / this.totalMilliseconds : 0;
        console.log(circumference * (1 - percent))
        return percent > 0 ? circumference * (1 - percent) : 339.29; 
    }

    disconnectedCallback() {
        if (this.interval) {
            clearInterval(this.interval);
        }
    }

    refreshScreen() {
        this.dispatchEvent(new RefreshEvent());
        refreshApex(this.returnValue);
    }

}
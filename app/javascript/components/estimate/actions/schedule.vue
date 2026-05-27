<template>
  <app-right-sidebar-form
    :id='id'
    title='Schedule'
    submitText='Submit'
    :onSubmit='updateWorkDate'
    :submitting='submitting'
  >

    <template v-slot:content>
    <validation-observer ref="observer">
      <app-select-field
        label='Lead Arborist'
        v-model='lead_arborist'
        name='lead_arborist'
        :options="arboristOptions"
        validationRules='required'
      />
      <app-conditional-box
        v-model='scheduleWork'
        conditionName='Add Date Range'
        id='schedule-work'
        class='form-box'
      >
        <template>
          <app-datepicker
            v-model='work_start_date'
            locale='en-CA'
            id='start-date'
            name='start-date'
            label='Start Date'
            validationRules='required'
          >
          </app-datepicker>

          <app-datepicker
            v-model='work_end_date'
            locale='en-CA'
            id='end-date'
            name='end-date'
            label='End Date'
            validationRules='required'
          >
          </app-datepicker>
        </template>
      </app-conditional-box>

      <app-conditional-box
        v-model='emailTeam'
        conditionName='Email Team'
        id='email-team'
        class='form-box'
      >
        <app-email-arborist-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-arborist-form>
      </app-conditional-box>

      <app-conditional-box
        v-if='schedulingTemplates.length > 0'
        v-model='emailCustomer'
        conditionName='Email Customer'
        id='email-customer'
      >
        <app-select-field
          label='Schedule Template'
          v-model='selectedTemplateKey'
          name='scheduleTemplate'
          :options='templateOptions'
          validationRules='required'
        />
        <app-templated-email-form
          v-if='selectedTemplateKey'
          :value='customerEmailDefinition'
          @changed='payload => handleCustomerEmailChange(payload)'
          :template='selectedTemplateKey'
          :estimate='estimate'
        />
      </app-conditional-box>

    </validation-observer>
    </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus'
import EmailArboristForm from '../../common/forms/emailArboristSelect';
import TemplatedEmailForm from '../../common/forms/templatedEmail';
import { EmailDefinition } from '@/models';

export default {
  components: {
    'app-email-arborist-form': EmailArboristForm,
    'app-templated-email-form': TemplatedEmailForm
  },
  props: {
    id: {
      required: true
    },
    estimate: {
      required: true
    }
  },
  data() {
    return {
      work_start_date: this.estimate.work_start_date,
      work_end_date: this.estimate.work_end_date,
      lead_arborist: null,
      emailTeam: false,
      emailCustomer: false,
      scheduleWork: false,
      submitting: false,
      emailDefinition: null,
      customerEmailDefinition: null,
      schedulingTemplates: [],
      selectedTemplateKey: null
    }
  },
  methods: {
    updateWorkDate() {
      this.submitting = true;
      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        var params = {
          estimate: {
            work_start_date: null,
            work_end_date: null,
            skip_schedule: false,
            arborist_id: this.lead_arborist
          }
        }

        if(this.scheduleWork) {
          params.estimate.work_start_date = this.work_start_date;
          params.estimate.work_end_date = this.work_end_date;
        }
        else {
          params.estimate.work_start_date = null;
          params.estimate.work_end_date = null;
          params.estimate.skip_schedule = true;
        }

        this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
          Promise.all([
            this.sendQuoteMailout(),
            this.sendSchedulingMailout()
          ]).then(() => {
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('ESTIMATE_UPDATED', response.data);
            this.submitting = false;
          })
        })
      })

    },
    arboristValue(arborist){
      return {
        value: arborist.id,
        text: arborist.name
      }
    },
    subject() {
      var address = null;
      var customer = null

      if(this.estimate.site && this.estimate.site.address) {
        address = this.estimate.site.address.full_address
      }

      if(this.estimate.customer) {
        customer = this.estimate.customer.name;
      }

      return `Quote - ${customer} - ${address}`
    },
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    handleCustomerEmailChange(new_email) {
      this.customerEmailDefinition = { ...new_email }
    },
    sendQuoteMailout() {
      if(!this.emailTeam) { return Promise.resolve(1); }

      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }

      return this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params);
    },
    sendSchedulingMailout() {
      if(!this.emailCustomer || !this.customerEmailDefinition || !this.selectedTemplateKey) {
        return Promise.resolve(1);
      }

      return this.axiosPost(`/estimates/${this.estimate.id}/scheduling_mailouts`, {
        dest_email: this.customerEmailDefinition.email,
        subject: this.customerEmailDefinition.subject,
        content: this.customerEmailDefinition.content,
        template_key: this.selectedTemplateKey
      });
    }
  },
  computed: {
    arboristOptions() {
      return this.$store.state.arborists.map(arborist => {
        if(arborist.role == 'super_admin' || arborist.role == 'admin' || arborist.role == 'team_lead') {
          return this.arboristValue(arborist);
        }
      }).filter(arborist => !!arborist);;
    },
    templateOptions() {
      return this.schedulingTemplates.map(t => ({
        value: t.key,
        text: t.key.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase())
      }));
    }
  },
  mounted() {
    this.lead_arborist = this.estimate.arborist.id;

    this.axiosGet('/email_templates').then(response => {
      this.schedulingTemplates = response.data.email_templates.filter(t => t.category === 'scheduling');
      if (this.schedulingTemplates.length > 0) {
        this.selectedTemplateKey = this.schedulingTemplates[0].key;
      }
    });
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.emailDefinition = new EmailDefinition(
          null,
          this.subject(),
          'Take a look at this quote'
        )
      }
    },
    work_start_date() {
      if(this.work_end_date == null || this.work_end_date === undefined) {
        this.work_end_date = this.work_start_date;
      }
    }
  }
}
</script>

<style scoped>
  .form-box {
    margin-bottom: 16px;
  }
</style>

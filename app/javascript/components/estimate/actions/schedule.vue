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
      >
        <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
      </app-conditional-box>

    </validation-observer>
    </template>
  </app-right-sidebar-form>
</template>

<script>
import EventBus from '@/store/eventBus'
import EmailForm from '../../common/forms/emailArboristSelect';
import { EmailDefinition } from '@/models';

export default {
  components: {
    'app-email-form': EmailForm
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
      scheduleWork: false,
      submitting: false,
      emailDefinition: null
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
          this.sendQuoteMailout().then(res => {
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
    sendQuoteMailout() {
      if(!this.emailTeam) { return Promise.resolve(1); }

      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject
      }

      return this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params);
    }
  },
  computed: {
    arboristOptions() {
      return this.$store.state.arborists.map(arborist => {
        if(arborist.role == 'super_admin' || arborist.role == 'admin' || arborist.role == 'team_lead') {
          return this.arboristValue(arborist);
        }
      }).filter(arborist => !!arborist);;
    }
  },
  mounted() {
    this.lead_arborist = this.estimate.arborist.id;
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

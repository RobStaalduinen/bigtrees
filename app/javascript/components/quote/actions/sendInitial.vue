<template>
  <app-right-sidebar :id='id' title='Send Quote' submitText='Send' :onSubmit='sendQuote' :alternateAction='skipSend'>
    <template v-slot:content>
        <app-select-field
          label='Add Schedule Text'
          v-model='scheduleText'
          name='scheduleText'
          :options="scheduleTextOptions"
          validationRules='required'
        />
      <app-email-form :value='emailDefinition' @changed='payload => handleChange(payload)'></app-email-form>
    </template>
  </app-right-sidebar>
</template>

<script>
import EmailForm from '../../common/forms/email';
import { quoteContent, reducedCosts, nextFewDays, nextWeek, nextTwoWeeks, moreThanTwoWeeks } from '../../../content/emailContent';
import moment from 'moment';
import EventBus from '@/store/eventBus'
import { EmailDefinition } from '@/models';
import OrganizationEstimateMailer from '../../../content/organizationEstimateMailer'

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
      emailDefinition: null,
      scheduleText: 'none',
      baseContent: '',
      estimateMailer: new OrganizationEstimateMailer(this.$store.state.organization, this.estimate),
      scheduleTextOptions: [
        { value: 'none', text: 'No schedule'},
        { value: 'reduced_costs', text: 'Reduced Costs'},
        { value: 'next_few_days', text: 'Next few days'},
        { value: 'next_week', text: 'Within 1 week'},
        { value: 'next_two_weeks', text: 'Within 2 weeks'},
        { value: 'more_than_two_weeks', text: 'More than 2 weeks'}
      ]
    }
  },
  methods: {
    handleChange(new_email) {
      this.emailDefinition = { ...new_email }
    },
    sendQuote() {
      var params = {
        dest_email: this.emailDefinition.email,
        content: this.emailDefinition.content,
        subject: this.emailDefinition.subject,
        quote_sent_date: moment().format('YYYY-MM-DD')
      }
      this.axiosPost(`/estimates/${this.estimate.id}/quote_mailouts`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    },
    skipSend() {
      var params = {
        estimate: { quote_sent_date: moment().format('YYYY-MM-DD') }
      }

      this.axiosPut(`/estimates/${this.estimate.id}`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      })
    }
  },
  computed: {
    quoteContentOptions() {
      var options = {}
      if(this.scheduleText != 'none') {
        var contentMapper = {
          reduced_costs: reducedCosts,
          next_few_days: nextFewDays,
          next_week: nextWeek,
          next_two_weeks: nextTwoWeeks,
          more_than_two_weeks: moreThanTwoWeeks
        }
        options.afterList =  contentMapper[this.scheduleText]
      }
      return options;
    }
  },
  watch: {
    estimate: {
      immediate: true,
      handler() {
        this.emailDefinition = new EmailDefinition(
          this.estimate.customer_detail.email,
          "",
          this.estimateMailer.quoteContent(this.baseContent, this.quoteContentOptions)
        )
      }
    },
    scheduleText: {
      immediate: false,
      handler() {
        this.emailDefinition = new EmailDefinition(
          this.estimate.customer_detail.email,
          this.emailDefinition.subject,
          this.estimateMailer.quoteContent(this.baseContent, this.quoteContentOptions)
        )
      }
    }
  },
  mounted(){
    this.axiosGet('/email_templates/quote_mailout').then (response => {
      this.baseContent = response.data.email_template.content
      console.log(this.baseContent);
      this.emailDefinition = new EmailDefinition(
        this.estimate.customer_detail.email,
        response.data.email_template.parsed_subject,
        this.estimateMailer.quoteContent(this.baseContent, this.quoteContentOptions)
      )
    })
  }
}
</script>

<style scoped>

</style>

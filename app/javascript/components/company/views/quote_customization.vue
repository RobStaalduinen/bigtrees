<template>
  <div>
    <app-header title='Quote Customization' />

    <div class='intro'>
      Choose which pages your quotes include. The quote itself is always sent;
      these control the pages that follow it. Invoices and receipts are a single
      page and are not affected.
    </div>

    <div v-if='loading' class='loading'>
      <b-spinner small></b-spinner>
    </div>

    <div v-else class='settings-list'>
      <div class='settings-row' v-for='option in options' :key='option.key'>
        <div class='settings-left'>
          <app-checkbox-right-label
            :id='option.key'
            :label='option.label'
            v-model='settings[option.key]'
            @input='save'
          ></app-checkbox-right-label>
          <div class='settings-description'>{{ option.description }}</div>
        </div>
      </div>
    </div>

    <div class='footer-section' v-if='!loading'>
      <div class='section-title'>Quote Footer</div>
      <div class='settings-description footer-description'>
        The fine print at the bottom of every page of the quote. Line breaks are
        kept, so you can put insurance, licensing and tax details on separate lines.
      </div>

      <app-text-area
        label=''
        name='footer_text'
        :rows='4'
        v-model='settings.footer_text'
      ></app-text-area>
    </div>

    <div class='page-content' v-if='!loading'>
      <div class='section-title'>Before We Start Page</div>
      <div class='settings-description footer-description'>
        The notes that appear after the quote. Bold, italic and underline are available;
        line breaks are kept.
      </div>
      <app-rich-text
        v-model='settings.pre_job_content'
        :resettable='true'
        @reset='resetContent("pre_job_content")'
      ></app-rich-text>
    </div>

    <div class='page-content' v-if='!loading'>
      <div class='section-title'>Terms and Conditions Page</div>
      <div class='settings-description footer-description'>
        Your full terms. <b>[ORGANIZATION_NAME]</b> is replaced with your company name
        wherever it appears.
      </div>
      <app-rich-text
        v-model='settings.terms_content'
        :resettable='true'
        @reset='resetContent("terms_content")'
      ></app-rich-text>
    </div>

    <div class='actions' v-if='!loading'>
      <b-button class='inverse-button' @click='save'>Save Changes</b-button>
      <span class='save-state' v-if='savedAt'>Saved</span>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      company: this.$store.state.organization,
      loading: true,
      savedAt: null,
      settings: {
        include_image_page: true,
        include_pre_job_page: true,
        include_terms: true,
        footer_text: '',
        pre_job_content: '',
        terms_content: ''
      }
    }
  },
  computed: {
    options() {
      return [
        {
          key: 'include_image_page',
          label: 'Include Image Page',
          description: 'Photos taken during the site visit, shown after the quote.'
        },
        {
          key: 'include_pre_job_page',
          label: 'Include Pre-Job Page',
          description: 'The "Before we start" notes about access, pets, and scheduling.'
        },
        {
          key: 'include_terms',
          label: 'Include Terms',
          description: 'The full terms and conditions page.'
        }
      ];
    }
  },
  methods: {
    retrieve() {
      this.axiosGet(`/organizations/${this.company.id}/quote_settings`).then(response => {
        // The endpoint reports effective defaults when no record exists yet.
        const payload = response.data.quote_setting || response.data;

        this.options.forEach(option => {
          if (payload[option.key] !== undefined) {
            this.settings[option.key] = payload[option.key];
          }
        });
        this.settings.footer_text = payload.footer_text || '';
        this.settings.pre_job_content = payload.pre_job_content || '';
        this.settings.terms_content = payload.terms_content || '';
        this.loading = false;
      }).catch(() => {
        this.loading = false;
      })
    },
    // Clearing the column (rather than pasting the stock text in) puts the
    // organization back to tracking the standard wording, so later corrections
    // to it still reach them.
    resetContent(key) {
      this.axiosPut(
        `/organizations/${this.company.id}/quote_settings`,
        { quote_settings: { [key]: '' } }
      ).then(() => {
        this.savedAt = Date.now();
        this.retrieve();
      })
    },
    save() {
      this.axiosPut(
        `/organizations/${this.company.id}/quote_settings`,
        { quote_settings: this.settings }
      ).then(() => {
        this.savedAt = Date.now();
      })
    }
  },
  mounted() {
    this.retrieve();
  }
}
</script>

<style scoped>
  .intro {
    font-size: 13px;
    color: gray;
    margin-bottom: 16px;
    max-width: 640px;
  }

  .loading {
    padding: 16px 0;
  }

  .settings-list {
    display: flex;
    flex-direction: column;
  }

  .settings-row {
    padding: 10px 0;
    border-bottom: 1px solid #ccc;
  }

  .settings-description {
    font-size: 12px;
    color: gray;
    margin-left: 26px;
  }

  .footer-section {
    margin-top: 28px;
  }

  .section-title {
    font-weight: bold;
    margin-bottom: 4px;
  }

  .footer-description {
    margin-left: 0;
    margin-bottom: 10px;
    max-width: 640px;
  }

  .page-content {
    margin-top: 28px;
  }

  .actions {
    display: flex;
    align-items: center;
    margin-top: 20px;
  }

  .save-state {
    margin-left: 12px;
    font-size: 12px;
    color: gray;
  }
</style>

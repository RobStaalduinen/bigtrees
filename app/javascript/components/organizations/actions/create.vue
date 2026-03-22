<template>
  <div>
  <app-right-sidebar-form
    :id='id'
    title='Create Organization'
    submitText='Create'
    :onSubmit='createOrganization'
    @cancelled='reset'
    :submitting='submitting'
  >
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          v-model='organization.name'
          name='name'
          label='Company Name'
          validationRules='required'
        ></app-input-field>

        <app-input-field
          v-model='organization.legal_name'
          name='legal_name'
          label='Legal Name'
        ></app-input-field>

        <app-input-field
          v-model='organization.contact_person'
          name='contact_person'
          label='Contact Person'
        ></app-input-field>

        <app-input-field
          v-model='organization.email'
          name='email'
          label='Email'
          validationRules='email'
        ></app-input-field>

        <app-input-field
          v-model='organization.website'
          name='website'
          label='Website'
        ></app-input-field>

        <app-input-field
          v-model='organization.monthly_cost'
          name='monthly_cost'
          label='Monthly Cost'
          inputType='number'
        ></app-input-field>

        <div class='field-group'>
          <label>Logo</label>
          <b-form-file
            v-model='logoFile'
            accept='.jpg,.jpeg,.png'
            placeholder='Choose a file...'
          ></b-form-file>
          <app-single-uploader
            v-if='logoFile'
            :imageToUpload='logoFile'
            bucketName='organizations'
            @upload-status-changed='handleLogoUpload'
            @deleted='logoFile = null; organization.logo_url = null'
          ></app-single-uploader>
        </div>

        <div class='field-group'>
          <label>Primary Colour</label>
          <app-colour-picker v-model='organization.primary_colour'></app-colour-picker>
        </div>

        <div class='field-group'>
          <label>Secondary Colour</label>
          <app-colour-picker v-model='organization.secondary_colour'></app-colour-picker>
        </div>

        <div class='error-box' v-if='errorMessage'>
          {{ errorMessage }}
        </div>
      </validation-observer>
    </template>
  </app-right-sidebar-form>

  <b-modal id='organization-created-modal' title='Organization Created' ok-title='Done' ok-only>
    <p>The organization has been created. Send the following temporary password to <strong>{{ createdContactPerson }}</strong>:</p>
    <b-input-group>
      <b-form-input readonly :value='temporaryPassword' ref='passwordField'></b-form-input>
      <b-input-group-append>
        <b-button variant='outline-secondary' @click='copyPassword'>{{ copied ? 'Copied!' : 'Copy' }}</b-button>
      </b-input-group-append>
    </b-input-group>
  </b-modal>
  </div>
</template>

<script>
import EventBus from '@/store/eventBus';
import SingleUploader from '@/components/file/actions/singleUploader';

export default {
  props: ['id'],
  components: {
    'app-single-uploader': SingleUploader
  },
  data() {
    return {
      organization: {
        primary_colour: '#000000',
        secondary_colour: '#000000'
      },
      logoFile: null,
      submitting: false,
      errorMessage: null,
      temporaryPassword: null,
      createdContactPerson: null,
      copied: false
    }
  },
  methods: {
    createOrganization() {
      this.errorMessage = null;
      this.submitting = true;

      this.$refs.observer.validate().then(success => {
        if (!success) {
          this.submitting = false;
          return;
        }

        this.axiosPost('/organizations', { organization: { ...this.organization } }).then(response => {
          this.temporaryPassword = response.data.temporary_password;
          this.createdContactPerson = this.organization.contact_person;
          this.$root.$emit('bv::toggle::collapse', this.id);
          EventBus.$emit('ORGANIZATION_CREATED');
          setTimeout(() => {
            this.reset();
            this.$bvModal.show('organization-created-modal');
          }, 500);
        }).catch(error => {
          this.errorMessage = 'Something went wrong. Please try again.';
          this.submitting = false;
        });
      });
    },
    handleLogoUpload({ uploading, url }) {
      if (!uploading && url) {
        this.organization.logo_url = url;
      }
    },
    copyPassword() {
      navigator.clipboard.writeText(this.temporaryPassword).then(() => {
        this.copied = true;
        setTimeout(() => { this.copied = false; }, 2000);
      });
    },
    reset() {
      this.organization = {
        primary_colour: '#000000',
        secondary_colour: '#000000'
      };
      this.logoFile = null;
      this.submitting = false;
      this.errorMessage = null;
      // temporaryPassword and createdContactPerson are kept until the modal is dismissed
    }
  }
}
</script>

<style scoped>
  .field-group {
    margin-bottom: 12px;
  }

  .field-group label {
    display: block;
    font-size: 14px;
    margin-bottom: 4px;
  }
</style>

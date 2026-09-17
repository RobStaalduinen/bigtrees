<template>
  <app-scrollable-sidebar
    :id='id'
    :title='sidebarTitle'
    :submitText='submitText'
    :onSubmit='submit'
    @cancelled='reset'
  >
    <template v-slot:content>
      <validation-observer ref="observer">
        <app-input-field
          :value='insertableKey'
          @input='setKey'
          name='key'
          label='Template Key'
          validationRules='required'
        />

        <div class='insertable-key-hint'>
          Reference this in a template as <b>{{ placeholder }}</b>.
          <span v-if='isEdit' class='insertable-key-warning'>
            Changing the key will stop any template still using the old placeholder from
            offering these options.
          </span>
        </div>

        <app-input-field
          v-model='label'
          name='label'
          label='Label'
          validationRules='required'
        />

        <div class='insertable-options-header'>
          <b>Options</b>
          <span class='insertable-options-count'>{{ options.length }} / {{ maxOptions }}</span>
        </div>

        <div v-for='(option, index) in options' :key='option.uid' class='insertable-option-entry'>
          <div class='insertable-option-title'>
            Option #{{ index + 1 }}
            <b-icon
              icon='trash-fill'
              class='app-icon edit-icon'
              v-if='options.length > 1'
              @click='deleteOption(index)'
            />
          </div>

          <app-input-field
            v-model='option.label'
            :name='`option_${index}_label`'
            label='Label'
            validationRules='required'
          />

          <app-text-area
            v-model='option.content'
            :name='`option_${index}_content`'
            label='Content'
            :rows=4
          />
        </div>

        <div
          class='insertable-add-option'
          v-if='options.length < maxOptions'
          @click.prevent='addOption'
        >
          + Add Option +
        </div>

        <div v-if='formError' class='insertable-form-error'>{{ formError }}</div>
      </validation-observer>
    </template>
  </app-scrollable-sidebar>
</template>

<script>

import EventBus from '@/store/eventBus';

const MAX_OPTIONS = 10;
const KEY_FORMAT = /^[A-Z][A-Z0-9_]*$/;

function uid() {
  return Math.random().toString(36).substr(2, 9);
}

export default {
  props: {
    id: {
      required: true
    },
    // Every insertable in the organization, used to keep the key unique without a round trip.
    insertables: {
      required: false,
      type: Array,
      default: () => []
    },
    // Placeholders the templates substitute themselves; the model refuses these as keys.
    reservedKeys: {
      required: false,
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      editing: null,
      insertableKey: '',
      label: '',
      options: [this.blankOption()],
      removedOptionIds: [],
      formError: null,
      maxOptions: MAX_OPTIONS
    }
  },
  computed: {
    isEdit() {
      return this.editing != null;
    },
    sidebarTitle() {
      return this.isEdit ? 'Edit Insertable Content' : 'New Insertable Content';
    },
    submitText() {
      return this.isEdit ? 'Save' : 'Create';
    },
    placeholder() {
      return `[${this.insertableKey || 'KEY'}]`;
    }
  },
  methods: {
    // Called by the list rather than toggling the sidebar directly, so the form is always
    // seeded from the record being opened — including 'New' twice in a row.
    open(insertable = null) {
      this.load(insertable);
      this.$root.$emit('bv::toggle::collapse', this.id);
    },
    load(insertable) {
      this.editing = insertable;
      this.insertableKey = insertable ? insertable.key : '';
      this.label = insertable ? insertable.label : '';
      this.removedOptionIds = [];
      this.formError = null;

      const existing = (insertable && insertable.options) || [];
      this.options = existing.length > 0
        ? existing.map(option => ({ uid: uid(), id: option.id, label: option.label, content: option.content }))
        : [this.blankOption()];
    },
    blankOption() {
      return { uid: uid(), id: null, label: null, content: null };
    },
    addOption() {
      if (this.options.length >= MAX_OPTIONS) { return; }

      this.options.push(this.blankOption());
    },
    deleteOption(index) {
      const [removed] = this.options.splice(index, 1);

      if (removed.id) { this.removedOptionIds.push(removed.id); }
    },
    setKey(value) {
      this.insertableKey = value.toUpperCase().replace(/[^A-Z0-9_]+/g, '_');
    },
    keyError() {
      if (!KEY_FORMAT.test(this.insertableKey)) {
        return 'The key must start with a letter and use only uppercase letters, numbers and underscores.';
      }

      if (this.reservedKeys.includes(this.insertableKey)) {
        return `${this.placeholder} is reserved and cannot be used as a key.`;
      }

      const clash = this.insertables.some(insertable =>
        insertable.key === this.insertableKey && (!this.editing || insertable.id !== this.editing.id)
      );

      if (clash) {
        return `The key ${this.placeholder} is already in use.`;
      }

      return null;
    },
    validate() {
      this.formError = this.keyError();

      if (!this.formError && this.options.some(option => !option.content || !option.content.trim())) {
        this.formError = 'Every option needs content.';
      }

      return this.formError == null;
    },
    optionsAttributes() {
      const present = this.options.map((option, index) => ({
        id: option.id,
        label: option.label,
        content: option.content,
        position: index
      }));

      const removed = this.removedOptionIds.map(id => ({ id: id, _destroy: true }));

      return present.concat(removed);
    },
    submit() {
      this.$refs.observer.validate().then(success => {
        if (!success || !this.validate()) {
          EventBus.$emit('FORM_VALIDATION_FAILED');
          return;
        }

        const payload = {
          email_insertable: {
            key: this.insertableKey,
            label: this.label,
            options_attributes: this.optionsAttributes()
          }
        };

        const request = this.isEdit
          ? this.axiosPut(`/email_insertables/${this.editing.id}`, payload)
          : this.axiosPost('/email_insertables', payload);

        request.then(response => {
          this.$root.$emit('bv::toggle::collapse', this.id);
          this.reset();
          this.$emit('changed', response.data.email_insertable);
        }).catch(error => {
          this.formError = this.serverError(error);
          EventBus.$emit('FORM_VALIDATION_FAILED');
        })
      })
    },
    // The controller renders `record.errors`, i.e. { key: ['is reserved'] }.
    serverError(error) {
      const errors = error.response && error.response.data;

      if (!errors || typeof errors !== 'object') {
        return 'The insertable could not be saved.';
      }

      return Object.keys(errors)
        .map(field => `${field.replace(/_/g, ' ')} ${[].concat(errors[field]).join(', ')}`)
        .join('. ');
    },
    reset() {
      this.load(this.editing);
    }
  }
}

</script>

<style scoped>
  .insertable-key-hint {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin-top: calc(-1 * var(--space-2));
    margin-bottom: var(--space-4);
  }

  .insertable-key-warning {
    display: block;
    margin-top: var(--space-1);
    color: var(--main-color);
  }

  .insertable-options-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;

    padding-bottom: var(--space-1);
    border-bottom: 1px solid var(--border);
  }

  .insertable-options-count {
    font-size: var(--text-xs);
    color: var(--text-muted);
  }

  .insertable-option-entry {
    border-bottom: 1px solid var(--border);
    padding-top: var(--space-2);
  }

  .insertable-option-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: var(--text-sm);
    margin-bottom: var(--space-1);
  }

  .insertable-add-option {
    display: flex;
    justify-content: center;
    width: 100%;

    color: var(--main-color);
    font-size: var(--text-lg);
    margin-top: var(--space-2);
    cursor: pointer;
  }

  .insertable-form-error {
    font-size: var(--text-xs);
    font-style: italic;
    color: var(--danger);
    margin-top: var(--space-2);
  }
</style>

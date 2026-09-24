<template>
  <b-modal
    :id='id'
    size='xl'
    title='Edit Email Content'
    ok-title='Done'
    cancel-title='Cancel'
    @show='seedDraft'
    @ok='save'
  >
    <p class='edit-content-note'>
      You are editing this email as a template. Macros are left as they are and filled in when the
      email is sent, so <b>[FIRST_NAME]</b> still becomes the customer's name. Adding or removing an
      insertable changes which options you are offered back on the form.
    </p>

    <div class='edit-content-layout'>
      <b-form-textarea
        v-model='draft'
        class='edit-content-field'
        name='email-content'
        rows='20'
        max-rows='20'
        no-resize
      ></b-form-textarea>

      <app-placeholder-reference class='edit-content-reference' />
    </div>
  </b-modal>
</template>

<script>

import PlaceholderReference from '@/components/common/forms/placeholderReference';

// Edits the stored wording of an email before macros and insertables are applied, so what the
// sender changes is the template rather than one rendered copy of it.
export default {
  components: {
    'app-placeholder-reference': PlaceholderReference
  },
  props: {
    id: {
      required: true
    },
    content: {
      required: false,
      type: String,
      default: ''
    }
  },
  data() {
    return {
      draft: ''
    }
  },
  methods: {
    // Seeded on open rather than watched, so cancelling leaves the original wording alone.
    seedDraft() {
      this.draft = this.content || '';
    },
    save() {
      this.$emit('saved', this.draft);
    }
  }
}

</script>

<style scoped>
  .edit-content-note {
    font-size: var(--text-xs);
    color: var(--text-muted);
    margin-bottom: var(--space-3);
  }

  .edit-content-layout {
    display: flex;
    flex-direction: column;
    gap: var(--space-4);
  }

  .edit-content-field {
    font-size: var(--text-base);
  }

  @media (min-width: 760px) {
    .edit-content-layout {
      flex-direction: row;
      align-items: flex-start;
    }

    .edit-content-field {
      flex: 1;
      min-width: 0;
    }

    .edit-content-reference {
      width: 280px;
      flex-shrink: 0;
    }
  }
</style>

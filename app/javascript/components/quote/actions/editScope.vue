<template>
  <app-scrollable-sidebar
    :id='id'
    title='Edit Quote Scope'
    submitText='Save'
    :onSubmit='save'
    :submitting='submitting'
    @cancelled='reset'
  >
    <template v-slot:content>
      <div id='scope-editor'>
        <app-text-area
          label='Scope of work'
          name='scope_of_work'
          :rows='5'
          v-model='scopeOfWork'
        ></app-text-area>
        <div class='field-hint'>
          A short paragraph describing the job. Leave blank to omit the section from the quote.
        </div>

        <app-scope-list
          label="What's included"
          addLabel='Add an inclusion'
          placeholder='e.g. Stump grinding to 8 in. below grade'
          v-model='inclusions'
        ></app-scope-list>

        <app-scope-list
          label='Not included'
          addLabel='Add an exclusion'
          placeholder='e.g. Topsoil or sod over the ground stumps'
          v-model='exclusions'
        ></app-scope-list>
      </div>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus';
import ScopeList from '../forms/scopeList';

export default {
  components: {
    'app-scope-list': ScopeList
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
      scopeOfWork: '',
      inclusions: [],
      exclusions: [],
      submitting: false
    }
  },
  methods: {
    save() {
      if(this.submitting) { return; }
      this.submitting = true;

      const params = {
        scope_of_work: this.scopeOfWork,
        inclusions: this.inclusions.map(i => i.text),
        exclusions: this.exclusions.map(e => e.text)
      };

      this.axiosPost(`/estimates/${this.estimate.id}/quote_scope/update`, params).then(response => {
        this.submitting = false;
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
      }).catch(() => {
        this.submitting = false;
      })
    },
    reset() {
      const scope = this.estimate.quote_scope;

      this.scopeOfWork = (scope && scope.scope_of_work) || '';
      this.inclusions = this.toRows((scope && scope.inclusions) || []);
      this.exclusions = this.toRows((scope && scope.exclusions) || []);
    },
    // The list editor needs a stable key per row so Vue doesn't reuse inputs
    // across a removal; the text alone isn't unique.
    toRows(values) {
      return values.map(text => ({
        key: Math.random().toString(36).substr(2, 9),
        text: text
      }));
    }
  },
  mounted() {
    this.reset();
  },
  watch: {
    // The page swaps in a fresh estimate whenever anything on it changes (an image upload
    // finishing, say), so reload only when the saved scope differs — otherwise an edit in
    // progress would be thrown away.
    'estimate.quote_scope'(newScope, oldScope) {
      if (JSON.stringify(newScope) === JSON.stringify(oldScope)) { return; }

      this.reset();
    }
  }
}
</script>

<style scoped>
  #scope-editor {
    padding-bottom: 24px;
  }

  .field-hint {
    font-size: 12px;
    color: var(--muted, #6E7365);
    margin-top: -12px;
    margin-bottom: 20px;
  }
</style>

<template>
  <app-scrollable-sidebar :id='id' title='Owner' submitText='Save' :onSubmit='handleSubmit'>
    <template v-slot:content>
      <app-select-field v-model='arborist' :options='options' label='Owner' name='arborist'/>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import EventBus from '@/store/eventBus';

export default {
  props: {
    id: { required: true },
    estimate: { required: true }
  },
  data() {
    return {
      arborist: this.estimate.arborist.id
    }
  },
  computed: {
    options() {
      return this.$store.state.arborists
        .filter(a => ['super_admin', 'admin', 'team_lead'].includes(a.role))
        .map(a => ({ value: a.id, text: a.name }));
    }
  },
  methods: {
    handleSubmit() {
      if (this.arborist === this.estimate.arborist.id) {
        this.$root.$emit('bv::toggle::collapse', this.id);
        return;
      }

      const params = { estimate: { arborist_id: this.arborist } };

      this.axiosPut(`/estimates/${this.estimate.id}`, params)
        .then(response => {
          if (response.status === 200) {
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('ESTIMATE_UPDATED', response.data);
          }
        });
    }
  },
  watch: {
    'estimate.arborist.id'(newVal) {
      this.arborist = newVal;
    }
  }
}
</script>

<template>
    <app-right-sidebar :id='id' title='Resolve Equipment Request' submitText='Resolve' :onSubmit='resolveEquipmentRequest' @cancelled='reset'>
      <template v-slot:content>
          <app-input-field
            v-model='notes'
            name="notes"
            label='Notes (optional)'
            validationRules='required'
          ></app-input-field>
      </template>
  </app-right-sidebar>
</template>

<script>
  import EventBus from '@/store/eventBus';

  export default {
    props: ['id', 'equipmentRequest'],
    data() {
      return {
        notes: null
      }
    },
    methods: {
      reset() {
        this.notes = null;
      },
      resolveEquipmentRequest() {
        let params = { equipment_request: { resolution_notes: this.notes }}

        this.axiosPost(`/equipment_requests/${this.equipmentRequest.id}/resolve`, params).then(response => {
            this.$root.$emit('bv::toggle::collapse', this.id);
            EventBus.$emit('EQUIPMENT_REQUEST_UPDATED');
            setTimeout(() => {
              this.reset();
            }, 500);
        })
      }
    }
  }

</script>

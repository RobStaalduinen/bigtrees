<template>
  <app-scrollable-sidebar :id='id' title='Edit Equipment Requirements' submitText='Save' :onSubmit='updateEquipmentRequirements' @cancelled='reset'>
    <template v-slot:content>
      <div>
        <app-multi-requirements v-model='equipmentRequirements'></app-multi-requirements>
      </div>
    </template>
  </app-scrollable-sidebar>
</template>

<script>
import MultiSelect from '../forms/mutliSelect';
import EventBus from '@/store/eventBus';

export default {
  components: {
    'app-multi-requirements': MultiSelect
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
      equipmentRequirements: null
    }
  },
  methods: {
    updateEquipmentRequirements() {
      let assignments = this.equipmentRequirements.map ( requirement => {
        return { vehicle_id: requirement }
      })

      var params = { estimate: { equipment_assignments_attributes: assignments } }
      this.axiosPost(`/estimates/${this.estimate.id}/equipment_assignments/bulk_update`, params).then(response => {
        this.$root.$emit('bv::toggle::collapse', this.id);
        EventBus.$emit('ESTIMATE_UPDATED', response.data);
        this.reset();
      })
    },
    reset() {
      this.equipmentRequirements = this.estimate.vehicles.map (v => v.id)
    }
  },
  mounted() {
    this.reset();
  },
  watch: {
    estimate() {
      if(this.estimate == null) {
        return
      }
      this.equipmentRequirements = this.estimate.vehicles.map (v => v.id)
    }
  }
}
</script>

<style scoped>


</style>

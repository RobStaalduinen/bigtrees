<template>
  <div>
    <div v-if='tools.length > 0'>
      <app-checkbox-highlight
        v-for='(tool, index) in tools'
        :key='tool.id'
        :checkedValue='tool.id'
        :label='tool.name'
        :id='`tool-checkbox-${tool.id}`'
        v-model='selected[index]'
      />
    </div>
  </div>
</template>

<script>
export default {
  props:{
    value: {
      required: true,
      type: Array
    }
  },
  data() {
    return {
      tools: [],
      selected: []
    }
  },
  mounted() {
    this.axiosGet(`/vehicles`).then(response => {
      this.tools = response.data.vehicles;

      this.tools.forEach((tool, index) => {
        this.selected[index] = this.value.find(v => v == tool.id) ? tool.id : null
      })
    })
  },
  computed: {
    activeSelected() {
      return this.selected.filter(selection => selection != null && selection != undefined)
    }
  },
  watch: {
    selected() {
      this.$emit('input', this.activeSelected)
    }
  }
}
</script>

<style scoped>

</style>

<template>
  <div>
    <div class='selected-summary'>
      <template v-if='selectedTools.length > 0'>
        <app-pill
          v-for='tool in selectedTools'
          :key='tool.id'
          :text='tool.name'
          tone='brand'
          filled
        ></app-pill>
      </template>
      <span v-else class='no-selection'>No equipment selected</span>
    </div>

    <a class='modify-link' v-b-modal='modalId'>+ Modify Equipment +</a>

    <b-modal :id='modalId' centered title='Equipment &amp; Tool Requirements'>
      <div v-if='tools.length > 0'>
        <app-checkbox-highlight
          v-for='tool in tools'
          :key='tool.id'
          :checkedValue='tool.id'
          :label='tool.name'
          :id='`tool-checkbox-${tool.id}`'
          :value='isSelected(tool.id) ? tool.id : null'
          @input='(val) => toggleTool(tool.id, val)'
        />
      </div>
      <div v-else class='no-selection'>Loading equipment…</div>

      <template v-slot:modal-footer>
        <b-button block class='submit-button' @click='close'>Done</b-button>
      </template>
    </b-modal>
  </div>
</template>

<script>
// New-quote equipment picker. Instead of rendering every vehicle inline (a lot
// of permanent vertical space), it shows only the selected equipment and opens
// the full checklist in a modal via "+ Modify Equipment +".
export default {
  props: {
    value: {
      required: true,
      type: Array
    }
  },
  data() {
    return {
      tools: [],
      selectedIds: [...this.value],
      // Unique per instance so multiple pickers never collide on modal id.
      modalId: `equipment-modal-${Math.random().toString(36).substr(2, 9)}`
    }
  },
  computed: {
    selectedTools() {
      return this.tools.filter(tool => this.selectedIds.includes(tool.id))
    }
  },
  methods: {
    isSelected(id) {
      return this.selectedIds.includes(id)
    },
    // checkbox-highlight emits its checkedValue (the tool id) when checked and
    // the uncheckedValue (null) when unchecked.
    toggleTool(id, val) {
      if (val && !this.selectedIds.includes(id)) {
        this.selectedIds.push(id)
      } else if (!val) {
        this.selectedIds = this.selectedIds.filter(selectedId => selectedId !== id)
      }
      this.$emit('input', this.selectedIds)
    },
    close() {
      this.$bvModal.hide(this.modalId)
    }
  },
  mounted() {
    this.axiosGet(`/vehicles`).then(response => {
      this.tools = response.data.vehicles;
    })
  }
}
</script>

<style scoped>
  .selected-summary {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: var(--space-2);
  }

  .no-selection {
    color: var(--text-muted);
    font-size: var(--text-sm);
  }

  .modify-link {
    display: flex;
    justify-content: center;
    width: 100%;
    margin-top: var(--space-2);
    color: var(--main-color);
    cursor: pointer;
  }
</style>

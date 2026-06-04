<template>
  <div class="tag-selector">
    <div class="chips">
      <app-tag
        v-for="tag in selectedTags"
        :key="tag.id"
        :tag="tag"
        action="delete"
        @click="removeTag(tag)"
      />
      <button
        type="button"
        class="add-tag"
        :class="{ on: showPicker }"
        @click="togglePicker"
      >+ Add tag</button>
    </div>

    <div v-if="showPicker" class="tag-picker">
      <div class="picker-title">Add a tag</div>
      <div v-if="addableTags.length" class="chips">
        <app-tag
          v-for="tag in addableTags"
          :key="tag.id"
          :tag="tag"
          action="add"
          @click="addTag(tag)"
        />
      </div>
      <div v-else class="picker-empty">All tags added</div>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      id: {
        required: true
      },
      value: {
        type: Array,
        default: () => []
      }
    },
    data() {
      return {
        organization: this.$store.state.organization,
        organizationTags: [],
        selectedTags: [],
        addableTags: [],
        showPicker: false
      }
    },
    computed: {
      selectedTagIds() {
        return this.selectedTags.map(tag => tag.id);
      }
    },
    methods: {
      retrieveTags() {
        return this.axiosGet(`/organizations/${this.organization.id}/tags`)
          .then(response => {
            this.organizationTags = response.data.tags;
            this.calculateAddableTags();
          })
          .catch(error => {
            console.log(error);
          });
      },
      togglePicker() {
        this.showPicker = !this.showPicker;
      },
      addTag(tag) {
       this.selectedTags.push(tag);
       this.calculateAddableTags();
       this.$emit('input', this.selectedTagIds);
       // keep the picker open so several tags can be added in a row
      },
      removeTag(tag) {
        this.selectedTags = this.selectedTags.filter(t => t.id !== tag.id);
        this.calculateAddableTags();
        this.$emit('input', this.selectedTagIds);
      },
      calculateAddableTags() {
        this.addableTags = this.organizationTags.filter(tag => {
          return !this.selectedTags.some(selected => selected.id === tag.id);
        });
      }
    },
    mounted() {
      this.retrieveTags().then(() => {
        this.selectedTags = this.value.map(tagId => {
          return this.organizationTags.find(tag => tag.id === tagId);
        }).filter(tag => tag !== undefined);

        this.calculateAddableTags();
      });
    }
  }
</script>

<style scoped>
  .tag-selector {
    flex: 1 1 auto;
    min-width: 0;
  }

  .chips {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    justify-content: flex-end;
  }

  .add-tag {
    display: inline-flex;
    align-items: center;
    border: 1px dashed #bbb;
    color: #666;
    background: #fff;
    border-radius: 8px;
    padding: 2px 9px;
    font-size: 12.5px;
    line-height: 1.4;
    cursor: pointer;
  }

  .add-tag:hover,
  .add-tag.on {
    border-color: var(--main-color);
    color: var(--main-color);
  }

  .tag-picker {
    margin-top: 8px;
    border: 1px solid #e3e3e3;
    border-radius: 8px;
    padding: 8px;
    background: #fbfbfb;
  }

  .picker-title {
    font-size: 11px;
    color: #999;
    text-transform: uppercase;
    letter-spacing: .04em;
    margin-bottom: 6px;
  }

  .tag-picker .chips {
    justify-content: flex-start;
  }

  .picker-empty {
    font-size: 12px;
    color: #999;
  }
</style>

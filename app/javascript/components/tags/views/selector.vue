<template>
  <div>
    <b-form-group label="With Tags:">
      <div class="tag-list">
        <div class="tag-container" v-for="tag in selectedTags" :key="tag.id">
          <app-tag :tag="tag" action="delete" @click="removeTag(tag)"/>
        </div>
      </div>
    </b-form-group>

    <b-form-group label="Possible Tags">
      <div class="tag-list">
        <div class="tag-container" v-for="tag in addableTags" :key="tag.id" @click="addTag(tag)">
          <app-tag :tag="tag" action="add"/>
        </div>
      </div>
    </b-form-group>
  </div>
</template>

<script>
  import EventBus from '@/store/eventBus';

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
      addTag(tag) {
       this.selectedTags.push(tag);
       this.calculateAddableTags();
       this.$emit('input', this.selectedTagIds);
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
        console.log('Value:', this.value);
        this.selectedTags = this.value.map(tagId => {
          return this.organizationTags.find(tag => tag.id === tagId);
        }).filter(tag => tag !== undefined);

        console.log('Selected Tags:', this.selectedTags);

        this.calculateAddableTags();
      });

    
    }
  }
</script>

<style scoped>
  .tag-list {
    width: 100%;
    display: flex;
    flex-wrap: wrap;
  }

  .tag-container {
    margin-right: 8px;
    margin-bottom: 8px;
  }

</style>
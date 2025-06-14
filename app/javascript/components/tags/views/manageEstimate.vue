<template>
  <div>
    <b-form-group label="Current Tags">
      <div class="tag-list">
        <div class="tag-container" v-for="tag in estimateTags" :key="tag.id">
          <app-tag :tag="tag" action="delete" @click="removeTag(tag)"/>
        </div>
      </div>
    </b-form-group>

    <b-form-group label="Addable Tags">
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
      estimate: {
        required: true
      }
    },
    data() {
      return {
        organization: this.$store.state.organization,
        organizationTags: [],
        addableTags: [],
        estimateTags: this.estimate.tags,
      }
    },
    methods: {
      retrieveTags() {
        this.axiosGet(`/organizations/${this.organization.id}/tags`)
          .then(response => {
            this.organizationTags = response.data.tags;
            this.calculateAddableTags();
          })
          .catch(error => {
            console.log(error);
          });
      },
      addTag(tag) {
        this.axiosPost(`/organizations/${this.organization.id}/taggings`, { estimate_id: this.estimate.id, tag_id: tag.id })
          .then(response => {
            if (response.status === 200) {
              this.estimateTags.push(tag);
              this.calculateAddableTags();
              this.$emit('tagsChanged', this.estimateTags);
            }
          })
      },
      removeTag(tag) {
        this.axiosDelete(`/organizations/${this.organization.id}/taggings?estimate_id=${this.estimate.id}&tag_id=${tag.id}`)
          .then(response => {
            if (response.status === 200) {
              this.estimateTags = this.estimateTags.filter(estimateTag => estimateTag.id !== tag.id);
              this.calculateAddableTags();
              this.$emit('tagsChanged', this.estimateTags);
            }
          })
      },
      // updateEstimate() {
      //   let params = { estimate: { state: this.state, state_reason: this.reason } }
      //   if (!this.reasonAllowed()) {
      //     this.reason = null;
      //     params.estimate.state_reason = null;
      //   }

      //   this.axiosPut(`/estimates/${this.estimate.id}`, params)
      //     .then(response => {
      //       if (response.status === 200) {
      //         this.$root.$emit('bv::toggle::collapse', this.id);
      //         EventBus.$emit('ESTIMATE_UPDATED', { state: this.state, state_reason: this.reason, tags: this.estimateTags });
      //       }
      //     })
      // },
      calculateAddableTags() {
        this.addableTags = this.organizationTags.filter(tag => {
          return !this.estimateTags.some(estimateTag => estimateTag.id === tag.id);
        });
      }
    },
    mounted() {
      this.retrieveTags();
    },
    watch: {
      'estimate.tags'(newVal) {
        this.estimateTags = newVal;
        this.calculateAddableTags();
      }
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
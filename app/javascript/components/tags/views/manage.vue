<template>
  <div>
    <app-header title='Custom Tags'>
      <template v-slot:header-right>
        <a v-if='!limitReached && hasPermission("quick_costs", "create")' @click="createTag">
          New
        </a>
        <span v-else>Limit Reached</span>
      </template>
    </app-header>

    <div class='tag-description'>
      You can define <b>up to 20</b> custom tags that can be added to estimates.
    </div>

    <div class="custom-tag-container">
      <table class='tag-table' v-if="nonSystemTags.length > 0">
        <div v-for="tag in nonSystemTags" :key="tag.id" class="tag-row">
          <div class="tag-cell"><app-tag :tag="tag" /></div>
          <div class="tag-cell tag-icons">
            <b-icon class='tag-icon' icon='pencil' @click='editTag(tag)'></b-icon>
            <b-icon class='tag-icon' icon='trash' @click='deleteTag(tag)'></b-icon>
          </div>
        </div>
      </table>
      <div v-else>
        <i>No custom tags created</i>
      </div>
    </div>

    <app-header title='System Tags'></app-header>
    <div class='tag-description'>System controlled tags can not be edited or deleted</div>

    <div class='tag-table'>
      <div v-for="tag in systemTags" :key="tag.id" class="tag-row">
      <div class="tag-cell"><app-tag :tag="tag" /></div>
      </div>
    </div>

    <app-create-or-update-tag
      :organization_id='organization_id'
      :tag='tagToEdit'
      @changed='retrieveTags'
      id='create-tag'
    />
  </div>
</template>

<script>
  import CreateOrUpdateTag from '@/components/tags/actions/create_or_update';

  export default {
    components: {
      'app-create-or-update-tag': CreateOrUpdateTag
    },
    props: {
      organization_id: {
        required: true,
        type: Number
      }
    },
    data() {
      return {
        tags: [],
        tagToEdit: null
      }
    },
    computed: {
      systemTags() {
        return this.tags.filter(tag => tag.system);
      },
      nonSystemTags() {
        return this.tags.filter(tag => !tag.system);
      },
      limitReached() {
        return this.nonSystemTags.length >= 20;
      }
    },
    methods : {
      retrieveTags() {
        this.axiosGet(`/organizations/${this.organization_id}/tags`).then(response => {
          this.tags = response.data.tags;
        })
      },
      createTag() {
        this.tagToEdit = null;
        this.$root.$emit('bv::toggle::collapse', 'create-tag');
      },
      editTag(tag) {
        this.tagToEdit = tag;
        this.$root.$emit('bv::toggle::collapse', 'create-tag');
      },
      deleteTag(tag) {
        if (confirm('Are you sure you want to delete this tag? It will be removed from all existing estimates.')) {
          this.axiosDelete(`/organizations/${this.organization_id}/tags/${tag.id}`).then(() => {
            this.retrieveTags();
          });
        }
      }
    },
    mounted() {
      this.retrieveTags();
    } 
  }
</script>

<style>
  .custom-tag-container {
    margin-bottom: 48px;
  } 

  .tag-table {
    width: 100%;
  }

  .tag-description {
    font-size: 0.75rem;
    color: grey;
    margin-top: -8px;
    margin-bottom: 8px;
  }

  .tag-row {
    border-bottom: 1px solid grey;
    display: flex;
    width: 100%;
    justify-content: space-between;
  }

  .tag-cell {
    padding: 8px;
  }

  .tag-icons {
    text-align: right;
  }

  .tag-icon {
    cursor: pointer;
    margin-left: 8px;
    color: var(--main-color);
  }
</style>
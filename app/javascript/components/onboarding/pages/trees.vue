<template>
    <app-pane  :formTitle='formTitle()'>
      <template v-slot:left-side>
        <div>
          <app-tree-form
            :treeNumber='treeNumber'
            :value='trees[0]'
            @input="(tree) => updateTree(0, tree)"
            v-if='treeNumber == 1'
            :key='1'
            :stumpingOnly='stumpingOnly'
          />

          <app-tree-form
            :treeNumber='treeNumber'
            :value='trees[1]'
            v-if='treeNumber == 2'
            @input="(tree) => updateTree(1, tree)"
            :key='2'
            :stumpingOnly='stumpingOnly'
          />

          <app-tree-form
            :treeNumber='treeNumber'
            :value='trees[2]'
            v-if='treeNumber == 3'
            @input="(tree) => updateTree(2, tree)"
            :key='3'
            :stumpingOnly='stumpingOnly'
          />
        </div>
      </template>
      <template v-slot:right-side>
        Give us as much detail as you can about the tree or stump you need work on. <br /><br />

        Detailed <b>pictures</b> of your trees or stumps will help us accurately assess your job. Pictures of the tree from multiple angles, and close-ups of any problem areas are especially helpful. <br /><br />

        An overall description of the job will help us assess the scope of the work, and the equipment and personnel needed to complete the job. <br /><br />

        The more information you provide, the faster and more accurate your estimate will be.
      </template>
      <template v-slot:controls>
        <app-buttons></app-buttons>
      </template>
    </app-pane>
</template>

<script>
import Pane from '@/components/onboarding/pane';
import FormButtons from '@/components/onboarding/widgets/formButtons';
import TreeForm from '@/components/onboarding/widgets/treeForm';

export default {
  components: {
    'app-pane' : Pane,
    'app-buttons': FormButtons,
    'app-tree-form': TreeForm
  },
  props: ['treeNumber', 'value', 'stumpingOnly'],
  data() {
    return {
      trees: this.value
    }
  },
  computed: {
    currentTree() {
      return this.trees[this.treeNumber - 1];
    }
  },
  methods: {
    updateTree(index, tree){
      this.trees[index] = tree;
      this.$emit('input', this.trees);
    },
    formTitle() {
      if(this.stumpingOnly) {
        return `Tell us about Stump #${this.treeNumber}`
      } else {
        return `Tell us about Tree #${this.treeNumber}`;
      }
    }
  },
  watch: {
    treeNumber() {
      console.log(this.trees);
    },
    trees() {

    }
  }
}
</script>

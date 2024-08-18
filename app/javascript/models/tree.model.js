class Tree {
  constructor(tree){
    this.tree = tree
  }

  galleryDisplay(current_display_index) {
    if(this.tree === null) {
      return {
        workType: 'No Task',
        treeName: 'Uncategorized'
      };
    }

    return {
      id:           this.tree.id,
      workType:     this.tree.work_name,
      description:  this.tree.description,
      stumpRemoval: this.tree.stumpRemoval ? 'Yes' : 'No',
      treeName: `Task #${current_display_index}`
    }
  }
}

export default Tree

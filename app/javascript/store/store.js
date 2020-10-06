import Vue from 'vue';
import Vuex from 'vuex'

Vue.use(Vuex);

export const store = new Vuex.Store({
  state: {
    user: { logged_in: false, admin: false, user_id: null },
    estimates: []
  },
  mutations: {
    setUser (state, user) {
      state.user = user;
    },
    setEstimates(state, payload) {
      state.estimates = payload;
    }
  },
  getters: { 
    isAdmin: state => {
      return state.user && state.user.admin;
    }
  }
})

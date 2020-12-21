import Vue from 'vue';
import Vuex from 'vuex'

import axiosFunc from '../mixins/axiosFunctions';

Vue.use(Vuex);

export const store = new Vuex.Store({
  state: {
    user: { logged_in: false, admin: false, user_id: null },
    estimates: [],
    arborists: []
  },
  mutations: {
    setUser (state, user) {
      state.user = user;
    },
    setEstimates(state, payload) {
      state.estimates = payload;
    },
    setArborists(state, payload) {
      state.arborists = payload;
    }
  },
  actions: {
    refreshArborists({ commit }) {
      axiosFunc.get('/arborists.json').then(response => {
        commit('setArborists', response.data.arborists);
      })
    }
  },
  getters: {
    isAdmin: state => {
      return state.user && state.user.admin;
    }
  }
})

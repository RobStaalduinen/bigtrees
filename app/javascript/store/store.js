import Vue from 'vue';
import Vuex from 'vuex'

import axiosFunc from '../mixins/axiosFunctions';

import { Authorization } from '../models';

Vue.use(Vuex);

export const store = new Vuex.Store({
  state: {
    user: { logged_in: false, user_id: null },
    lastRoute: null,
    authorization: null,
    estimates: [],
    estimateSettings: {
      mySchedule: false
    },
    arborists: [],
    organization: {}
  },
  mutations: {
    setUser (state, user) {
      state.authorization = new Authorization(user.role_permissions);
      state.user = user;
    },
    setEstimates(state, payload) {
      state.estimates = payload;
    },
    setArborists(state, payload) {
      state.arborists = payload;
    },
    setOrganization(state, payload) {
      state.organization = payload
    },
    updateOrganization(state, payload) {
      state.organization = {
        ...state.organization,
        ...payload
      }
    },
    setEstimateSettings(state, payload) {
      state.estimateSettings = {
        ...state.estimateSettings,
        ...payload
      }
    }
  },
  actions: {
    refreshArborists({ commit }) {
      axiosFunc.get('/arborists.json').then(response => {
        commit('setArborists', response.data.arborists);
      })
    },
    authenticate({ commit }) {
      return axiosFunc.get('/authenticate').then(response => {
        if(response.status == 200 && response.data.logged_in){
          commit('setUser', response.data);
        }

        let organization_id = response.data.default_organization_id;
        if(localStorage.getItem('selectedOrganizationId')) {
          organization_id = localStorage.getItem('selectedOrganizationId');
        }

        axiosFunc.get(`/organizations/${organization_id}`).then(response => {
          commit('setOrganization', response.data.organization)
        })

      })
    },
    refreshOrganization({ commit }) {
      let organization_id = localStorage.getItem('selectedOrganizationId') || null;
      if (organization_id) {
        return axiosFunc.get(`/organizations/${organization_id}`).then(response => {
          commit('setOrganization', response.data.organization);
        });
      }
    }
  },
  getters: {
    hasPermission: (state) => (page, permission_type) => {
      return state.authorization.hasPermission(page, permission_type);
    },
    featureEnabled: (state) => (feature) => {
      return state.organization.configuration[feature] === true;
    },
    userRole: (state) => () => {
      return state.user.role;
    }
  }
})

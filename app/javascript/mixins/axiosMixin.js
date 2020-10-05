import axios from 'axios';

export default {
  methods: {
    axiosPut (endpoint, options) { 
      this.setupAxios();
      return axios.put(endpoint, options, { withCredentials: true });
    },
    axiosGet(endpoint, params = {}){
      this.setupAxios();
      return axios.get(endpoint, { params: params, withCredentials: true });
    },
    setupAxios() {
      axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector("meta[name=csrf-token]").content;
      axios.defaults.headers.common['Accept'] = 'application/json'
      axios.defaults.headers.common['Content-Type'] = 'application/json'
    }
  }
}

import axios from 'axios';

export default {
  methods: {
    axiosPut (endpoint, options) { 
      this.setupAxios();
      return axios.put(endpoint, options, { withCredentials: true });
    },
    axiosGet(endpoint){
      this.setupAxios();
      return axios.get(endpoint, { withCredentials: true });
    },
    setupAxios() {
      axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector("meta[name=csrf-token]").content;;
    }
  }
}

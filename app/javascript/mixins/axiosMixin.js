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
    axiosPost(endpoint, options){
      this.setupAxios();
      return axios.post(endpoint, options, { withCredentials: true });
    },
    axiosImagePost(endpoint, formData){
      let options = { 'Content-Type': 'multipart/form-data' };
      return axios.post(endpoint, formData, options);
    },
    setupAxios() {
      axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector("meta[name=csrf-token]").content;
      axios.defaults.headers.common['Accept'] = 'application/json'
      axios.defaults.headers.common['Content-Type'] = 'application/json'
    }
  }
}

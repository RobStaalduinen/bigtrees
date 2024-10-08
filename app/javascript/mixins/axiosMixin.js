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
    axiosDelete(endpoint, options){
      this.setupAxios();
      return axios.delete(endpoint, options, { withCredentials: true });
    },
    axiosImagePost(endpoint, formData){
      let options = { 'Content-Type': 'multipart/form-data' };
      return axios.post(endpoint, formData, options);
    },
    axiosDownload(endpoint, fileName) {
      this.setupAxios();
      let options = { responseType: 'blob'}
      return axios.get(endpoint, options, { withCredentials: true }).then(response => {

        const href = URL.createObjectURL(response.data);
        // create "a" HTML element with href to file & click
        const link = document.createElement('a');
        link.href = href;
        link.setAttribute('download', fileName); //or any other extension
        document.body.appendChild(link);
        link.click();

        // clean up "a" element & remove ObjectURL
        document.body.removeChild(link);
        URL.revokeObjectURL(href);
      })
    },
    axiosBase64ImagePost(endpoint, image) {
      let options = {
        'Content-Type': 'image/png',
        'Content-Encoding': 'base64'
      };
    },
    setupAxios() {
      axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector("meta[name=csrf-token]").content;
      axios.defaults.headers.common['Accept'] = 'application/json'
      axios.defaults.headers.common['Content-Type'] = 'application/json'

      if(localStorage.getItem('selectedOrganizationId') != null) {
        axios.defaults.headers.common['X-ORGANIZATION-ID'] = localStorage.getItem('selectedOrganizationId');
      }
    }
  }
}

import axios from 'axios';

export default {
  get(endpoint, params) {
    this.setup();
    return axios.get(endpoint, { params: params, withCredentials: true });
  },
  setup() {
    axios.defaults.headers.common['X-CSRF-Token'] = document.querySelector("meta[name=csrf-token]").content;
    axios.defaults.headers.common['Accept'] = 'application/json'
    axios.defaults.headers.common['Content-Type'] = 'application/json'
  }
}

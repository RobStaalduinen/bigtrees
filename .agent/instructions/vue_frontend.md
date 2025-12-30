# Vue Frontend Development Rules

- **Axios Usage**: When calling APIs, where possible, use the default Axios global mixins (`axiosGet`, `axiosPost`, `axiosPut`, `axiosDelete`) established from `axiosMixin.js` to ensure consistent error handling and header configuration.

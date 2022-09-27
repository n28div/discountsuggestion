import Vue from 'vue'
import App from './App.vue'
import axios from 'axios'
import Buefy from 'buefy'
import 'buefy/dist/buefy.css'


Vue.use({
    install (Vue) {
    Vue.prototype.$api = axios.create({
      baseURL: 'http://127.0.0.1:5555/'
    })
  }
})

Vue.use(Buefy)

Vue.config.productionTip = false

new Vue({
  render: h => h(App),
}).$mount('#app')

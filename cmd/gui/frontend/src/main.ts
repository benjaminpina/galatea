import {createApp} from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import VueKonva from 'vue-konva';
import App from './App.vue'
import pinia from './stores'
import router from './router';
import './style.css';

const app = createApp(App)

app.use(pinia)
app.use(ElementPlus)
app.use(VueKonva)
app.use(router)

app.mount('#app')

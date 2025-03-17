import {createApp} from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import App from './App.vue'
import VueKonva from 'vue-konva';
import './style.css';

const app = createApp(App)

app.use(ElementPlus)
app.use(VueKonva)

app.mount('#app')

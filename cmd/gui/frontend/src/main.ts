import {createApp} from 'vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import { Icon } from '@iconify/vue';
import VueKonva from 'vue-konva';
import App from './App.vue'
import pinia from './stores'
import { VueQueryPlugin } from '@tanstack/vue-query';
import router from './router';
import './style.css';

const app = createApp(App)

app.use(pinia)
app.use(VueQueryPlugin)
app.use(ElementPlus)
app.use(VueKonva)
app.use(router)

// Register Iconify icons
app.component('Icon', Icon)

app.mount('#app')

import {createApp} from 'vue'
import ElementPlus from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
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

// Register ElementPlus icons
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

app.mount('#app')

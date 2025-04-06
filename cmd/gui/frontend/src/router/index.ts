import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';



const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'main',
    component: () => import('../layouts/MainLayout.vue'),
    children: [
      {
        path: '',
        name: 'main.home',
        component: () => import('../pages/HomePage.vue')
      }
    ]
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
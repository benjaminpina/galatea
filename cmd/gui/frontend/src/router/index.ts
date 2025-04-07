import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router';

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'projects',
    component: () => import('../pages/ProjectsPage.vue')
  },
  {
    path: '/substrates',
    name: 'substrates',
    component: () => import('../pages/SubstratesPage.vue')
  },
  {
    path: '/stages',
    name: 'stages',
    component: () => import('../pages/StagesPage.vue')
  },
  {
    path: '/agents',
    name: 'agents',
    component: () => import('../pages/AgentsPage.vue')
  },
  {
    path: '/environments',
    name: 'environments',
    component: () => import('../pages/EnvironmentsPage.vue')
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;